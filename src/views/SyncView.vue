<template>
  <div class="sync-view">
    <div class="view-header">
      <div>
        <p class="view-eyebrow">同步视图</p>
        <h2>WebDAV 远程优先同步</h2>
      </div>
      <button class="text-button" type="button" :disabled="isLoadingStatus" @click="loadAll">
        {{ isLoadingStatus ? '刷新中' : '刷新' }}
      </button>
    </div>

    <div v-if="error" class="inline-message inline-message--error">{{ error }}</div>

    <section class="card status-card">
      <div class="card-head">
        <h3>同步状态</h3>
        <span v-if="status" class="status-pill" :class="`status-pill--${statusPillKind}`">
          {{ statusPillLabel }}
        </span>
      </div>

      <div v-if="isLoadingStatus && !status" class="loading-message">正在读取同步状态…</div>
      <dl v-else-if="status" class="status-grid">
        <div class="status-item">
          <dt>设备 ID</dt>
          <dd>{{ status.deviceId ?? '未生成' }}</dd>
        </div>
        <div class="status-item">
          <dt>本地脏标记</dt>
          <dd>{{ status.localDirty ? '有未推送变更' : '已与远端对齐' }}</dd>
        </div>
        <div class="status-item">
          <dt>远端版本</dt>
          <dd>{{ status.remoteVersion ?? '尚未同步' }}</dd>
        </div>
        <div class="status-item">
          <dt>远端 ETag</dt>
          <dd class="status-etag">{{ status.remoteEtag ?? '—' }}</dd>
        </div>
        <div class="status-item">
          <dt>最近同步时间</dt>
          <dd>{{ formatTimestamp(status.lastSyncAt) }}</dd>
        </div>
        <div class="status-item">
          <dt>最近同步结果</dt>
          <dd>{{ status.lastSyncResult ?? '尚无记录' }}</dd>
        </div>
        <div class="status-item status-item--full">
          <dt>脏基线 ETag</dt>
          <dd class="status-etag">{{ status.dirtyBaseRemoteEtag ?? '—' }}</dd>
        </div>
        <div v-if="status.lastRecoveryPath" class="status-item status-item--full">
          <dt>最近恢复副本</dt>
          <dd>{{ status.lastRecoveryPath }}</dd>
        </div>
        <div v-if="status.lastRecoveryAt" class="status-item">
          <dt>恢复时间</dt>
          <dd>{{ formatTimestamp(status.lastRecoveryAt) }}</dd>
        </div>
        <div v-if="status.lastRecoveryReason" class="status-item status-item--full">
          <dt>恢复原因</dt>
          <dd>{{ status.lastRecoveryReason }}</dd>
        </div>
      </dl>
    </section>

    <section class="card config-card">
      <div class="card-head">
        <h3>WebDAV 配置</h3>
      </div>

      <div class="form-grid">
        <label class="field-block">
          <span class="field-label">服务器地址</span>
          <input
            v-model="form.webdavUrl"
            class="text-input"
            type="url"
            placeholder="https://dav.example.com/todo/"
            :disabled="isSavingConfig"
          />
        </label>

        <label class="field-block">
          <span class="field-label">用户名</span>
          <input
            v-model="form.webdavUser"
            class="text-input"
            type="text"
            autocomplete="off"
            placeholder="可选"
            :disabled="isSavingConfig"
          />
        </label>

        <label class="field-block field-block--full">
          <span class="field-label">密码 / 应用专用密码</span>
          <input
            v-model="form.webdavPassword"
            class="text-input"
            type="password"
            autocomplete="off"
            placeholder="可选"
            :disabled="isSavingConfig"
          />
        </label>
      </div>

      <div class="card-actions">
        <button
          class="ghost-button"
          type="button"
          :disabled="isSavingConfig"
          @click="handleSaveConfig"
        >
          {{ isSavingConfig ? '保存中…' : '保存配置' }}
        </button>
        <button
          class="ghost-button"
          type="button"
          :disabled="isSavingConfig"
          @click="handleClearConfig"
        >
          清除已保存配置
        </button>
      </div>
    </section>

    <section class="card action-card">
      <div class="card-head">
        <h3>同步操作</h3>
      </div>

      <p class="action-hint">
        远程优先策略：冲突时以远端为准，本地脏数据会先导出为恢复副本。
      </p>

      <div v-if="outcome" class="inline-message" :class="`inline-message--${outcomeKind}`">
        {{ outcomeMessage }}
      </div>

      <div class="card-actions">
        <button
          class="primary-button"
          type="button"
          :disabled="isSyncing || !hasConfig"
          @click="handleRunSync"
        >
          {{ isSyncing ? '同步中…' : '立即同步' }}
        </button>
        <button
          class="ghost-button"
          type="button"
          :disabled="isMarkingDirty || !status"
          @click="handleMarkDirty"
        >
          {{ isMarkingDirty ? '标记中…' : '标记本地为脏' }}
        </button>
        <button
          class="ghost-button"
          type="button"
          :disabled="isChecking || !hasConfig"
          @click="handleCheckBeforeSave"
        >
          {{ isChecking ? '检查中…' : '保存前冲突检查' }}
        </button>
      </div>

      <div v-if="saveCheck" class="inline-message" :class="`inline-message--${saveCheckKind}`">
        {{ saveCheck.message }}
      </div>
    </section>

    <section class="card reminder-card">
      <div class="card-head">
        <h3>提醒设置</h3>
      </div>

      <p class="action-hint">
        危险日与截止提醒由后台计算并交由系统通知调度；关闭后取消已有通知。
      </p>

      <div class="form-grid">
        <label class="field-block field-block--check">
          <input
            v-model="reminderForm.enabled"
            class="checkbox-input"
            type="checkbox"
            :disabled="isSavingReminder"
          />
          <span class="field-label">启用提醒</span>
        </label>

        <label class="field-block">
          <span class="field-label">提醒窗口（小时，默认 24）</span>
          <input
            v-model.number="reminderForm.windowHours"
            class="text-input"
            type="number"
            min="1"
            :disabled="isSavingReminder"
          />
        </label>

        <label class="field-block">
          <span class="field-label">后台同步间隔（分钟，最小 5，默认 15）</span>
          <input
            v-model.number="reminderForm.intervalMinutes"
            class="text-input"
            type="number"
            min="5"
            :disabled="isSavingReminder"
          />
        </label>
      </div>

      <div class="card-actions">
        <button
          class="ghost-button"
          type="button"
          :disabled="isSavingReminder"
          @click="handleSaveReminderSettings"
        >
          {{ isSavingReminder ? '保存中…' : '保存提醒设置' }}
        </button>
      </div>
    </section>

    <section class="card preview-card">
      <div class="card-head">
        <h3>提醒预览</h3>
        <button
          class="text-button"
          type="button"
          :disabled="isPreviewing"
          @click="handlePreviewReminders"
        >
          {{ isPreviewing ? '加载中' : '刷新预览' }}
        </button>
      </div>

      <div v-if="isPreviewing && !reminderPlan" class="loading-message">正在计算近期提醒…</div>
      <div v-else-if="reminderPlan && reminderPlan.items.length === 0" class="action-hint">
        近期无待触发提醒。
      </div>
      <ul v-else-if="reminderPlan" class="reminder-list">
        <li
          v-for="item in reminderPlan.items"
          :key="`${item.seriesId}::${item.occurrenceKey}::${item.kind}`"
          class="reminder-item"
        >
          <span class="reminder-time">{{ item.triggerAt }}</span>
          <span class="reminder-kind" :class="`reminder-kind--${item.kind}`">
            {{ item.kind === 'danger' ? '危险日' : '截止' }}
          </span>
          <span class="reminder-title">{{ item.title }}</span>
        </li>
      </ul>

      <div class="card-actions">
        <button
          class="primary-button"
          type="button"
          :disabled="isRebuilding"
          @click="handleRebuildReminders"
        >
          {{ isRebuilding ? '重建中…' : '立即重建提醒' }}
        </button>
      </div>

      <div v-if="rebuildMessage" class="inline-message" :class="`inline-message--${rebuildKind}`">
        {{ rebuildMessage }}
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import {
  checkSyncBeforeSave,
  decodeSettingValue,
  encodeSettingValue,
  getSettings,
  getSyncStatus,
  markSyncDirty,
  runSync,
  setSetting,
  deleteSetting,
  type SaveCheckResult,
  type SyncOutcome,
  type SyncStatusDto,
} from '../features/sync/sync-api'
import {
  previewReminders,
  rebuildReminders,
  type ReminderPlan,
} from '../features/reminder/reminder-api'

