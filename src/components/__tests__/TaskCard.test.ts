import { describe, expect, it, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import TaskCard from '../TaskCard.vue'
import type { TaskListItemDto } from '../../features/tasks/task-api'

function createMockTask(overrides: Partial<TaskListItemDto> = {}): TaskListItemDto {
  return {
    seriesId: 'series-1',
    revisionId: 'rev-1',
    occurrenceKey: '2026-06-30',
    title: '测试任务',
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

describe('TaskCard', () => {
  it('渲染任务标题和状态标签', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ title: '周报整理', status: 'pending' }) },
    })
    expect(wrapper.text()).toContain('周报整理')
    expect(wrapper.text()).toContain('未完成')
  })

  it('当任务有开始日期时显示开始信息', () => {
    const wrapper = mount(TaskCard, {
      props: {
        task: createMockTask({
          startDate: '2026-06-25',
          startTime: '09:00',
          allDay: false,
        }),
      },
    })
    expect(wrapper.text()).toContain('开始')
  })

  it('当任务没有开始日期时不显示开始信息', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ startDate: null }) },
    })
    const metaItems = wrapper.findAll('.meta-start')
    expect(metaItems).toHaveLength(0)
  })

  it('已完成任务应用状态弱化样式', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ status: 'completed' }) },
    })
    expect(wrapper.find('.task-card').classes()).toContain('task-card--completed')
  })

  it('已取消任务应用状态弱化样式', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ status: 'cancelled' }) },
    })
    expect(wrapper.find('.task-card').classes()).toContain('task-card--cancelled')
  })

  it('未完成任务不应用弱化样式', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ status: 'pending' }) },
    })
    const classes = wrapper.find('.task-card').classes()
    expect(classes).not.toContain('task-card--completed')
    expect(classes).not.toContain('task-card--cancelled')
  })

  it('危险日任务应用高亮样式并显示危险日标签', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask(), isDangerDay: true },
    })
    expect(wrapper.find('.task-card').classes()).toContain('task-card--danger')
    expect(wrapper.text()).toContain('危险日')
  })

  it('非危险日任务不显示危险日标签', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask(), isDangerDay: false },
    })
    expect(wrapper.text()).not.toContain('危险日')
  })

  it('点击任务卡片时触发 select 事件', async () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ seriesId: 'series-abc' }) },
    })
    await wrapper.find('.task-card').trigger('click')
    expect(wrapper.emitted('select')).toBeTruthy()
    expect(wrapper.emitted('select')![0]).toEqual(['series-abc'])
  })

  it('当任务有优先级时显示优先级标识', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ priority: 1 }) },
    })
    expect(wrapper.text()).toContain('P1')
  })

  it('当任务无优先级时不显示优先级标识', () => {
    const wrapper = mount(TaskCard, {
      props: { task: createMockTask({ priority: null }) },
    })
    expect(wrapper.text()).not.toContain('P')
  })

  it('当有标签且 tagsById 中存在时显示标签名称', () => {
    const tagsById = new Map([
      ['tag-1', { id: 'tag-1', name: '工作', colorValue: '#ff0000', sortOrder: 0 }],
    ])
    const wrapper = mount(TaskCard, {
      props: {
        task: createMockTask({ tagId: 'tag-1' }),
        tagsById,
      },
    })
    expect(wrapper.text()).toContain('工作')
  })
})
