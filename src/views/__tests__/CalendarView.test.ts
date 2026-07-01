import { describe, expect, it, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import CalendarView from '../CalendarView.vue'
import type { CalendarDayDto, TaskListItemDto } from '../../features/tasks/task-api'

vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}))

import { invoke } from '@tauri-apps/api/core'

function createMockTask(overrides: Partial<TaskListItemDto> = {}): TaskListItemDto {
  return {
    seriesId: 'series-1',
    revisionId: 'rev-1',
    occurrenceKey: '2026-06-15',
    title: '日历任务',
    note: null,
    tagId: null,
    priority: null,
    allDay: true,
    startDate: null,
    startTime: null,
    dueDate: '2026-06-15',
    dueTime: null,
    status: 'pending',
    createdAt: '2026-06-01T10:00:00Z',
    ...overrides,
  }
}

describe('CalendarView', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('首日显示月份分隔符', async () => {
    const mockDays: CalendarDayDto[] = [
      { date: '2026-06-01', items: [] },
      { date: '2026-06-02', items: [] },
    ]
    vi.mocked(invoke).mockResolvedValue(mockDays)

    const wrapper = mount(CalendarView)
    await flushPromises()

    const separators = wrapper.findAll('.month-separator')
    expect(separators).toHaveLength(1)
    expect(separators[0].text()).toContain('2026 年 6 月')
  })

  it('跨月时显示月份分隔符', async () => {
    const mockDays: CalendarDayDto[] = [
      { date: '2026-06-30', items: [] },
      { date: '2026-07-01', items: [] },
    ]
    vi.mocked(invoke).mockResolvedValue(mockDays)

    const wrapper = mount(CalendarView)
    await flushPromises()

    const separators = wrapper.findAll('.month-separator')
    expect(separators).toHaveLength(2)
    expect(separators[0].text()).toContain('2026 年 6 月')
    expect(separators[1].text()).toContain('2026 年 7 月')
  })

  it('空日显示占位符', async () => {
    const mockDays: CalendarDayDto[] = [
      { date: '2026-06-15', items: [] },
    ]
    vi.mocked(invoke).mockResolvedValue(mockDays)

    const wrapper = mount(CalendarView)
    await flushPromises()

    const emptyDay = wrapper.find('.calendar-day--empty')
    expect(emptyDay.exists()).toBe(true)
    expect(emptyDay.text()).toContain('—')
  })

  it('有任务的日期渲染任务卡片', async () => {
    const task = createMockTask({ title: '重要会议', dueDate: '2026-06-15' })
    const mockDays: CalendarDayDto[] = [
      { date: '2026-06-15', items: [task] },
    ]
    vi.mocked(invoke).mockResolvedValue(mockDays)

    const wrapper = mount(CalendarView)
    await flushPromises()

    expect(wrapper.text()).toContain('重要会议')
    expect(wrapper.findAll('.task-card')).toHaveLength(1)
  })

  it('同日多任务渲染多个任务卡片', async () => {
    const task1 = createMockTask({ seriesId: 's1', title: '任务A', dueDate: '2026-06-15' })
    const task2 = createMockTask({ seriesId: 's2', title: '任务B', dueDate: '2026-06-15' })
    const mockDays: CalendarDayDto[] = [
      { date: '2026-06-15', items: [task1, task2] },
    ]
    vi.mocked(invoke).mockResolvedValue(mockDays)

    const wrapper = mount(CalendarView)
    await flushPromises()

    expect(wrapper.text()).toContain('任务A')
    expect(wrapper.text()).toContain('任务B')
    expect(wrapper.findAll('.task-card')).toHaveLength(2)
  })

  it('点击任务时触发 select 事件', async () => {
    const task = createMockTask({ seriesId: 'series-xyz', dueDate: '2026-06-15' })
    const mockDays: CalendarDayDto[] = [
      { date: '2026-06-15', items: [task] },
    ]
    vi.mocked(invoke).mockResolvedValue(mockDays)

    const wrapper = mount(CalendarView)
    await flushPromises()

    await wrapper.find('.task-card').trigger('click')
    expect(wrapper.emitted('select')).toBeTruthy()
    expect(wrapper.emitted('select')![0]).toEqual(['series-xyz'])
  })

  it('加载中显示加载提示', async () => {
    vi.mocked(invoke).mockReturnValue(new Promise(() => {}))

    const wrapper = mount(CalendarView)
    await flushPromises()

    expect(wrapper.text()).toContain('正在加载日历')
  })

  it('加载失败显示错误信息', async () => {
    vi.mocked(invoke).mockRejectedValue(new Error('连接失败'))

    const wrapper = mount(CalendarView)
    await flushPromises()

    expect(wrapper.text()).toContain('加载日历失败')
    expect(wrapper.text()).toContain('连接失败')
  })
})