const status = ref<SyncStatusDto | null>(null)
const isLoadingStatus = ref(false)
const isSavingConfig = ref(false)
const isSyncing = ref(false)
const isMarkingDirty = ref(false)
const isChecking = ref(false)
const error = ref('')
const outcome = ref<SyncOutcome | null>(null)
const saveCheck = ref<SaveCheckResult | null>(null)

interface ConfigForm {
  webdavUrl: string
  webdavUser: string
  webdavPassword: string
}

const form = reactive<ConfigForm>({
  webdavUrl: '',
  webdavUser: '',
  webdavPassword: '',
})

interface ReminderForm {
  enabled: boolean
  windowHours: number
  intervalMinutes: number
}

const reminderForm = reactive<ReminderForm>({
  enabled: true,
  windowHours: 24,
  intervalMinutes: 15,
})

const isSavingReminder = ref(false)
const isPreviewing = ref(false)
const isRebuilding = ref(false)
const reminderPlan = ref<ReminderPlan | null>(null)
const rebuildMessage = ref('')

const hasConfig = computed(() => Boolean(form.webdavUrl))

const statusPillKind = computed(() => {
  if (!status.value) {
    return 'unknown'
  }
  if (status.value.lastSyncResult === 'success') {
    return status.value.localDirty ? 'dirty' : 'ok'
  }
  if (status.value.lastSyncResult) {
    return 'warn'
  }
  return 'unknown'
})

