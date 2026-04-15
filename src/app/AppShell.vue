<template>
  <NConfigProvider :locale="zhCN" :date-locale="dateZhCN">
    <main class="shell">
      <header class="page-header">
        <div class="header-copy">
          <p class="eyebrow">阶段 3 / 任务基础能力</p>
          <h1>任务编辑</h1>
          <p class="summary">
            可查看未来 {{ upcomingDayCount }} 天任务，并创建或编辑任务。
          </p>
        </div>

        <div class="header-actions">
          <button class="ghost-button" type="button" @click="handleCreateNew">
            新建任务
          </button>
          <button
            class="primary-button"
            type="button"
            :disabled="isSaving || isEditorLoading"
            @click="handleSave"
          >
            {{ saveButtonLabel }}
          </button>
        </div>
      </header>

      <div
        v-if="feedback"
        class="feedback-banner"
        :class="`feedback-banner--${feedback.type}`"
      >
        {{ feedback.text }}
      </div>

      <section class="workspace">
        <aside class="list-pane">
          <div class="pane-header">
            <div>
              <p class="pane-eyebrow">近期任务</p>
              <h2>未来 {{ upcomingDayCount }} 天</h2>
            </div>
            <button class="text-button" type="button" :disabled="isListLoading" @click="loadUpcomingTasks">
              {{ isListLoading ? '刷新中' : '刷新' }}
            </button>
          </div>

          <div v-if="listError" class="inline-message inline-message--error">
            {{ listError }}
          </div>

          <div v-if="isListLoading" class="task-list-empty">正在加载近期任务…</div>
          <div v-else-if="upcomingTasks.length === 0" class="task-list-empty">
            未来 {{ upcomingDayCount }} 天还没有任务，可以直接在右侧创建。
          </div>
          <div v-else class="task-list">
            <button
              v-for="task in upcomingTasks"
              :key="task.seriesId"
              class="task-card"
              :class="{ 'task-card--active': task.seriesId === selectedSeriesId }"
              type="button"
              @click="handleSelectTask(task.seriesId)"
            >
              <div class="task-card-main">
                <div class="task-card-head">
                  <span class="task-title">{{ task.title }}</span>
                  <span class="status-chip" :class="`status-chip--${task.status}`">
                    {{ statusLabels[task.status] }}
                  </span>
                </div>
                <p v-if="task.note" class="task-note">{{ task.note }}</p>
                <div class="task-meta">
                  <span>{{ formatDueMeta(task) }}</span>
                  <span v-if="task.priority !== null">优先级 {{ task.priority }}</span>
                </div>
              </div>

              <div class="task-card-foot">
                <span
                  v-if="task.tagId && tagsById.get(task.tagId)"
                  class="tag-pill"
                  :style="buildTagStyle(task.tagId)"
                >
                  {{ tagsById.get(task.tagId)?.name }}
                </span>
                <span v-else class="task-meta-muted">未分配标签</span>
              </div>
            </button>
          </div>
        </aside>

        <section class="editor-pane">
          <section v-if="selectedSeriesId || isDetailLoading || detailError" class="detail-panel">
            <div class="pane-header">
              <div>
                <p class="pane-eyebrow">任务详情</p>
                <h2>
                  {{ isDetailLoading ? '正在加载…' : selectedTaskDetail?.title ?? '任务详情' }}
                </h2>
              </div>

              <span
                v-if="selectedTaskDetail"
                class="status-chip"
                :class="`status-chip--${selectedTaskDetail.status}`"
              >
                {{ statusLabels[selectedTaskDetail.status] }}
              </span>
            </div>

            <div v-if="detailError" class="inline-message inline-message--error">
              {{ detailError }}
            </div>

            <div v-else-if="isDetailLoading" class="task-list-empty">
              正在读取任务详情…
            </div>

            <template v-else-if="selectedTaskDetail">
              <p v-if="selectedTaskDetail.note" class="detail-note">
                {{ selectedTaskDetail.note }}
              </p>

              <div class="detail-grid">
                <div class="detail-item">
                  <span class="detail-label">开始</span>
                  <span class="detail-value">{{ formatStartMeta(selectedTaskDetail) }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">截止</span>
                  <span class="detail-value">{{ formatDeadlineMeta(selectedTaskDetail) }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">标签</span>
                  <span class="detail-value">
                    {{ selectedTaskDetail.tagId ? tagsById.get(selectedTaskDetail.tagId)?.name ?? '未知标签' : '无标签' }}
                  </span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">优先级</span>
                  <span class="detail-value">{{ formatPriorityLabel(selectedTaskDetail.priority) }}</span>
                </div>
              </div>

              <div class="detail-actions">
                <button
                  class="ghost-button"
                  type="button"
                  :disabled="isEditorLoading || isStatusSaving || isDeleting"
                  @click="handleEditSelectedTask"
                >
                  加载到编辑表单
                </button>
                <button
                  v-if="selectedTaskDetail.status !== 'completed'"
                  class="secondary-button"
                  type="button"
                  :disabled="isStatusSaving || isDeleting"
                  @click="handleSetStatus('completed')"
                >
                  标记完成
                </button>
                <button
                  v-if="selectedTaskDetail.status !== 'cancelled'"
                  class="ghost-button"
                  type="button"
                  :disabled="isStatusSaving || isDeleting"
                  @click="handleSetStatus('cancelled')"
                >
                  标记取消
                </button>
                <button
                  v-if="selectedTaskDetail.status !== 'pending'"
                  class="ghost-button"
                  type="button"
                  :disabled="isStatusSaving || isDeleting"
                  @click="handleSetStatus('pending')"
                >
                  恢复未完成
                </button>
                <button
                  class="danger-button"
                  type="button"
                  :disabled="isStatusSaving || isDeleting"
                  @click="handleDeleteSelectedTask"
                >
                  {{ isDeleting ? '删除中…' : '删除任务' }}
                </button>
              </div>
            </template>
          </section>

          <div class="pane-header">
            <div>
              <p class="pane-eyebrow">编辑表单</p>
              <h2>{{ isEditing ? '编辑任务' : '创建任务' }}</h2>
            </div>
            <span v-if="isEditing" class="status-chip" :class="`status-chip--${form.currentStatus}`">
              {{ statusLabels[form.currentStatus] }}
            </span>
          </div>

          <div v-if="editorError" class="inline-message inline-message--error">
            {{ editorError }}
          </div>

          <form class="editor-form" @submit.prevent="handleSave">
            <div class="field-grid field-grid--single">
              <label class="field-block">
                <span class="field-label">标题</span>
                <NInput
                  v-model:value="form.title"
                  class="form-control"
                  maxlength="120"
                  placeholder="例如：整理周报"
                />
                <span v-if="validationErrors.title" class="field-error">
                  {{ validationErrors.title }}
                </span>
              </label>
            </div>

            <div class="field-grid">
              <label class="field-block">
                <span class="field-label">标签</span>
                <NSelect
                  v-model:value="form.tagId"
                  class="form-control"
                  clearable
                  :consistent-menu-width="false"
                  :options="tagOptions"
                  placeholder="无标签"
                />
              </label>

              <label class="field-block">
                <span class="field-label">优先级</span>
                <NSelect
                  v-model:value="form.priority"
                  class="form-control"
                  clearable
                  :consistent-menu-width="false"
                  :options="priorityOptions"
                  placeholder="默认"
                />
              </label>
            </div>

            <label class="field-block">
              <span class="field-label">备注</span>
              <NInput
                v-model:value="form.note"
                class="form-control"
                type="textarea"
                :autosize="{ minRows: 4, maxRows: 8 }"
                placeholder="记录需要补充的上下文、限制条件或备注。"
              />
            </label>

            <div class="toggle-row">
              <div class="toggle-control">
                <NSwitch v-model:value="form.allDay" size="small" />
                <span>全天任务</span>
              </div>
            </div>

            <div class="schedule-card">
              <div class="schedule-head">
                <h3>开始信息</h3>
              </div>

              <div class="field-grid">
                <label class="field-block">
                  <span class="field-label">开始日期</span>
                  <NDatePicker
                    :formatted-value="form.startDate"
                    class="form-control"
                    clearable
                    type="date"
                    value-format="yyyy-MM-dd"
                    @update:formatted-value="handleStartDateChange"
                  />
                  <span v-if="validationErrors.startDate" class="field-error">
                    {{ validationErrors.startDate }}
                  </span>
                </label>

                <label class="field-block">
                  <span class="field-label">开始时间</span>
                  <NTimePicker
                    :disabled="form.allDay"
                    :formatted-value="form.startTime"
                    class="form-control"
                    clearable
                    format="HH:mm"
                    value-format="HH:mm"
                    @update:formatted-value="handleStartTimeChange"
                  />
                  <span v-if="validationErrors.startTime" class="field-error">
                    {{ validationErrors.startTime }}
                  </span>
                </label>
              </div>
            </div>

            <div class="schedule-card">
              <div class="schedule-head">
                <h3>截止信息</h3>
              </div>

              <div class="field-grid">
                <label class="field-block">
                  <span class="field-label">截止日期</span>
                  <NDatePicker
                    :formatted-value="form.dueDate"
                    class="form-control"
                    type="date"
                    value-format="yyyy-MM-dd"
                    @update:formatted-value="handleDueDateChange"
                  />
                  <span v-if="validationErrors.dueDate" class="field-error">
                    {{ validationErrors.dueDate }}
                  </span>
                </label>

                <label class="field-block">
                  <span class="field-label">截止时间</span>
                  <NTimePicker
                    :disabled="form.allDay"
                    :formatted-value="form.dueTime"
                    class="form-control"
                    clearable
                    format="HH:mm"
                    value-format="HH:mm"
                    @update:formatted-value="handleDueTimeChange"
                  />
                  <span v-if="validationErrors.dueTime" class="field-error">
                    {{ validationErrors.dueTime }}
                  </span>
                </label>
              </div>
            </div>

            <div v-if="validationErrors.range || formError" class="inline-message inline-message--error">
              <span v-if="validationErrors.range">{{ validationErrors.range }}</span>
              <span v-else>{{ formError }}</span>
            </div>

            <div v-else-if="formError" class="inline-message inline-message--error">
              {{ formError }}
            </div>

            <div class="form-actions">
              <button class="ghost-button" type="button" @click="handleCreateNew">
                重置为新建
              </button>
              <button
                class="primary-button"
                type="submit"
                :disabled="isSaving || isEditorLoading || hasBlockingValidation"
              >
                {{ saveButtonLabel }}
              </button>
            </div>
          </form>
        </section>
      </section>
    </main>
  </NConfigProvider>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import {
  dateZhCN,
  NConfigProvider,
  NDatePicker,
  NInput,
  NSelect,
  NSwitch,
  NTimePicker,
  zhCN,
} from 'naive-ui'
import {
  createTask,
  deleteTask,
  getTaskDetail,
  getTaskEditor,
  listTags,
  queryUpcomingTasks,
  setTaskStatus,
  updateTask,
  type TagDto,
  type TaskDetailDto,
  type TaskEditorDto,
  type TaskListItemDto,
  type TaskSaveInput,
  type TaskStatus,
} from '../features/tasks/task-api'

const upcomingDayCount = 31

const priorityOptions = [
  { value: '1', label: '1 · 最高' },
  { value: '2', label: '2 · 较高' },
  { value: '3', label: '3 · 标准' },
  { value: '4', label: '4 · 较低' },
  { value: '5', label: '5 · 最低' },
]

const statusLabels: Record<TaskStatus, string> = {
  pending: '未完成',
  completed: '已完成',
  cancelled: '已取消',
}

type FeedbackType = 'success' | 'info' | 'error'

interface FeedbackState {
  type: FeedbackType
  text: string
}

interface TaskFormState {
  seriesId: string | null
  title: string
  note: string
  tagId: string | null
  priority: string | null
  allDay: boolean
  startDate: string | null
  startTime: string | null
  dueDate: string
  dueTime: string | null
  currentStatus: TaskStatus
}

interface FormValidationErrors {
  title: string
  startDate: string
  startTime: string
  dueDate: string
  dueTime: string
  range: string
}

const tags = ref<TagDto[]>([])
const upcomingTasks = ref<TaskListItemDto[]>([])
const selectedSeriesId = ref<string | null>(null)
const selectedTaskDetail = ref<TaskDetailDto | null>(null)

const isListLoading = ref(false)
const isDetailLoading = ref(false)
const isEditorLoading = ref(false)
const isSaving = ref(false)
const isStatusSaving = ref(false)
const isDeleting = ref(false)

const listError = ref('')
const detailError = ref('')
const editorError = ref('')
const formError = ref('')
const feedback = ref<FeedbackState | null>(null)

const form = reactive<TaskFormState>(createEmptyForm())

const isEditing = computed(() => Boolean(form.seriesId))
const saveButtonLabel = computed(() => {
  if (isSaving.value) {
    return isEditing.value ? '保存中…' : '创建中…'
  }
  return isEditing.value ? '保存修改' : '创建任务'
})

const tagOptions = computed(() =>
  sortedTags.value.map((tag) => ({
    label: tag.name,
    value: tag.id,
  })),
)

const validationErrors = computed<FormValidationErrors>(() => validateFormFields())
const hasBlockingValidation = computed(() =>
  Boolean(
    validationErrors.value.title ||
      validationErrors.value.startDate ||
      validationErrors.value.startTime ||
      validationErrors.value.dueDate ||
      validationErrors.value.dueTime ||
      validationErrors.value.range,
  ),
)

const sortedTags = computed(() =>
  [...tags.value].sort((left, right) => {
    if (left.sortOrder !== right.sortOrder) {
      return left.sortOrder - right.sortOrder
    }
    return left.name.localeCompare(right.name, 'zh-CN')
  }),
)

const tagsById = computed(() => {
  return new Map(tags.value.map((tag) => [tag.id, tag] as const))
})

watch(
  () => form.allDay,
  (value) => {
    if (value) {
      form.startTime = ''
      form.dueTime = ''
    }
  },
)

watch(
  () => form.startDate,
  (value) => {
    if (!value) {
      form.startTime = null
    }
  },
)

onMounted(async () => {
  await Promise.all([loadTags(), loadUpcomingTasks(false)])
})

async function loadTags() {
  try {
    tags.value = await listTags()
  } catch (error) {
    editorError.value = `加载标签失败：${formatError(error)}`
  }
}

async function loadUpcomingTasks(preserveSelection = true) {
  isListLoading.value = true
  listError.value = ''

  try {
    const tasks = await queryUpcomingTasks({ dayCount: upcomingDayCount })
    upcomingTasks.value = tasks

    if (!preserveSelection) {
      return
    }

    if (selectedSeriesId.value && !tasks.some((task) => task.seriesId === selectedSeriesId.value)) {
      const removedSeriesId = selectedSeriesId.value
      selectedSeriesId.value = null
      selectedTaskDetail.value = null

      if (form.seriesId === removedSeriesId) {
        Object.assign(form, createEmptyForm())
      }
    }
  } catch (error) {
    listError.value = `加载近期任务失败：${formatError(error)}`
  } finally {
    isListLoading.value = false
  }
}

async function handleSelectTask(seriesId: string) {
  if (seriesId === selectedSeriesId.value && selectedTaskDetail.value) {
    return
  }

  selectedSeriesId.value = seriesId
  selectedTaskDetail.value = null
  detailError.value = ''
  editorError.value = ''
  formError.value = ''
  isDetailLoading.value = true

  try {
    const detail = await getTaskDetail(seriesId)
    if (!detail) {
      throw new Error('任务不存在，可能已被删除。')
    }

    selectedTaskDetail.value = detail
    feedback.value = {
      type: 'info',
      text: `已选中任务“${detail.title}”。`,
    }
  } catch (error) {
    selectedSeriesId.value = null
    selectedTaskDetail.value = null
    detailError.value = `读取任务详情失败：${formatError(error)}`
  } finally {
    isDetailLoading.value = false
  }
}

async function handleEditSelectedTask() {
  const seriesId = selectedSeriesId.value
  if (!seriesId) {
    return
  }

  isEditorLoading.value = true
  formError.value = ''
  editorError.value = ''

  try {
    const editor = await getTaskEditor(seriesId)
    if (!editor) {
      throw new Error('任务不存在，可能已被删除。')
    }

    applyTaskToForm(editor)
    feedback.value = {
      type: 'info',
      text: `已载入任务“${editor.title}”的编辑态。`,
    }
  } catch (error) {
    selectedSeriesId.value = null
    Object.assign(form, createEmptyForm())
    editorError.value = `读取任务编辑态失败：${formatError(error)}`
  } finally {
    isEditorLoading.value = false
  }
}

function handleCreateNew() {
  selectedSeriesId.value = null
  selectedTaskDetail.value = null
  detailError.value = ''
  editorError.value = ''
  formError.value = ''
  feedback.value = {
    type: 'info',
    text: '已切换为新建任务模式。',
  }
  Object.assign(form, createEmptyForm())
}

async function handleSave() {
  formError.value = ''
  detailError.value = ''
  editorError.value = ''

  const validationError = validateForm()
  if (validationError) {
    formError.value = validationError
    return
  }

  isSaving.value = true
  const editing = Boolean(form.seriesId)

  try {
    const payload = buildSaveInput()
    const saved = editing
      ? await updateTask({
          seriesId: form.seriesId as string,
          ...payload,
        })
      : await createTask(payload)

    applyTaskToForm(saved)
    selectedSeriesId.value = saved.seriesId
    selectedTaskDetail.value = saved
    feedback.value = {
      type: 'success',
      text: editing ? '任务修改已保存。' : '任务已创建，可继续补充或调整。',
    }
    await loadUpcomingTasks()
  } catch (error) {
    formError.value = `保存失败：${formatError(error)}`
  } finally {
    isSaving.value = false
  }
}

async function handleSetStatus(status: TaskStatus) {
  const seriesId = selectedSeriesId.value
  if (!seriesId) {
    return
  }

  isStatusSaving.value = true
  detailError.value = ''

  try {
    const detail = await setTaskStatus({ seriesId, status })
    selectedTaskDetail.value = detail

    if (form.seriesId === detail.seriesId) {
      form.currentStatus = detail.status
    }

    feedback.value = {
      type: 'success',
      text: `任务状态已更新为${statusLabels[detail.status]}。`,
    }
    await loadUpcomingTasks()
  } catch (error) {
    detailError.value = `更新任务状态失败：${formatError(error)}`
  } finally {
    isStatusSaving.value = false
  }
}

async function handleDeleteSelectedTask() {
  const seriesId = selectedSeriesId.value
  const title = selectedTaskDetail.value?.title ?? '当前任务'
  if (!seriesId) {
    return
  }

  const confirmed = window.confirm(`确认删除“${title}”？此操作不能撤销。`)
  if (!confirmed) {
    return
  }

  isDeleting.value = true
  detailError.value = ''

  try {
    await deleteTask(seriesId)
    if (form.seriesId === seriesId) {
      Object.assign(form, createEmptyForm())
    }

    selectedSeriesId.value = null
    selectedTaskDetail.value = null
    feedback.value = {
      type: 'success',
      text: '任务已删除。',
    }
    await loadUpcomingTasks()
  } catch (error) {
    detailError.value = `删除任务失败：${formatError(error)}`
  } finally {
    isDeleting.value = false
  }
}

function createEmptyForm(): TaskFormState {
  return {
    seriesId: null,
    title: '',
    note: '',
    tagId: null,
    priority: null,
    allDay: false,
    startDate: null,
    startTime: null,
    dueDate: todayString(),
    dueTime: null,
    currentStatus: 'pending',
  }
}

function applyTaskToForm(task: TaskEditorDto | TaskDetailDto) {
  form.seriesId = task.seriesId
  form.title = task.title
  form.note = task.note ?? ''
  form.tagId = task.tagId
  form.priority = task.priority === null ? null : String(task.priority)
  form.allDay = task.allDay
  form.startDate = task.startDate
  form.startTime = task.startTime
  form.dueDate = task.dueDate
  form.dueTime = task.dueTime
  form.currentStatus = 'currentStatus' in task ? task.currentStatus : task.status
}

function buildSaveInput(): TaskSaveInput {
  return {
    title: form.title.trim(),
    note: normalizeOptionalText(form.note),
    tagId: form.tagId,
    priority: normalizePriority(form.priority),
    allDay: form.allDay,
    startDate: form.startDate,
    startTime: form.allDay ? null : form.startTime,
    dueDate: form.dueDate,
    dueTime: form.allDay ? null : form.dueTime,
  }
}

function validateForm() {
  const errors = validationErrors.value
  if (errors.title) {
    return errors.title
  }
  if (errors.startDate) {
    return errors.startDate
  }
  if (errors.startTime) {
    return errors.startTime
  }
  if (errors.dueDate) {
    return errors.dueDate
  }
  if (errors.dueTime) {
    return errors.dueTime
  }
  if (errors.range) {
    return errors.range
  }
  return ''
}

function validateFormFields(): FormValidationErrors {
  const errors: FormValidationErrors = {
    title: '',
    startDate: '',
    startTime: '',
    dueDate: '',
    dueTime: '',
    range: '',
  }

  if (!form.title.trim()) {
    errors.title = '标题不能为空。'
  }

  if (!form.dueDate) {
    errors.dueDate = '请至少填写截止日期。'
  }

  if (!form.allDay && !form.dueTime) {
    errors.dueTime = '非全天任务必须填写截止时间。'
  }

  if (form.startTime && !form.startDate) {
    errors.startDate = '填写开始时间时必须同时填写开始日期。'
  }

  const startStamp = buildDateTimeStamp(form.startDate, form.startTime, form.allDay)
  const dueStamp = buildDateTimeStamp(form.dueDate, form.dueTime, form.allDay)
  if (startStamp !== null && dueStamp !== null && startStamp > dueStamp) {
    errors.range = '开始时间不能晚于截止时间。'
  }

  return errors
}

function handleStartDateChange(value: string | null) {
  form.startDate = value
  formError.value = ''
}

function handleStartTimeChange(value: string | null) {
  form.startTime = value
  formError.value = ''
}

function handleDueDateChange(value: string | null) {
  form.dueDate = value ?? todayString()
  formError.value = ''
}

function handleDueTimeChange(value: string | null) {
  form.dueTime = value
  formError.value = ''
}

function formatDueMeta(task: TaskListItemDto) {
  const parts = [formatDateLabel(task.dueDate)]

  if (task.allDay) {
    parts.push('全天')
  } else if (task.dueTime) {
    parts.push(task.dueTime)
  }

  return parts.join(' · ')
}

function formatStartMeta(task: TaskDetailDto) {
  if (!task.startDate) {
    return '未设置'
  }

  const parts = [formatDateLabel(task.startDate)]
  if (task.allDay) {
    parts.push('全天')
  } else if (task.startTime) {
    parts.push(task.startTime)
  }
  return parts.join(' · ')
}

function formatDeadlineMeta(task: TaskDetailDto) {
  const parts = [formatDateLabel(task.dueDate)]
  if (task.allDay) {
    parts.push('全天')
  } else if (task.dueTime) {
    parts.push(task.dueTime)
  }
  return parts.join(' · ')
}

function formatPriorityLabel(priority: number | null) {
  if (priority === null) {
    return '默认'
  }

  return `优先级 ${priority}`
}

function formatDateLabel(value: string) {
  const [year, month, day] = value.split('-').map((part) => Number(part))
  const date = new Date(year, month - 1, day)
  return new Intl.DateTimeFormat('zh-CN', {
    month: 'numeric',
    day: 'numeric',
    weekday: 'short',
  }).format(date)
}

function buildTagStyle(tagId: string) {
  const tag = tagsById.value.get(tagId)
  const colorValue = tag?.colorValue

  if (!colorValue) {
    return undefined
  }

  return {
    borderColor: `${colorValue}55`,
    backgroundColor: `${colorValue}18`,
    color: colorValue,
  }
}

function normalizeOptionalText(value: string | null) {
  if (value === null) {
    return null
  }

  const trimmed = value.trim()
  return trimmed ? trimmed : null
}

function normalizePriority(value: string | null) {
  if (!value) {
    return null
  }

  return Number.parseInt(value, 10)
}

function buildDateTimeStamp(dateValue: string | null, timeValue: string | null, allDay: boolean) {
  if (!dateValue) {
    return null
  }

  const effectiveTime = allDay ? '00:00' : timeValue ?? '00:00'
  return new Date(`${dateValue}T${effectiveTime}:00`).getTime()
}

function formatError(error: unknown) {
  if (error instanceof Error) {
    return error.message
  }

  if (error && typeof error === 'object') {
    const maybeMessage = Reflect.get(error, 'message')
    if (typeof maybeMessage === 'string' && maybeMessage.trim()) {
      return maybeMessage
    }

    const maybeCode = Reflect.get(error, 'code')
    if (typeof maybeCode === 'string') {
      return maybeCode
    }
  }

  return String(error)
}

function todayString() {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}
</script>

<style scoped>
.shell {
  max-width: 1320px;
  margin: 0 auto;
  min-height: 100vh;
  min-height: 100dvh;
  padding-top: calc(14px + env(safe-area-inset-top, 0px));
  padding-right: calc(16px + env(safe-area-inset-right, 0px));
  padding-bottom: calc(20px + env(safe-area-inset-bottom, 0px));
  padding-left: calc(16px + env(safe-area-inset-left, 0px));
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 14px;
}

.header-copy {
  max-width: 760px;
}

.eyebrow,
.pane-eyebrow {
  margin: 0 0 8px;
  color: var(--color-accent);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  font-size: clamp(26px, 2.6vw, 36px);
  line-height: 1.08;
}

h2,
h3 {
  margin: 0;
}

.summary,
.task-note,
.task-meta,
.task-meta-muted {
  color: var(--color-text-muted);
}

.summary {
  margin: 8px 0 0;
  line-height: 1.55;
}

.header-actions,
.form-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.workspace {
  display: grid;
  grid-template-columns: minmax(240px, 304px) minmax(0, 1fr);
  gap: 14px;
  align-items: start;
}

.list-pane,
.editor-pane {
  border: 1px solid var(--color-border);
  border-radius: 20px;
  background: linear-gradient(180deg, var(--color-surface) 0%, var(--color-surface-muted) 100%);
  box-shadow: var(--shadow-soft);
}

.list-pane {
  padding: 14px;
}

.editor-pane {
  padding: 16px;
}

.detail-panel {
  display: grid;
  gap: 12px;
  margin-bottom: 14px;
  padding: 14px;
  border: 1px solid var(--color-border);
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.82);
}

.pane-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.task-list {
  display: grid;
  gap: 8px;
  margin-top: 14px;
}

.detail-note {
  margin: 0;
  font-size: 13px;
  line-height: 1.6;
  color: var(--color-text-muted);
}

.detail-grid {
  display: grid;
  gap: 10px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.detail-item {
  display: grid;
  gap: 4px;
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-surface-raised);
}

.detail-label {
  font-size: 12px;
  font-weight: 700;
  color: var(--color-text-muted);
}

.detail-value {
  font-size: 13px;
  line-height: 1.5;
}

.detail-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.task-list-empty {
  margin-top: 14px;
  padding: 14px 12px;
  border: 1px dashed var(--color-border);
  border-radius: 16px;
  background: var(--color-surface-raised);
  color: var(--color-text-muted);
  font-size: 13px;
  line-height: 1.6;
}

.task-card {
  width: 100%;
  padding: 12px;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  background: var(--color-surface-raised);
  color: inherit;
  text-align: left;
  cursor: pointer;
  transition:
    border-color 160ms ease,
    transform 160ms ease,
    box-shadow 160ms ease;
}

.task-card:hover {
  border-color: var(--color-border-strong);
  transform: translateY(-1px);
  box-shadow: 0 10px 22px rgba(23, 33, 15, 0.08);
}

.task-card--active {
  border-color: color-mix(in srgb, var(--color-accent) 55%, white);
  background: linear-gradient(180deg, #ffffff 0%, #eef5ee 100%);
  box-shadow: 0 14px 28px rgba(38, 88, 49, 0.12);
}

.task-card-main {
  display: grid;
  gap: 6px;
}

.task-card-head,
.task-card-foot,
.toggle-row,
.schedule-head {
  display: flex;
  justify-content: space-between;
  gap: 10px;
}

.task-card-head {
  align-items: center;
}

.task-card-foot,
.toggle-row {
  margin-top: 10px;
  align-items: center;
  flex-wrap: wrap;
}

.task-title {
  font-size: 14px;
  font-weight: 700;
  line-height: 1.4;
}

.task-note {
  margin: 0;
  font-size: 13px;
  line-height: 1.55;
}

.task-meta {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  font-size: 12px;
}

.status-chip,
.tag-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 24px;
  padding: 0 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}

.status-chip--pending {
  background: #eef2e5;
  color: #586446;
}

.status-chip--completed {
  background: #dff0e2;
  color: #2b6f3c;
}

.status-chip--cancelled {
  background: #f5e5e1;
  color: #995045;
}

.tag-pill {
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  color: var(--color-text);
}

.editor-form {
  display: grid;
  gap: 12px;
  margin-top: 14px;
}

.field-grid {
  display: grid;
  gap: 12px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.field-grid--single {
  grid-template-columns: minmax(0, 1fr);
}

.field-block {
  display: grid;
  gap: 6px;
}

.field-label {
  font-size: 12px;
  font-weight: 700;
  color: var(--color-text-muted);
  letter-spacing: 0.02em;
}

.field-error {
  font-size: 12px;
  color: #8f4a3f;
  line-height: 1.45;
}

.form-control {
  width: 100%;
}

:deep(.form-control .n-input-wrapper),
:deep(.form-control .n-base-selection),
:deep(.form-control .n-date-picker),
:deep(.form-control .n-time-picker) {
  min-height: 38px;
}

.toggle-control {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 600;
}

.schedule-card {
  padding: 12px;
  border: 1px solid var(--color-border);
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.76);
}

.schedule-head {
  align-items: flex-start;
  margin-bottom: 8px;
}

.primary-button,
.ghost-button,
.secondary-button,
.danger-button,
.text-button {
  min-height: 38px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
}

.primary-button:disabled,
.ghost-button:disabled,
.secondary-button:disabled,
.danger-button:disabled,
.text-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.primary-button {
  min-width: 112px;
  border: 0;
  background: linear-gradient(180deg, #397b46 0%, #2f6b3b 100%);
  color: #fff;
  box-shadow: 0 10px 20px rgba(47, 107, 59, 0.22);
}

.ghost-button {
  min-width: 112px;
  border: 1px solid var(--color-border);
  background: rgba(255, 255, 255, 0.72);
  color: var(--color-text);
}

.secondary-button {
  min-width: 112px;
  border: 1px solid rgba(47, 107, 59, 0.22);
  background: rgba(223, 240, 226, 0.88);
  color: #255d32;
}

.danger-button {
  min-width: 112px;
  border: 1px solid rgba(153, 80, 69, 0.22);
  background: rgba(247, 232, 227, 0.9);
  color: #8f4a3f;
}

.text-button {
  border: 0;
  background: transparent;
  color: var(--color-accent);
}

.feedback-banner,
.inline-message {
  padding: 12px 14px;
  border-radius: 14px;
  font-size: 13px;
  line-height: 1.6;
}

.feedback-banner {
  margin-bottom: 14px;
}

.feedback-banner--success {
  background: #e4f4e6;
  color: #285d34;
}

.feedback-banner--info {
  background: #ebf1e4;
  color: #4b5f39;
}

.feedback-banner--error,
.inline-message--error {
  background: #f7e8e3;
  color: #8f4a3f;
}

@media (max-width: 980px) {
  .shell {
    padding-top: calc(6px + env(safe-area-inset-top, 0px));
    padding-right: calc(12px + env(safe-area-inset-right, 0px));
    padding-bottom: calc(14px + env(safe-area-inset-bottom, 0px));
    padding-left: calc(12px + env(safe-area-inset-left, 0px));
  }

  .page-header,
  .workspace {
    grid-template-columns: minmax(0, 1fr);
    display: grid;
  }

  .list-pane {
    order: 2;
  }

  .editor-pane {
    order: 1;
  }

  .field-grid,
  .schedule-head,
  .detail-grid {
    grid-template-columns: minmax(0, 1fr);
    display: grid;
  }

  .pane-header {
    align-items: start;
  }
}

@media (max-width: 640px) {
  .list-pane,
  .editor-pane {
    padding: 12px;
    border-radius: 16px;
  }

  .form-actions,
  .header-actions {
    width: 100%;
  }

  .primary-button,
  .ghost-button {
    flex: 1 1 0;
  }
}
</style>
