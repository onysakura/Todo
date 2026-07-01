import { invoke } from '@tauri-apps/api/core'

export type ReminderKind = 'danger' | 'due'

export interface ReminderItem {
  seriesId: string
  occurrenceKey: string
  title: string
  /** 触发时间，无时区 ISO 字符串 `YYYY-MM-DDTHH:MM:SS`。 */
  triggerAt: string
  kind: ReminderKind
  payload: string | null
}

export interface ReminderPlan {
  items: ReminderItem[]
  windowStart: string
  windowEnd: string
}

/**
 * 手动触发提醒重建：计算近期计划并交给平台调度，返回计划供前端展示。
 */
export async function rebuildReminders() {
  return invoke<ReminderPlan>('reminder_rebuild')
}

/**
 * 预览近期提醒计划（不调度），供前端展示。
 * @param windowHours 自定义窗口小时数；不传则使用后端默认（24h）。
 */
export async function previewReminders(windowHours?: number) {
  return invoke<ReminderPlan>('reminder_preview', { windowHours })
}