const statusPillLabel = computed(() => {
  switch (statusPillKind.value) {
    case 'ok':
      return '已同步'
    case 'dirty':
      return '有未推送变更'
    case 'warn':
      return '上次同步异常'
    default:
      return '尚未同步'
  }
})

const outcomeKind = computed(() => {
  if (!outcome.value) {
    return 'info'
  }
  switch (outcome.value.action) {
    case 'pushed':
    case 'pulled':
    case 'up_to_date':
      return 'success'
    case 'conflict_recovered':
      return 'warn'
    default:
      return 'error'
  }
})

const outcomeMessage = computed(() => {
  if (!outcome.value) {
    return ''
  }
  const base = outcome.value.message
  if (outcome.value.recoveryPath) {
    return `${base}（已生成恢复副本：${outcome.value.recoveryPath}）`
  }
  return base
})

const saveCheckKind = computed(() => {
  if (!saveCheck.value) {
    return 'info'
  }
  switch (saveCheck.value.status) {
    case 'ok':
      return 'success'
    case 'conflict':
      return 'warn'
    default:
      return 'error'
  }
})

const rebuildKind = computed(() => {
  if (!rebuildMessage.value) {
    return 'info'
  }
  return rebuildMessage.value.includes('失败') ? 'error' : 'success'
})

onMounted(() => {
  loadAll()
})

async function loadAll() {
  error.value = ''
  await Promise.all([loadStatus(), loadConfig(), loadReminderSettings()])
}

async function loadStatus() {
  isLoadingStatus.value = true
  try {
    status.value = await getSyncStatus()
  } catch (err) {
    error.value = `读取同步状态失败：${formatError(err)}`
  } finally {
    isLoadingStatus.value = false
  }
}

async function loadConfig() {
  try {
    const settings = await getSettings()
    const map = new Map(settings.items.map((item) => [item.key, item.valueJson] as const))
    form.webdavUrl = decodeSettingValue(map.get('sync.webdavUrl')) ?? ''
    form.webdavUser = decodeSettingValue(map.get('sync.webdavUser')) ?? ''
    form.webdavPassword = decodeSettingValue(map.get('sync.webdavPassword')) ?? ''
  } catch (err) {
    error.value = `读取 WebDAV 配置失败：${formatError(err)}`
  }
}

async function handleSaveConfig() {
  isSavingConfig.value = true
  error.value = ''
  try {
    const tasks: Promise<unknown>[] = [
      setSetting({ key: 'sync.webdavUrl', valueJson: encodeSettingValue(form.webdavUrl || null) }),
      setSetting({ key: 'sync.webdavUser', valueJson: encodeSettingValue(form.webdavUser || null) }),
      setSetting({
        key: 'sync.webdavPassword',
        valueJson: encodeSettingValue(form.webdavPassword || null),
      }),
    ]
    await Promise.all(tasks)
    outcome.value = {
      action: 'up_to_date',
      message: 'WebDAV 配置已保存。',
      recoveryPath: null,
    }
  } catch (err) {
    error.value = `保存配置失败：${formatError(err)}`
  } finally {
    isSavingConfig.value = false
  }
}

