<template>
  <div class="calendar-view">
    <div class="view-header">
      <div>
        <p class="view-eyebrow">日历视图</p>
        <h2>未来 {{ dayCount }} 天</h2>
      </div>
      <button class="text-button" type="button" :disabled="isLoading" @click="loadCalendar">
        {{ isLoading ? '刷新中' : '刷新' }}
      </button>
    </div>

    <div v-if="error" class="inline-message inline-message--error">{{ error }}</div>
    <div v-else-if="isLoading" class="loading-message">正在加载日历…</div>
    <div v-else-if="calendarDays.length === 0" class="loading-message">暂无日历数据。</div>
    <div v-else class="calendar-stream">
      <template v-for="(day, index) in calendarDays" :key="day.date">
        <div
          v-if="index === 0 || isMonthBoundary(calendarDays[index - 1].date, day.date)"
          class="month-separator"
        >
          <span class="month-label">{{ formatMonthLabel(day.date) }}</span>
        </div>
        <div
          class="calendar-day"
          :class="{
            'calendar-day--empty': day.items.length === 0,
            'calendar-day--today': isToday(day.date),
          }"
        >
          <div class="day-header">
            <span class="day-number">{{ getDayNumber(day.date) }}</span>
            <span class="day-weekday">{{ getWeekday(day.date) }}</span>
          </div>
          <div v-if="day.items.length > 0" class="day-items">
            <TaskCard
              v-for="task in day.items"
              :key="`${task.seriesId}-${task.occurrenceKey}`"
              :task="task"
              :tags-by-id="tagsById"
              :is-active="task.seriesId === selectedSeriesId"
              @select="handleSelect"
            />
          </div>
          <div v-else class="day-empty-hint">—</div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import TaskCard from '../components/TaskCard.vue'
import {
  queryCalendarTasks,
  type CalendarDayDto,
  type TagDto,
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
const calendarDays = ref<CalendarDayDto[]>([])
const isLoading = ref(false)
const error = ref('')

onMounted(() => {
  loadCalendar()
})

async function loadCalendar() {
  isLoading.value = true
  error.value = ''
  try {
    calendarDays.value = await queryCalendarTasks({ dayCount })
  } catch (err) {
    error.value = `加载日历失败：${formatError(err)}`
  } finally {
    isLoading.value = false
  }
}

function handleSelect(seriesId: string) {
  emit('select', seriesId)
}

function getDayNumber(dateStr: string) {
  const day = dateStr.split('-')[2]
  return Number(day)
}

function getWeekday(dateStr: string) {
  const [year, month, day] = dateStr.split('-').map(Number)
  const date = new Date(year, month - 1, day)
  return new Intl.DateTimeFormat('zh-CN', { weekday: 'short' }).format(date)
}

function formatMonthLabel(dateStr: string) {
  const [year, month] = dateStr.split('-').map(Number)
  return `${year} 年 ${month} 月`
}

function isMonthBoundary(prevDate: string, currentDate: string) {
  const prevMonth = prevDate.slice(0, 7)
  const currentMonth = currentDate.slice(0, 7)
  return prevMonth !== currentMonth
}

function isToday(dateStr: string) {
  const now = new Date()
  const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
  return dateStr === today
}

function formatError(error: unknown) {
  if (error instanceof Error) {
    return error.message
  }
  return String(error)
}

defineExpose({ loadCalendar })
</script>

<style scoped>
.calendar-view {
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

.calendar-stream {
  display: grid;
  gap: 6px;
}

.month-separator {
  padding: 10px 0 6px;
  border-bottom: 2px solid var(--color-border-strong);
  margin-bottom: 4px;
}

.month-separator:first-child {
  padding-top: 0;
}

.month-label {
  font-size: 14px;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: 0.02em;
}

.calendar-day {
  display: grid;
  grid-template-columns: 48px minmax(0, 1fr);
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid var(--color-border);
}

.calendar-day:last-child {
  border-bottom: 0;
}

.calendar-day--empty {
  opacity: 0.5;
}

.calendar-day--today .day-header {
  color: var(--color-accent);
}

.calendar-day--today .day-number {
  background: var(--color-accent);
  color: #fff;
}

.day-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  padding-top: 2px;
}

.day-number {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  font-size: 14px;
  font-weight: 700;
  background: var(--color-surface-muted);
  color: var(--color-text);
}

.day-weekday {
  font-size: 11px;
  color: var(--color-text-muted);
}

.day-items {
  display: grid;
  gap: 6px;
}

.day-empty-hint {
  display: flex;
  align-items: center;
  height: 36px;
  color: var(--color-text-muted);
  font-size: 12px;
}

@media (max-width: 640px) {
  .calendar-day {
    grid-template-columns: 40px minmax(0, 1fr);
    gap: 8px;
  }

  .day-number {
    width: 28px;
    height: 28px;
    font-size: 13px;
  }
}
</style>
