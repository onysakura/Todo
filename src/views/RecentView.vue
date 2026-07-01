<template>
  <div class="recent-view">
    <div class="view-header">
      <div>
        <p class="view-eyebrow">近期视图</p>
        <h2>未来 {{ dayCount }} 天任务</h2>
      </div>
      <button class="text-button" type="button" :disabled="isLoading" @click="loadRecentTasks">
        {{ isLoading ? '刷新中' : '刷新' }}
      </button>
    </div>

    <div v-if="error" class="inline-message inline-message--error">{{ error }}</div>
    <div v-else-if="isLoading" class="loading-message">正在加载近期任务…</div>
    <div v-else-if="tasks.length === 0" class="loading-message">
      未来 {{ dayCount }} 天还没有任务。
    </div>
    <div v-else class="task-list">
      <div v-if="pendingTasks.length > 0" class="status-group">
        <p class="status-group-label">未完成</p>
        <TaskCard
          v-for="task in pendingTasks"
          :key="`${task.seriesId}-${task.occurrenceKey}`"
          :task="task"
          :tags-by-id="tagsById"
          :is-active="task.seriesId === selectedSeriesId"
          @select="handleSelect"
        />
      </div>
      <div v-if="doneTasks.length > 0" class="status-group">
        <p class="status-group-label status-group-label--muted">已完成 / 已取消</p>
        <TaskCard
          v-for="task in doneTasks"
          :key="`${task.seriesId}-${task.occurrenceKey}`"
          :task="task"
          :tags-by-id="tagsById"
          :is-active="task.seriesId === selectedSeriesId"
          @select="handleSelect"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import TaskCard from '../components/TaskCard.vue'
import {
  queryUpcomingTasks,
  type TagDto,
  type TaskListItemDto,
} from '../features/tasks/task-api'

const props = defineProps<{
  tagsById?: Map<string, TagDto>
  selectedSeriesId?: string | null
  dayCount?: number
}>()

const emit = defineEmits<{
  select: [seriesId: string]
}>()

const dayCount = props.dayCount ?? 31
const tasks = ref<TaskListItemDto[]>([])
const isLoading = ref(false)
const error = ref('')

const pendingTasks = computed(() =>
  tasks.value.filter((task) => task.status === 'pending'),
)

const doneTasks = computed(() =>
  tasks.value.filter((task) => task.status !== 'pending'),
)

onMounted(() => {
  loadRecentTasks()
})

async function loadRecentTasks() {
  isLoading.value = true
  error.value = ''
  try {
    tasks.value = await queryUpcomingTasks({ dayCount })
  } catch (err) {
    error.value = `加载近期任务失败：${formatError(err)}`
  } finally {
    isLoading.value = false
  }
}

function handleSelect(seriesId: string) {
  emit('select', seriesId)
}

function formatError(error: unknown) {
  if (error instanceof Error) {
    return error.message
  }
  return String(error)
}

defineExpose({ loadRecentTasks })
</script>

<style scoped>
.recent-view {
  display: grid;
  gap: 12px;
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

.inline-message--error {
  background: #f7e8e3;
  color: #8f4a3f;
}

.task-list {
  display: grid;
  gap: 14px;
}

.status-group {
  display: grid;
  gap: 6px;
}

.status-group-label {
  margin: 0 0 4px;
  font-size: 12px;
  font-weight: 700;
  color: var(--color-text-muted);
  letter-spacing: 0.04em;
}

.status-group-label--muted {
  opacity: 0.7;
}
</style>
