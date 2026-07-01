import { describe, expect, it, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import SyncView from '../SyncView.vue'

vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}))

import { invoke } from '@tauri-apps/api/core'

function createStatus(overrides: Record<string, unknown> = {}) {
  return {
    remoteEtag: null,
    remoteVersion: null,
    lastSyncAt: null,
    localDirty: false,
    dirtyBaseRemoteEtag: null,
    lastSyncResult: null,
    deviceId: 'device-abc',
    lastRecoveryPath: null,
    lastRecoveryAt: null,
    lastRecoveryReason: null,
    rawItems: [],
    ...overrides,
  }
}

function createSettings(items: Array<{ key: string; value: string | null }> = []) {
  return {
    items: items.map((item) => ({
      key: item.key,
      valueJson: item.value === null ? 'null' : JSON.stringify(item.value),
      updatedAt: '2026-07-01T00:00:00Z',
    })),
  }
}

function mockInvokeByCommand(map: Record<string, unknown>) {
  vi.mocked(invoke).mockImplementation((command: string) => {
    if (command in map) {
      const value = map[command]
      if (value instanceof Error) {
        return Promise.reject(value)
      }
      return Promise.resolve(value)
    }
    return Promise.resolve(undefined)
  })
}

describe('SyncView', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('挂载后读取同步状态与 WebDAV 配置并渲染设备 ID', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus({ deviceId: 'device-xyz', localDirty: true }),
      settings_get: createSettings([
        { key: 'sync.webdavUrl', value: 'https://dav.example.com/todo/' },
        { key: 'sync.webdavUser', value: 'alice' },
      ]),
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    expect(invoke).toHaveBeenCalledWith('sync_status_get')
    expect(invoke).toHaveBeenCalledWith('settings_get')
    expect(wrapper.text()).toContain('device-xyz')
    expect(wrapper.text()).toContain('有未推送变更')
    expect((wrapper.find('input[type="url"]').element as HTMLInputElement).value).toBe(
      'https://dav.example.com/todo/',
    )
    expect((wrapper.find('input[type="text"]').element as HTMLInputElement).value).toBe('alice')
  })

  it('读取同步状态失败时显示错误信息', async () => {
    mockInvokeByCommand({
      sync_status_get: new Error('数据库错误'),
      settings_get: createSettings(),
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    expect(wrapper.text()).toContain('读取同步状态失败')
    expect(wrapper.text()).toContain('数据库错误')
  })

  it('点击保存配置时调用 settings_set 写入三个键', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings(),
      settings_set: { key: 'sync.webdavUrl', valueJson: '"https://x"', updatedAt: 't' },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const inputs = wrapper.findAll('input')
    await inputs[0].setValue('https://x')
    await wrapper.findAll('.config-card .ghost-button')[0].trigger('click')
    await flushPromises()

    const calls = vi.mocked(invoke).mock.calls.filter((c) => c[0] === 'settings_set')
    expect(calls).toHaveLength(3)
    expect(calls[0][1]).toEqual({
      input: { key: 'sync.webdavUrl', valueJson: '"https://x"' },
    })
    expect(calls[1][1]).toEqual({
      input: { key: 'sync.webdavUser', valueJson: 'null' },
    })
    expect(calls[2][1]).toEqual({
      input: { key: 'sync.webdavPassword', valueJson: 'null' },
    })
    expect(wrapper.text()).toContain('WebDAV 配置已保存')
  })

  it('点击立即同步时调用 sync_run 并刷新状态', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus({ deviceId: 'd1' }),
      settings_get: createSettings([{ key: 'sync.webdavUrl', value: 'https://dav' }]),
      sync_run: { action: 'pushed', message: '本地已推送至远端。', recoveryPath: null },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    await wrapper.find('.action-card .primary-button').trigger('click')
    await flushPromises()

    expect(invoke).toHaveBeenCalledWith('sync_run')
    expect(wrapper.text()).toContain('本地已推送至远端')
    // sync_status_get 应被调用两次：初次加载 + 同步后刷新
    const statusCalls = vi.mocked(invoke).mock.calls.filter((c) => c[0] === 'sync_status_get')
    expect(statusCalls.length).toBeGreaterThanOrEqual(2)
  })

  it('同步返回冲突恢复时显示恢复副本路径', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings([{ key: 'sync.webdavUrl', value: 'https://dav' }]),
      sync_run: {
        action: 'conflict_recovered',
        message: '远端有更新，本地脏数据已导出为恢复副本。',
        recoveryPath: '/recovery/recovery-1.sqlite3',
      },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    await wrapper.find('.action-card .primary-button').trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('已生成恢复副本')
    expect(wrapper.text()).toContain('/recovery/recovery-1.sqlite3')
  })

  it('同步失败时显示错误 outcome', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings([{ key: 'sync.webdavUrl', value: 'https://dav' }]),
      sync_run: new Error('网络不通'),
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    await wrapper.find('.action-card .primary-button').trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('同步失败')
    expect(wrapper.text()).toContain('网络不通')
  })

  it('未配置 WebDAV 时立即同步按钮禁用', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings(),
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const syncButton = wrapper.find('.action-card .primary-button')
    expect((syncButton.element as HTMLButtonElement).disabled).toBe(true)
  })

  it('点击标记本地为脏时调用 sync_mark_dirty', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus({ deviceId: 'd1' }),
      settings_get: createSettings(),
      sync_mark_dirty: undefined,
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const buttons = wrapper.findAll('.action-card .ghost-button')
    const markDirtyButton = buttons.find((b) => b.text().includes('标记本地为脏'))
    await markDirtyButton!.trigger('click')
    await flushPromises()

    expect(invoke).toHaveBeenCalledWith('sync_mark_dirty')
    expect(wrapper.text()).toContain('已将本地标记为脏')
  })

  it('点击保存前冲突检查时调用 sync_check_before_save', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings([{ key: 'sync.webdavUrl', value: 'https://dav' }]),
      sync_check_before_save: { status: 'conflict', message: '远端有新版本，建议先同步。' },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const buttons = wrapper.findAll('.action-card .ghost-button')
    const checkButton = buttons.find((b) => b.text().includes('保存前冲突检查'))
    await checkButton!.trigger('click')
    await flushPromises()

    expect(invoke).toHaveBeenCalledWith('sync_check_before_save')
    expect(wrapper.text()).toContain('远端有新版本，建议先同步')
  })

  it('点击清除配置时调用 settings_delete 三个键并清空表单', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings([
        { key: 'sync.webdavUrl', value: 'https://dav' },
        { key: 'sync.webdavUser', value: 'alice' },
      ]),
      settings_delete: undefined,
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const urlInput = wrapper.find('input[type="url"]').element as HTMLInputElement
    expect(urlInput.value).toBe('https://dav')

    const buttons = wrapper.findAll('.config-card .ghost-button')
    const clearButton = buttons.find((b) => b.text().includes('清除已保存配置'))
    await clearButton!.trigger('click')
    await flushPromises()

    const deleteCalls = vi.mocked(invoke).mock.calls.filter((c) => c[0] === 'settings_delete')
    expect(deleteCalls).toHaveLength(3)
    expect((wrapper.find('input[type="url"]').element as HTMLInputElement).value).toBe('')
    expect(wrapper.text()).toContain('已清除 WebDAV 配置')
  })

  it('同步状态为 success 且无脏标记时显示已同步徽标', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus({
        lastSyncResult: 'success',
        localDirty: false,
        lastSyncAt: '2026-07-01T08:00:00Z',
      }),
      settings_get: createSettings(),
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    expect(wrapper.find('.status-pill--ok').exists()).toBe(true)
    expect(wrapper.text()).toContain('已同步')
  })

  it('挂载后读取提醒设置并回填表单', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings([
        { key: 'reminder.enabled', value: 'false' },
        { key: 'reminder.windowHours', value: '48' },
        { key: 'sync.intervalMinutes', value: '30' },
      ]),
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const checkbox = wrapper.find('.reminder-card input[type="checkbox"]').element as HTMLInputElement
    expect(checkbox.checked).toBe(false)
    const numberInputs = wrapper.findAll('.reminder-card input[type="number"]')
    expect((numberInputs[0].element as HTMLInputElement).value).toBe('48')
    expect((numberInputs[1].element as HTMLInputElement).value).toBe('30')
  })

  it('点击保存提醒设置时写入三个键', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings(),
      settings_set: { key: 'reminder.enabled', valueJson: '"true"', updatedAt: 't' },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const saveButton = wrapper.findAll('.reminder-card .ghost-button').find((b) =>
      b.text().includes('保存提醒设置'),
    )
    await saveButton!.trigger('click')
    await flushPromises()

    const calls = vi.mocked(invoke).mock.calls.filter((c) => c[0] === 'settings_set')
    expect(calls).toHaveLength(3)
    expect(calls[0][1]).toEqual({
      input: { key: 'reminder.enabled', valueJson: '"true"' },
    })
    expect(calls[1][1]).toEqual({
      input: { key: 'reminder.windowHours', valueJson: '"24"' },
    })
    expect(calls[2][1]).toEqual({
      input: { key: 'sync.intervalMinutes', valueJson: '"15"' },
    })
    expect(wrapper.text()).toContain('提醒设置已保存')
  })

  it('点击刷新预览时调用 reminder_preview 并渲染提醒列表', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings(),
      reminder_preview: {
        items: [
          {
            seriesId: 's1',
            occurrenceKey: '2026-07-02',
            title: '整理周报',
            triggerAt: '2026-07-02T09:00:00',
            kind: 'danger',
            payload: '周五前',
          },
          {
            seriesId: 's2',
            occurrenceKey: '2026-07-02',
            title: '提交日报',
            triggerAt: '2026-07-02T10:00:00',
            kind: 'due',
            payload: null,
          },
        ],
        windowStart: '2026-07-01T10:00:00',
        windowEnd: '2026-07-02T10:00:00',
      },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const refreshButton = wrapper.findAll('.preview-card .text-button').find((b) =>
      b.text().includes('刷新预览'),
    )
    await refreshButton!.trigger('click')
    await flushPromises()

    expect(invoke).toHaveBeenCalledWith('reminder_preview', { windowHours: undefined })
    expect(wrapper.findAll('.reminder-item')).toHaveLength(2)
    expect(wrapper.text()).toContain('整理周报')
    expect(wrapper.text()).toContain('提交日报')
    expect(wrapper.find('.reminder-kind--danger').exists()).toBe(true)
    expect(wrapper.find('.reminder-kind--due').exists()).toBe(true)
  })

  it('点击立即重建提醒时调用 reminder_rebuild 并显示结果', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings(),
      reminder_rebuild: {
        items: [
          {
            seriesId: 's1',
            occurrenceKey: '2026-07-02',
            title: '整理周报',
            triggerAt: '2026-07-02T09:00:00',
            kind: 'danger',
            payload: null,
          },
        ],
        windowStart: '2026-07-01T10:00:00',
        windowEnd: '2026-07-02T10:00:00',
      },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const rebuildButton = wrapper.find('.preview-card .primary-button')
    await rebuildButton.trigger('click')
    await flushPromises()

    expect(invoke).toHaveBeenCalledWith('reminder_rebuild')
    expect(wrapper.text()).toContain('提醒已重建，共 1 条待触发')
  })

  it('提醒预览返回空列表时显示无提醒提示', async () => {
    mockInvokeByCommand({
      sync_status_get: createStatus(),
      settings_get: createSettings(),
      reminder_preview: { items: [], windowStart: '2026-07-01T10:00:00', windowEnd: '2026-07-02T10:00:00' },
    })

    const wrapper = mount(SyncView)
    await flushPromises()

    const refreshButton = wrapper.findAll('.preview-card .text-button').find((b) =>
      b.text().includes('刷新预览'),
    )
    await refreshButton!.trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('近期无待触发提醒')
  })
})
