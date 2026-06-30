import { describe, expect, it, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import RecentView from '../RecentView.vue'
import type { TaskListItemDto } from '../../features/tasks/task-api'

vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}))

import { invoke } from '@tauri-apps/api/core'

function createMockTask(overrides: Partial<TaskListItemDto> = {}): TaskListItemDto {
  return {
    seriesId: 'series-1',
    revisionId: 'rev-1',
    occurrenceKey: '2026-06-30',
    title: '近期任务',
    note: null,
    tagId: null,
    priority: null,
    allDay: true,
    startDate: null,
    startTime: null,
    dueDate: '2026-06-30',
    dueTime: null,
    status: 'pending',
    createdAt: '2026-06-20T10:00:00Z',
    ...overrides,
  }
}

describe('RecentView', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('未完成任务归入未完成分组', async () => {
    const tasks = [
      createMockTask({ seriesId: 's1', title: '待办A', status: 'pending' }),
    ]
    vi.mocked(invoke).mockResolvedValue(tasks)

    const wrapper = mount(RecentView)
    await flushPromises()

    expect(wrapper.text()).toContain('未完成')
    expect(wrapper.text()).toContain('待办A')
    expect(wrapper.findAll('.status-group')).toHaveLength(1)
  })

  it('已完成和已取消任务归入已完成/已取消分组', async () => {
    const tasks = [
      createMockTask({ seriesId: 's1', title: '已完成任务', status: 'completed' }),
      createMockTask({ seriesId: 's2', title: '已取消任务', status: 'cancelled' }),
    ]
    vi.mocked(invoke).mockResolvedValue(tasks)

    const wrapper = mount(RecentView)
    await flushPromises()

    expect(wrapper.text()).toContain('已完成 / 已取消')
    expect(wrapper.text()).toContain('已完成任务')
    expect(wrapper.text()).toContain('已取消任务')
  })

  it('未完成和已完成任务分别归入两个分组', async () => {
    const tasks = [
      createMockTask({ seriesId: 's1', title: '待办', status: 'pending' }),
      createMockTask({ seriesId: 's2', title: '已办', status: 'completed' }),
    ]
    vi.mocked(invoke).mockResolvedValue(tasks)

    const wrapper = mount(RecentView)
    await flushPromises()

    const groups = wrapper.findAll('.status-group')
    expect(groups).toHaveLength(2)
    expect(groups[0].text()).toContain('待办')
    expect(groups[1].text()).toContain('已办')
  })

  it('无任务时显示空提示', async () => {
    vi.mocked(invoke).mockResolvedValue([])

    const wrapper = mount(RecentView)
    await flushPromises()

    expect(wrapper.text()).toContain('还没有任务')
  })

  it('点击任务时触发 select 事件', async () => {
    const tasks = [
      createMockTask({ seriesId: 'series-pick', status: 'pending' }),
    ]
    vi.mocked(invoke).mockResolvedValue(tasks)

    const wrapper = mount(RecentView)
    await flushPromises()

    await wrapper.find('.task-card').trigger('click')
    expect(wrapper.emitted('select')).toBeTruthy()
    expect(wrapper.emitted('select')![0]).toEqual(['series-pick'])
  })

  it('加载中显示加载提示', async () => {
    vi.mocked(invoke).mockReturnValue(new Promise(() => {}))

    const wrapper = mount(RecentView)
    await flushPromises()

    expect(wrapper.text()).toContain('正在加载近期任务')
  })

  it('加载失败显示错误信息', async () => {
    vi.mocked(invoke).mockRejectedValue(new Error('数据库错误'))

    const wrapper = mount(RecentView)
    await flushPromises()

    expect(wrapper.text()).toContain('加载近期任务失败')
    expect(wrapper.text()).toContain('数据库错误')
  })
})
