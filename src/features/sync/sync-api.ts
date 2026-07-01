import { invoke } from '@tauri-apps/api/core'

export interface SyncMetaItemDto {
  key: string
  value: string
  updatedAt: string
}

export interface SyncStatusDto {
  remoteEtag: string | null
  remoteVersion: string | null
  lastSyncAt: string | null
  localDirty: boolean
  dirtyBaseRemoteEtag: string | null
  lastSyncResult: string | null
  deviceId: string | null
  lastRecoveryPath: string | null
  lastRecoveryAt: string | null
  lastRecoveryReason: string | null
  rawItems: SyncMetaItemDto[]
}

export interface SyncOutcome {
  action: 'pushed' | 'pulled' | 'up_to_date' | 'conflict_recovered' | 'error'
  message: string
  recoveryPath: string | null
}

export interface SaveCheckResult {
  status: 'ok' | 'conflict' | 'offline'
  message: string
}

export interface SettingItemDto {
  key: string
  valueJson: string
  updatedAt: string
}

export interface SettingsDto {
  items: SettingItemDto[]
}

export interface SettingsSetInput {
  key: string
  valueJson: string
}

export interface SyncMetaSetInput {
  key: string
  value: string
}

export async function getSyncStatus() {
  return invoke<SyncStatusDto>('sync_status_get')
}

export async function setSyncMeta(input: SyncMetaSetInput) {
  return invoke<SyncMetaItemDto>('sync_meta_set', { input })
}

export async function deleteSyncMeta(key: string) {
  return invoke<void>('sync_meta_delete', { key })
}

export async function runSync() {
  return invoke<SyncOutcome>('sync_run')
}

export async function checkSyncBeforeSave() {
  return invoke<SaveCheckResult>('sync_check_before_save')
}

export async function markSyncDirty() {
  return invoke<void>('sync_mark_dirty')
}

export async function getSettings() {
  return invoke<SettingsDto>('settings_get')
}

export async function setSetting(input: SettingsSetInput) {
  return invoke<SettingItemDto>('settings_set', { input })
}

export async function deleteSetting(key: string) {
  return invoke<void>('settings_delete', { key })
}

/**
 * 将任意可序列化的值编码为后端 settings 表使用的 JSON 字符串。
 */
export function encodeSettingValue(value: string | null): string {
  return JSON.stringify(value)
}

/**
 * 从后端 settings 项中解析出字符串值（null 表示未配置）。
 */
export function decodeSettingValue(valueJson: string | null | undefined): string | null {
  if (!valueJson) {
    return null
  }
  try {
    const parsed = JSON.parse(valueJson)
    return typeof parsed === 'string' ? parsed : null
  } catch {
    return null
  }
}