async function handleClearConfig() {
  isSavingConfig.value = true
  error.value = ''
  try {
    await Promise.all([
      deleteSetting('sync.webdavUrl'),
      deleteSetting('sync.webdavUser'),
      deleteSetting('sync.webdavPassword'),
    ])
    form.webdavUrl = ''
    form.webdavUser = ''
    form.webdavPassword = ''
    outcome.value = {
      action: 'up_to_date',
      message: '已清除 WebDAV 配置。',
      recoveryPath: null,
    }
  } catch (err) {
    error.value = `清除配置失败：${formatError(err)}`
  } finally {
    isSavingConfig.value = false
  }
}

async function handleRunSync() {
  isSyncing.value = true
  error.value = ''
  outcome.value = null
  try {
    outcome.value = await runSync()
    await loadStatus()
  } catch (err) {
    outcome.value = {
      action: 'error',
      message: `同步失败：${formatError(err)}`,
      recoveryPath: null,
    }
  } finally {
    isSyncing.value = false
  }
}

async function handleMarkDirty() {
  isMarkingDirty.value = true
  error.value = ''
  try {
    await markSyncDirty()
    outcome.value = {
      action: 'up_to_date',
      message: '已将本地标记为脏，下次同步将优先推送本地。',
      recoveryPath: null,
    }
    await loadStatus()
  } catch (err) {
    error.value = `标记脏失败：${formatError(err)}`
  } finally {
    isMarkingDirty.value = false
  }
}

async function handleCheckBeforeSave() {
  isChecking.value = true
  error.value = ''
  saveCheck.value = null
  try {
    saveCheck.value = await checkSyncBeforeSave()
  } catch (err) {
    saveCheck.value = {
      status: 'offline',
      message: `检查失败：${formatError(err)}`,
    }
  } finally {
    isChecking.value = false
  }
}

async function loadReminderSettings() {
  try {
    const settings = await getSettings()
    const map = new Map(settings.items.map((item) => [item.key, item.valueJson] as const))
    const enabled = decodeSettingValue(map.get('reminder.enabled'))
    reminderForm.enabled = enabled === null ? true : enabled === 'true'
    reminderForm.windowHours = parseInt(decodeSettingValue(map.get('reminder.windowHours')) ?? '24', 10) || 24
    reminderForm.intervalMinutes = parseInt(decodeSettingValue(map.get('sync.intervalMinutes')) ?? '15', 10) || 15
  } catch (err) {
    error.value = `读取提醒设置失败：${formatError(err)}`
  }
}

async function handleSaveReminderSettings() {
  isSavingReminder.value = true
  error.value = ''
  try {
    await Promise.all([
      setSetting({
        key: 'reminder.enabled',
        valueJson: encodeSettingValue(reminderForm.enabled ? 'true' : 'false'),
      }),
      setSetting({
        key: 'reminder.windowHours',
        valueJson: encodeSettingValue(String(reminderForm.windowHours)),
      }),
      setSetting({
        key: 'sync.intervalMinutes',
        valueJson: encodeSettingValue(String(reminderForm.intervalMinutes)),
      }),
    ])
    rebuildMessage.value = '提醒设置已保存。'
  } catch (err) {
    rebuildMessage.value = `保存提醒设置失败：${formatError(err)}`
  } finally {
    isSavingReminder.value = false
  }
}

async function handlePreviewReminders() {
  isPreviewing.value = true
  error.value = ''
  try {
    reminderPlan.value = await previewReminders()
  } catch (err) {
    error.value = `提醒预览失败：${formatError(err)}`
  } finally {
    isPreviewing.value = false
  }
}

async function handleRebuildReminders() {
  isRebuilding.value = true
  error.value = ''
  rebuildMessage.value = ''
  try {
    reminderPlan.value = await rebuildReminders()
    const count = reminderPlan.value?.items.length ?? 0
    rebuildMessage.value = `提醒已重建，共 ${count} 条待触发。`
  } catch (err) {
    rebuildMessage.value = `提醒重建失败：${formatError(err)}`
  } finally {
    isRebuilding.value = false
  }
}

function formatTimestamp(value: string | null) {
  if (!value) {
    return '尚无记录'
  }
  return value
}

function formatError(error: unknown) {
  if (error instanceof Error) {
    return error.message
  }
  return String(error)
}

defineExpose({ loadStatus, loadConfig, loadAll, loadReminderSettings })
</script>

<style scoped>
.sync-view {
  display: grid;
  gap: 14px;
}

