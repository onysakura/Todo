import { invoke } from '@tauri-apps/api/core'

export type TaskStatus = 'pending' | 'completed' | 'cancelled'

export interface TagDto {
  id: string
  name: string
  colorValue: string | null
  sortOrder: number
}

export interface TaskListItemDto {
  seriesId: string
  revisionId: string
  occurrenceKey: string
  title: string
  note: string | null
  tagId: string | null
  priority: number | null
  allDay: boolean
  startDate: string | null
  startTime: string | null
  dueDate: string
  dueTime: string | null
  status: TaskStatus
  createdAt: string
}

export interface CalendarDayDto {
  date: string
  items: TaskListItemDto[]
}

export interface TaskEditorDto {
  seriesId: string
  revisionId: string
  kind: string
  title: string
  note: string | null
  tagId: string | null
  priority: number | null
  allDay: boolean
  startDate: string | null
  startTime: string | null
  dueDate: string
  dueTime: string | null
  currentStatus: TaskStatus
}

export interface TaskDetailDto {
  seriesId: string
  revisionId: string
  occurrenceKey: string
  kind: string
  title: string
  note: string | null
  tagId: string | null
  priority: number | null
  allDay: boolean
  startDate: string | null
  startTime: string | null
  dueDate: string
  dueTime: string | null
  status: TaskStatus
  completedAt: string | null
  cancelledAt: string | null
}

export interface UpcomingQueryInput {
  startDate?: string
  dayCount?: number
}

export interface TaskSaveInput {
  title: string
  note: string | null
  tagId: string | null
  priority: number | null
  allDay: boolean
  startDate: string | null
  startTime: string | null
  dueDate: string
  dueTime: string | null
}

export interface TaskUpdateInput extends TaskSaveInput {
  seriesId: string
}

export interface TaskSetStatusInput {
  seriesId: string
  status: TaskStatus
}

export async function listTags() {
  return invoke<TagDto[]>('tag_list')
}

export async function queryUpcomingTasks(input: UpcomingQueryInput) {
  return invoke<TaskListItemDto[]>('upcoming_query', { input })
}

export async function queryCalendarTasks(input: UpcomingQueryInput) {
  return invoke<CalendarDayDto[]>('task_calendar_query', { input })
}

export async function getTaskDetail(seriesId: string) {
  return invoke<TaskDetailDto | null>('task_get_detail', { seriesId })
}

export async function getTaskEditor(seriesId: string) {
  return invoke<TaskEditorDto | null>('task_get_editor', { seriesId })
}

export async function createTask(input: TaskSaveInput) {
  return invoke<TaskDetailDto>('task_create', { input })
}

export async function updateTask(input: TaskUpdateInput) {
  return invoke<TaskDetailDto>('task_update', { input })
}

export async function setTaskStatus(input: TaskSetStatusInput) {
  return invoke<TaskDetailDto>('task_set_status', { input })
}

export async function deleteTask(seriesId: string) {
  return invoke<void>('task_delete', { seriesId })
}
