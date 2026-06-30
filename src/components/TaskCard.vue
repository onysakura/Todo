<template>
  <button
    class="task-card"
    :class="{
      'task-card--completed': task.status === 'completed',
      'task-card--cancelled': task.status === 'cancelled',
      'task-card--danger': isDangerDay,
      'task-card--active': isActive,
    }"
    type="button"
    @click="$emit('select', task.seriesId)"
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
        <span class="meta-item meta-due">
          <span class="meta-icon" aria-hidden="true">截止</span>
          <span>{{ formatDueMeta(task) }}</span>
        </span>
        <span v-if="hasStartInfo" class="meta-item meta-start">
          <span class="meta-icon" aria-hidden="true">开始</span>
          <span>{{ formatStartMeta(task) }}</span>
        </span>
        <span v-if="task.priority !== null" class="meta-item meta-priority">
          P{{ task.priority }}
        </span>
      </div>
    </div>
    <div class="task-card-foot">
      <span
        v-if="task.tagId && tagsById?.get(task.tagId)"
        class="tag-pill"
        :style="buildTagStyle(task.tagId)"
      >
        {{ tagsById?.get(task.tagId)?.name }}
      </span>
      <span v-if="isDangerDay" class="danger-pill">危险日</span>
    </div>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { TagDto, TaskListItemDto, TaskStatus } from '../features/tasks/task-api'

const props = defineProps<{
  task: TaskListItemDto
  tagsById?: Map<string, TagDto>
  isActive?: boolean
  isDangerDay?: boolean
}>()

defineEmits<{
  select: [seriesId: string]
}>()

const statusLabels: Record<TaskStatus, string> = {
  pending: '未完成',
  completed: '已完成',
  cancelled: '已取消',
}

const hasStartInfo = computed(() => {
  return Boolean(props.task.startDate)
})

function formatDueMeta(task: TaskListItemDto) {
  const parts = [formatDateLabel(task.dueDate)]
  if (task.allDay) {
    parts.push('全天')
  } else if (task.dueTime) {
    parts.push(task.dueTime)
  }
  return parts.join(' · ')
}

function formatStartMeta(task: TaskListItemDto) {
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
  const tag = props.tagsById?.get(tagId)
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
</script>

<style scoped>
.task-card {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-surface-raised);
  color: inherit;
  text-align: left;
  cursor: pointer;
  transition:
    border-color 160ms ease,
    transform 160ms ease,
    box-shadow 160ms ease,
    opacity 160ms ease;
}

.task-card:hover {
  border-color: var(--color-border-strong);
  transform: translateY(-1px);
  box-shadow: 0 8px 18px rgba(23, 33, 15, 0.08);
}

.task-card--active {
  border-color: color-mix(in srgb, var(--color-accent) 55%, white);
  background: linear-gradient(180deg, #ffffff 0%, #eef5ee 100%);
  box-shadow: 0 12px 24px rgba(38, 88, 49, 0.12);
}

.task-card--completed,
.task-card--cancelled {
  opacity: 0.55;
}

.task-card--completed:hover,
.task-card--cancelled:hover {
  opacity: 0.8;
}

.task-card--danger {
  border-color: rgba(153, 80, 69, 0.35);
  background: linear-gradient(180deg, #fcf5f3 0%, #f9eeeb 100%);
}

.task-card--danger:hover {
  border-color: rgba(153, 80, 69, 0.55);
  box-shadow: 0 8px 18px rgba(153, 80, 69, 0.12);
}

.task-card-main {
  display: grid;
  gap: 5px;
}

.task-card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.task-card-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
  flex-wrap: wrap;
}

.task-title {
  font-size: 13px;
  font-weight: 700;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.task-note {
  margin: 0;
  font-size: 12px;
  line-height: 1.5;
  color: var(--color-text-muted);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.task-meta {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  font-size: 11px;
  color: var(--color-text-muted);
}

.meta-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.meta-icon {
  font-size: 10px;
  font-weight: 700;
  color: var(--color-text-muted);
  opacity: 0.7;
}

.meta-priority {
  font-weight: 700;
  color: var(--color-accent);
}

.status-chip,
.tag-pill,
.danger-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 20px;
  padding: 0 8px;
  border-radius: 999px;
  font-size: 11px;
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

.danger-pill {
  background: #f5e5e1;
  color: #995045;
  border: 1px solid rgba(153, 80, 69, 0.22);
}
</style>