.view-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.view-eyebrow {
  margin: 0 0 6px;
  color: var(--color-accent);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

h2 {
  margin: 0;
  font-size: 18px;
}

h3 {
  margin: 0;
}

.text-button {
  border: 0;
  background: transparent;
  color: var(--color-accent);
  min-height: 32px;
  padding: 0 12px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}

.text-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.card {
  display: grid;
  gap: 12px;
  padding: 14px;
  border: 1px solid var(--color-border);
  border-radius: 18px;
  background: linear-gradient(180deg, var(--color-surface) 0%, var(--color-surface-muted) 100%);
  box-shadow: var(--shadow-soft);
}

.card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  min-height: 24px;
  padding: 0 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  background: #eef2e5;
  color: #586446;
}

.status-pill--ok {
  background: #dff0e2;
  color: #2b6f3c;
}

.status-pill--dirty {
  background: #f5edda;
  color: #8a6b2a;
}

.status-pill--warn {
  background: #f7e8e3;
  color: #8f4a3f;
}

.status-pill--unknown {
  background: #eef2e5;
  color: #586446;
}

.loading-message,
.inline-message {
  padding: 12px 14px;
  border-radius: 14px;
  font-size: 13px;
  line-height: 1.6;
}

.loading-message {
  border: 1px dashed var(--color-border);
  background: var(--color-surface-raised);
  color: var(--color-text-muted);
}

.inline-message--success {
  background: #e4f4e6;
  color: #285d34;
}

.inline-message--info {
  background: #ebf1e4;
  color: #4b5f39;
}

.inline-message--warn {
  background: #f7ecda;
  color: #8a6b2a;
}

.inline-message--error {
  background: #f7e8e3;
  color: #8f4a3f;
}

.status-grid {
  display: grid;
  gap: 10px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  margin: 0;
}

.status-item {
  display: grid;
  gap: 4px;
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-surface-raised);
}

.status-item--full {
  grid-column: 1 / -1;
}

.status-item dt {
  font-size: 12px;
  font-weight: 700;
  color: var(--color-text-muted);
}

.status-item dd {
  margin: 0;
  font-size: 13px;
  line-height: 1.5;
  word-break: break-all;
}

.status-etag {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 12px;
}

.form-grid {
  display: grid;
  gap: 12px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.field-block {
  display: grid;
  gap: 6px;
}

.field-block--full {
  grid-column: 1 / -1;
}

.field-label {
  font-size: 12px;
  font-weight: 700;
  color: var(--color-text-muted);
  letter-spacing: 0.02em;
}

.text-input {
  width: 100%;
  min-height: 38px;
  padding: 0 12px;
  border: 1px solid var(--color-border);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.92);
  color: var(--color-text);
  font-size: 13px;
}

.text-input:focus {
  outline: 0;
  border-color: var(--color-accent);
}

.text-input:disabled {
  opacity: 0.6;
}

.card-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.action-hint {
  margin: 0;
  font-size: 12px;
  line-height: 1.6;
  color: var(--color-text-muted);
}

.primary-button,
.ghost-button {
  min-height: 38px;
  min-width: 112px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
}

.primary-button:disabled,
.ghost-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.primary-button {
  border: 0;
  background: linear-gradient(180deg, #397b46 0%, #2f6b3b 100%);
  color: #fff;
  box-shadow: 0 10px 20px rgba(47, 107, 59, 0.22);
}

.ghost-button {
  border: 1px solid var(--color-border);
  background: rgba(255, 255, 255, 0.72);
  color: var(--color-text);
}

.field-block--check {
  flex-direction: row;
  align-items: center;
  gap: 8px;
}

.checkbox-input {
  width: 18px;
  height: 18px;
  accent-color: var(--color-accent);
  cursor: pointer;
}

.reminder-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 8px;
}

.reminder-item {
  display: grid;
  grid-template-columns: auto auto 1fr;
  gap: 10px;
  align-items: center;
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-surface-raised);
  font-size: 13px;
}

.reminder-time {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 12px;
  color: var(--color-text-muted);
}

.reminder-kind {
  display: inline-flex;
  align-items: center;
  min-height: 22px;
  padding: 0 8px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
}

.reminder-kind--danger {
  background: #f7e8e3;
  color: #8f4a3f;
}

.reminder-kind--due {
  background: #f5edda;
  color: #8a6b2a;
}

.reminder-title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

@media (max-width: 640px) {
  .status-grid,
  .form-grid {
    grid-template-columns: minmax(0, 1fr);
  }

  .primary-button,
  .ghost-button {
    flex: 1 1 0;
  }
}
</style>
