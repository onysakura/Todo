use std::collections::HashMap;

use serde::{Deserialize, Serialize};
use time::{
    format_description::well_known::Iso8601, macros::format_description, Date, Duration, Month,
    PrimitiveDateTime, Time,
};
use uuid::Uuid;

use crate::{
    db::{now_rfc3339, Database},
    domain::{TaskOccurrenceOverride, TaskSeries, TaskSeriesRevision},
    error::{AppError, AppResult},
    repository::{
        tag_repository::TagRepository,
        task_occurrence_override_repository::TaskOccurrenceOverrideRepository,
        task_series_repository::TaskSeriesRepository,
        task_series_revision_repository::TaskSeriesRevisionRepository,
    },
};

const STATUS_PENDING: &str = "pending";
const STATUS_COMPLETED: &str = "completed";
const STATUS_CANCELLED: &str = "cancelled";
const TASK_KIND_SINGLE: &str = "single";
const TASK_KIND_RECURRING: &str = "recurring";
const RECURRENCE_HOUR: &str = "hour";
const RECURRENCE_DAY: &str = "day";
const RECURRENCE_WEEK: &str = "week";
const RECURRENCE_MONTH: &str = "month";
const RECURRENCE_YEAR: &str = "year";
const DATE_FORMAT: &[time::format_description::FormatItem<'static>] =
    format_description!("[year]-[month]-[day]");
const TIME_FORMAT: &[time::format_description::FormatItem<'static>] =
    format_description!("[hour]:[minute]");

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TaskCreateInput {
    pub title: String,
    pub note: Option<String>,
    pub tag_id: Option<String>,
    pub priority: Option<i64>,
    pub all_day: bool,
    pub start_date: Option<String>,
    pub start_time: Option<String>,
    pub due_date: String,
    pub due_time: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TaskUpdateInput {
    pub series_id: String,
    pub title: String,
    pub note: Option<String>,
    pub tag_id: Option<String>,
    pub priority: Option<i64>,
    pub all_day: bool,
    pub start_date: Option<String>,
    pub start_time: Option<String>,
    pub due_date: String,
    pub due_time: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TaskSetStatusInput {
    pub series_id: String,
    pub status: String,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TaskDetailDto {
    pub series_id: String,
    pub revision_id: String,
    pub occurrence_key: String,
    pub kind: String,
    pub title: String,
    pub note: Option<String>,
    pub tag_id: Option<String>,
    pub priority: Option<i64>,
    pub all_day: bool,
    pub start_date: Option<String>,
    pub start_time: Option<String>,
    pub due_date: String,
    pub due_time: Option<String>,
    pub status: String,
    pub completed_at: Option<String>,
    pub cancelled_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TaskEditorDto {
    pub series_id: String,
    pub revision_id: String,
    pub kind: String,
    pub title: String,
    pub note: Option<String>,
    pub tag_id: Option<String>,
    pub priority: Option<i64>,
    pub all_day: bool,
    pub start_date: Option<String>,
    pub start_time: Option<String>,
    pub due_date: String,
    pub due_time: Option<String>,
    pub current_status: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpcomingQueryInput {
    pub start_date: Option<String>,
    pub day_count: Option<u32>,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TaskListItemDto {
    pub series_id: String,
    pub revision_id: String,
    pub occurrence_key: String,
    pub title: String,
    pub note: Option<String>,
    pub tag_id: Option<String>,
    pub priority: Option<i64>,
    pub all_day: bool,
    pub start_date: Option<String>,
    pub start_time: Option<String>,
    pub due_date: String,
    pub due_time: Option<String>,
    pub status: String,
}

#[derive(Debug, Clone)]
struct ParsedTaskInput {
    title: String,
    note: Option<String>,
    tag_id: Option<String>,
    priority: Option<i64>,
    all_day: bool,
    effective_from: Date,
    start_time: Option<Time>,
    due_date: Date,
    due_time: Option<Time>,
    duration_seconds: Option<i64>,
}

#[derive(Debug, Clone)]
struct ScheduleSeed {
    effective_from: Date,
    start_time: Option<Time>,
    base_start_anchor: PrimitiveDateTime,
    duration_seconds: i64,
}

#[derive(Debug, Clone)]
struct ScheduledOccurrence {
    revision_id: String,
    occurrence_key: String,
    start_date: Option<String>,
    start_time: Option<String>,
    due_date: String,
    due_time: Option<String>,
    due_date_value: Date,
    due_anchor_value: PrimitiveDateTime,
}

pub struct TaskService;

impl TaskService {
    pub fn create_task(database: &Database, input: TaskCreateInput) -> AppResult<TaskDetailDto> {
        let parsed = Self::validate_input(input)?;
        let series_id = Uuid::new_v4().to_string();
        let revision_id = Uuid::new_v4().to_string();
        let occurrence_key = parsed
            .due_date
            .format(DATE_FORMAT)
            .map_err(|error| AppError::Time(format!("格式化实例键失败: {error}")))?;
        let now = now_rfc3339()?;

        database.with_transaction(|transaction| {
            if let Some(tag_id) = parsed.tag_id.as_deref() {
                let tag = TagRepository::get_by_id(transaction, tag_id)?;
                if tag.is_none() {
                    return Err(AppError::Validation("指定的标签不存在".to_string()));
                }
            }

            let series = TaskSeries {
                id: series_id.clone(),
                kind: TASK_KIND_SINGLE.to_string(),
                created_at: now.clone(),
                updated_at: now.clone(),
                archived_at: None,
            };
            TaskSeriesRepository::create(transaction, &series)?;

            let revision = TaskSeriesRevision {
                id: revision_id.clone(),
                series_id: series_id.clone(),
                effective_from: parsed
                    .effective_from
                    .format(DATE_FORMAT)
                    .map_err(|error| AppError::Time(format!("格式化生效日期失败: {error}")))?,
                effective_until: None,
                title: parsed.title.clone(),
                note: parsed.note.clone(),
                tag_id: parsed.tag_id.clone(),
                priority: parsed.priority,
                all_day: parsed.all_day,
                start_at_time_part: parsed.start_time.map(time_to_seconds),
                due_at_time_part: parsed.due_time.map(time_to_seconds),
                duration_seconds: parsed.duration_seconds,
                recurrence_type: None,
                recurrence_interval: None,
                recurrence_rule_json: None,
                recurrence_until: None,
                danger_offset_value: None,
                danger_offset_unit: None,
                danger_use_workday: false,
                created_at: now.clone(),
                updated_at: now.clone(),
            };
            TaskSeriesRevisionRepository::create(transaction, &revision)?;

            Ok(TaskDetailDto {
                series_id: series_id.clone(),
                revision_id: revision_id.clone(),
                occurrence_key: occurrence_key.clone(),
                kind: TASK_KIND_SINGLE.to_string(),
                title: parsed.title.clone(),
                note: parsed.note.clone(),
                tag_id: parsed.tag_id.clone(),
                priority: parsed.priority,
                all_day: parsed.all_day,
                start_date: Some(
                    parsed
                        .effective_from
                        .format(DATE_FORMAT)
                        .map_err(|error| AppError::Time(format!("格式化开始日期失败: {error}")))?,
                ),
                start_time: parsed.start_time.map(format_time).transpose()?,
                due_date: parsed
                    .due_date
                    .format(DATE_FORMAT)
                    .map_err(|error| AppError::Time(format!("格式化截止日期失败: {error}")))?,
                due_time: parsed.due_time.map(format_time).transpose()?,
                status: STATUS_PENDING.to_string(),
                completed_at: None,
                cancelled_at: None,
            })
        })
    }

    pub fn get_task_detail(
        database: &Database,
        series_id: &str,
    ) -> AppResult<Option<TaskDetailDto>> {
        database.with_connection(|connection| Self::load_task_detail(connection, series_id))
    }

    pub fn get_task_editor(
        database: &Database,
        series_id: &str,
    ) -> AppResult<Option<TaskEditorDto>> {
        database.with_connection(|connection| {
            let Some(detail) = Self::load_task_detail(connection, series_id)? else {
                return Ok(None);
            };

            Ok(Some(TaskEditorDto {
                series_id: detail.series_id,
                revision_id: detail.revision_id,
                kind: detail.kind,
                title: detail.title,
                note: detail.note,
                tag_id: detail.tag_id,
                priority: detail.priority,
                all_day: detail.all_day,
                start_date: detail.start_date,
                start_time: detail.start_time,
                due_date: detail.due_date,
                due_time: detail.due_time,
                current_status: detail.status,
            }))
        })
    }

    pub fn update_task(database: &Database, input: TaskUpdateInput) -> AppResult<TaskDetailDto> {
        let parsed = Self::validate_input(TaskCreateInput {
            title: input.title,
            note: input.note,
            tag_id: input.tag_id,
            priority: input.priority,
            all_day: input.all_day,
            start_date: input.start_date,
            start_time: input.start_time,
            due_date: input.due_date,
            due_time: input.due_time,
        })?;
        let now = now_rfc3339()?;

        database.with_transaction(|transaction| {
            let series = TaskSeriesRepository::get_by_id(transaction, &input.series_id)?
                .ok_or_else(|| AppError::Validation("任务不存在".to_string()))?;
            if series.kind != TASK_KIND_SINGLE {
                return Err(AppError::Validation("当前仅支持编辑单次任务".to_string()));
            }

            if let Some(tag_id) = parsed.tag_id.as_deref() {
                let tag = TagRepository::get_by_id(transaction, tag_id)?;
                if tag.is_none() {
                    return Err(AppError::Validation("指定的标签不存在".to_string()));
                }
            }

            let revisions =
                TaskSeriesRevisionRepository::list_by_series_id(transaction, &input.series_id)?;
            let mut revision = revisions
                .into_iter()
                .next()
                .ok_or_else(|| AppError::State("任务缺少版本段数据".to_string()))?;

            let old_occurrence_key = reconstruct_task_schedule(&revision)?.4;
            let new_occurrence_key = parsed
                .due_date
                .format(DATE_FORMAT)
                .map_err(|error| AppError::Time(format!("格式化实例键失败: {error}")))?;

            revision.effective_from = parsed
                .effective_from
                .format(DATE_FORMAT)
                .map_err(|error| AppError::Time(format!("格式化生效日期失败: {error}")))?;
            revision.title = parsed.title.clone();
            revision.note = parsed.note.clone();
            revision.tag_id = parsed.tag_id.clone();
            revision.priority = parsed.priority;
            revision.all_day = parsed.all_day;
            revision.start_at_time_part = parsed.start_time.map(time_to_seconds);
            revision.due_at_time_part = parsed.due_time.map(time_to_seconds);
            revision.duration_seconds = parsed.duration_seconds;
            revision.updated_at = now.clone();
            TaskSeriesRevisionRepository::update(transaction, &revision)?;
            TaskSeriesRepository::touch_updated_at(transaction, &input.series_id, &now)?;

            if let Some(mut occurrence_override) =
                TaskOccurrenceOverrideRepository::get_by_series_and_occurrence(
                    transaction,
                    &input.series_id,
                    &old_occurrence_key,
                )?
            {
                occurrence_override.occurrence_key = new_occurrence_key.clone();
                occurrence_override.updated_at = now.clone();
                TaskOccurrenceOverrideRepository::upsert(transaction, &occurrence_override)?;
            }

            Self::build_task_detail(transaction, series, revision, new_occurrence_key)
        })
    }

    pub fn delete_task(database: &Database, series_id: &str) -> AppResult<()> {
        database.with_transaction(|transaction| {
            let series = TaskSeriesRepository::get_by_id(transaction, series_id)?
                .ok_or_else(|| AppError::Validation("任务不存在".to_string()))?;
            if series.kind != TASK_KIND_SINGLE {
                return Err(AppError::Validation("当前仅支持删除单次任务".to_string()));
            }

            TaskOccurrenceOverrideRepository::delete_by_series_id(transaction, series_id)?;
            TaskSeriesRevisionRepository::delete_by_series_id(transaction, series_id)?;
            TaskSeriesRepository::delete(transaction, series_id)?;
            Ok(())
        })
    }

    pub fn set_status(database: &Database, input: TaskSetStatusInput) -> AppResult<TaskDetailDto> {
        let status = normalize_status(&input.status)?;
        let now = now_rfc3339()?;

        database.with_transaction(|transaction| {
            let series = TaskSeriesRepository::get_by_id(transaction, &input.series_id)?
                .ok_or_else(|| AppError::Validation("任务不存在".to_string()))?;
            if series.kind != TASK_KIND_SINGLE {
                return Err(AppError::Validation(
                    "当前仅支持设置单次任务状态".to_string(),
                ));
            }

            let revisions =
                TaskSeriesRevisionRepository::list_by_series_id(transaction, &input.series_id)?;
            let revision = revisions
                .into_iter()
                .next()
                .ok_or_else(|| AppError::State("任务缺少版本段数据".to_string()))?;
            let occurrence_key = reconstruct_task_schedule(&revision)?.4;

            let existing_override = TaskOccurrenceOverrideRepository::get_by_series_and_occurrence(
                transaction,
                &input.series_id,
                &occurrence_key,
            )?;
            let created_at = existing_override
                .as_ref()
                .map(|value| value.created_at.clone())
                .unwrap_or_else(|| now.clone());
            let override_id = existing_override
                .as_ref()
                .map(|value| value.id.clone())
                .unwrap_or_else(|| Uuid::new_v4().to_string());

            let override_record = TaskOccurrenceOverride {
                id: override_id,
                series_id: input.series_id.clone(),
                occurrence_key: occurrence_key.clone(),
                override_start_at: existing_override
                    .as_ref()
                    .and_then(|value| value.override_start_at.clone()),
                override_due_at: existing_override
                    .as_ref()
                    .and_then(|value| value.override_due_at.clone()),
                override_danger_at: existing_override
                    .as_ref()
                    .and_then(|value| value.override_danger_at.clone()),
                override_title: existing_override
                    .as_ref()
                    .and_then(|value| value.override_title.clone()),
                override_note: existing_override
                    .as_ref()
                    .and_then(|value| value.override_note.clone()),
                override_tag_id: existing_override
                    .as_ref()
                    .and_then(|value| value.override_tag_id.clone()),
                override_priority: existing_override
                    .as_ref()
                    .and_then(|value| value.override_priority),
                status: status.to_string(),
                completed_at: if status == STATUS_COMPLETED {
                    Some(now.clone())
                } else {
                    None
                },
                cancelled_at: if status == STATUS_CANCELLED {
                    Some(now.clone())
                } else {
                    None
                },
                detached_as_single: existing_override
                    .as_ref()
                    .map(|value| value.detached_as_single)
                    .unwrap_or(false),
                created_at,
                updated_at: now.clone(),
            };

            TaskOccurrenceOverrideRepository::upsert(transaction, &override_record)?;
            TaskSeriesRepository::touch_updated_at(transaction, &input.series_id, &now)?;

            Self::build_task_detail(transaction, series, revision, occurrence_key)
        })
    }

    pub fn upcoming_query(
        database: &Database,
        input: UpcomingQueryInput,
    ) -> AppResult<Vec<TaskListItemDto>> {
        let start_date = input
            .start_date
            .as_deref()
            .map(|value| parse_date(value, "查询开始日期"))
            .transpose()?
            .unwrap_or_else(today_utc);
        let day_count = input.day_count.unwrap_or(31);
        if day_count == 0 {
            return Err(AppError::Validation("查询天数必须大于 0".to_string()));
        }
        let end_date = start_date + Duration::days(day_count as i64 - 1);

        database.with_connection(|connection| {
            let series_list = TaskSeriesRepository::list_active(connection)?;
            let mut items = Vec::new();

            for series in series_list {
                let revisions =
                    TaskSeriesRevisionRepository::list_by_series_id(connection, &series.id)?;
                if revisions.is_empty() {
                    continue;
                }

                let overrides =
                    TaskOccurrenceOverrideRepository::list_by_series_id(connection, &series.id)?;
                let override_map: HashMap<String, TaskOccurrenceOverride> = overrides
                    .into_iter()
                    .map(|item| (item.occurrence_key.clone(), item))
                    .collect();

                for revision in revisions {
                    let occurrences = expand_occurrences_for_revision(
                        &series.kind,
                        &revision,
                        start_date,
                        end_date,
                    )?;

                    for occurrence in occurrences {
                        let occurrence_override = override_map.get(&occurrence.occurrence_key);
                        items.push(build_task_list_item(
                            &series,
                            &revision,
                            occurrence,
                            occurrence_override,
                        ));
                    }
                }
            }

            items.sort_by(|left, right| sort_key(left).cmp(&sort_key(right)));
            Ok(items)
        })
    }

    fn validate_input(input: TaskCreateInput) -> AppResult<ParsedTaskInput> {
        let title = input.title.trim().to_string();
        if title.is_empty() {
            return Err(AppError::Validation("标题不能为空".to_string()));
        }

        let due_date = parse_date(&input.due_date, "截止日期")?;
        let start_date = input
            .start_date
            .as_deref()
            .map(|value| parse_date(value, "开始日期"))
            .transpose()?;

        let start_time = if input.all_day {
            if input.start_time.is_some() || input.due_time.is_some() {
                return Err(AppError::Validation("全日任务不能填写具体时间".to_string()));
            }
            None
        } else {
            input
                .start_time
                .as_deref()
                .map(|value| parse_time(value, "开始时间"))
                .transpose()?
        };

        let due_time = if input.all_day {
            None
        } else {
            let value = input
                .due_time
                .as_deref()
                .ok_or_else(|| AppError::Validation("非全日任务必须填写截止时间".to_string()))?;
            Some(parse_time(value, "截止时间")?)
        };

        if start_time.is_some() && start_date.is_none() {
            return Err(AppError::Validation(
                "填写开始时间时必须同时填写开始日期".to_string(),
            ));
        }

        let effective_from = start_date.unwrap_or(due_date);
        let start_anchor =
            PrimitiveDateTime::new(effective_from, start_time.unwrap_or(Time::MIDNIGHT));
        let due_anchor = PrimitiveDateTime::new(due_date, due_time.unwrap_or(Time::MIDNIGHT));

        if start_anchor > due_anchor {
            return Err(AppError::Validation("开始时间不能晚于截止时间".to_string()));
        }

        let duration_seconds =
            if effective_from == due_date && start_time.is_none() && input.all_day {
                None
            } else {
                Some((due_anchor - start_anchor).whole_seconds())
            };

        Ok(ParsedTaskInput {
            title,
            note: normalize_optional_text(input.note),
            tag_id: input.tag_id,
            priority: input.priority,
            all_day: input.all_day,
            effective_from,
            start_time,
            due_date,
            due_time,
            duration_seconds,
        })
    }

    fn build_task_detail(
        connection: &rusqlite::Connection,
        series: TaskSeries,
        revision: TaskSeriesRevision,
        occurrence_key: String,
    ) -> AppResult<TaskDetailDto> {
        let (start_date, start_time, due_date, due_time, detail_occurrence_key) =
            reconstruct_task_schedule(&revision)?;

        let occurrence_override = TaskOccurrenceOverrideRepository::get_by_series_and_occurrence(
            connection,
            &series.id,
            &occurrence_key,
        )?;

        Ok(TaskDetailDto {
            series_id: series.id,
            revision_id: revision.id,
            occurrence_key: detail_occurrence_key,
            kind: series.kind,
            title: occurrence_override
                .as_ref()
                .and_then(|value| value.override_title.clone())
                .unwrap_or(revision.title),
            note: occurrence_override
                .as_ref()
                .and_then(|value| value.override_note.clone())
                .or(revision.note),
            tag_id: occurrence_override
                .as_ref()
                .and_then(|value| value.override_tag_id.clone())
                .or(revision.tag_id),
            priority: occurrence_override
                .as_ref()
                .and_then(|value| value.override_priority)
                .or(revision.priority),
            all_day: revision.all_day,
            start_date,
            start_time,
            due_date,
            due_time,
            status: occurrence_override
                .as_ref()
                .map(|value| value.status.clone())
                .unwrap_or_else(|| STATUS_PENDING.to_string()),
            completed_at: occurrence_override
                .as_ref()
                .and_then(|value| value.completed_at.clone()),
            cancelled_at: occurrence_override
                .as_ref()
                .and_then(|value| value.cancelled_at.clone()),
        })
    }

    fn load_task_detail(
        connection: &rusqlite::Connection,
        series_id: &str,
    ) -> AppResult<Option<TaskDetailDto>> {
        let series = match TaskSeriesRepository::get_by_id(connection, series_id)? {
            Some(series) => series,
            None => return Ok(None),
        };
        if series.kind != TASK_KIND_SINGLE {
            return Err(AppError::Validation(
                "当前仅支持读取单次任务详情".to_string(),
            ));
        }

        let mut revisions = TaskSeriesRevisionRepository::list_by_series_id(connection, series_id)?;
        let revision = revisions
            .drain(..)
            .next()
            .ok_or_else(|| AppError::State("任务缺少版本段数据".to_string()))?;
        let occurrence_key = reconstruct_task_schedule(&revision)?.4;

        Self::build_task_detail(connection, series, revision, occurrence_key).map(Some)
    }
}

fn build_task_list_item(
    series: &TaskSeries,
    revision: &TaskSeriesRevision,
    occurrence: ScheduledOccurrence,
    occurrence_override: Option<&TaskOccurrenceOverride>,
) -> TaskListItemDto {
    TaskListItemDto {
        series_id: series.id.clone(),
        revision_id: occurrence.revision_id,
        occurrence_key: occurrence.occurrence_key,
        title: occurrence_override
            .and_then(|value| value.override_title.clone())
            .unwrap_or_else(|| revision.title.clone()),
        note: occurrence_override
            .and_then(|value| value.override_note.clone())
            .or_else(|| revision.note.clone()),
        tag_id: occurrence_override
            .and_then(|value| value.override_tag_id.clone())
            .or_else(|| revision.tag_id.clone()),
        priority: occurrence_override
            .and_then(|value| value.override_priority)
            .or(revision.priority),
        all_day: revision.all_day,
        start_date: occurrence.start_date,
        start_time: occurrence.start_time,
        due_date: occurrence.due_date,
        due_time: occurrence.due_time,
        status: occurrence_override
            .map(|value| value.status.clone())
            .unwrap_or_else(|| STATUS_PENDING.to_string()),
    }
}

fn expand_occurrences_for_revision(
    series_kind: &str,
    revision: &TaskSeriesRevision,
    window_start: Date,
    window_end: Date,
) -> AppResult<Vec<ScheduledOccurrence>> {
    let seed = build_schedule_seed(revision)?;
    if series_kind == TASK_KIND_SINGLE {
        let occurrence = build_scheduled_occurrence(revision, &seed, seed.effective_from, true)?;
        if occurrence.due_date_value < window_start || occurrence.due_date_value > window_end {
            return Ok(Vec::new());
        }
        return Ok(vec![occurrence]);
    }

    if series_kind != TASK_KIND_RECURRING {
        return Err(AppError::State(format!(
            "未知任务类型，无法展开实例: {series_kind}"
        )));
    }

    let recurrence_type = revision
        .recurrence_type
        .as_deref()
        .ok_or_else(|| AppError::State("重复任务缺少 recurrence_type".to_string()))?;
    let recurrence_interval = revision.recurrence_interval.unwrap_or(1);
    if recurrence_interval <= 0 {
        return Err(AppError::Validation("重复间隔必须大于 0".to_string()));
    }

    let recurrence_until = revision
        .recurrence_until
        .as_deref()
        .map(|value| parse_date(value, "循环截止日期"))
        .transpose()?;
    let effective_until = revision
        .effective_until
        .as_deref()
        .map(|value| parse_date(value, "版本结束日期"))
        .transpose()?;
    let first_occurrence = build_scheduled_occurrence(revision, &seed, seed.effective_from, false)?;
    let window_start_anchor = PrimitiveDateTime::new(window_start, Time::MIDNIGHT);
    let window_end_exclusive_anchor =
        PrimitiveDateTime::new(window_end + Duration::days(1), Time::MIDNIGHT);

    if recurrence_type == RECURRENCE_HOUR {
        let mut occurrence_index = initial_hourly_occurrence_index(
            first_occurrence.due_anchor_value,
            recurrence_interval,
            window_start_anchor,
        );
        let mut items = Vec::new();

        loop {
            let occurrence_start_anchor = shift_hourly_recurrence_start(
                seed.base_start_anchor,
                recurrence_interval,
                occurrence_index,
            );
            if let Some(value) = effective_until {
                if occurrence_start_anchor.date() > value {
                    break;
                }
            }

            let occurrence = build_scheduled_occurrence_at_anchor(
                revision,
                &seed,
                occurrence_start_anchor,
                false,
            )?;
            if let Some(value) = recurrence_until {
                if occurrence.due_date_value > value {
                    break;
                }
            }
            if occurrence.due_anchor_value >= window_end_exclusive_anchor {
                break;
            }
            if occurrence.due_anchor_value >= window_start_anchor {
                items.push(occurrence);
            }

            occurrence_index += 1;
        }

        return Ok(items);
    }

    let mut occurrence_index = initial_occurrence_index(
        recurrence_type,
        first_occurrence.due_date_value,
        recurrence_interval,
        window_start,
    );
    let mut items = Vec::new();

    loop {
        let occurrence_start = shift_recurrence_start(
            seed.effective_from,
            recurrence_type,
            recurrence_interval,
            occurrence_index,
        )?;
        if let Some(value) = effective_until {
            if occurrence_start > value {
                break;
            }
        }

        let occurrence = build_scheduled_occurrence(revision, &seed, occurrence_start, false)?;
        if let Some(value) = recurrence_until {
            if occurrence.due_date_value > value {
                break;
            }
        }
        if occurrence.due_date_value > window_end {
            break;
        }
        if occurrence.due_date_value >= window_start {
            items.push(occurrence);
        }

        occurrence_index += 1;
    }

    Ok(items)
}

fn build_schedule_seed(revision: &TaskSeriesRevision) -> AppResult<ScheduleSeed> {
    let effective_from = parse_date(&revision.effective_from, "版本开始日期")?;
    let start_time = revision
        .start_at_time_part
        .map(seconds_to_time)
        .transpose()?;

    Ok(ScheduleSeed {
        effective_from,
        start_time,
        base_start_anchor: PrimitiveDateTime::new(
            effective_from,
            start_time.unwrap_or(Time::MIDNIGHT),
        ),
        duration_seconds: revision.duration_seconds.unwrap_or(0),
    })
}

fn build_scheduled_occurrence(
    revision: &TaskSeriesRevision,
    seed: &ScheduleSeed,
    start_date: Date,
    use_legacy_occurrence_key: bool,
) -> AppResult<ScheduledOccurrence> {
    let start_anchor =
        PrimitiveDateTime::new(start_date, seed.start_time.unwrap_or(Time::MIDNIGHT));
    build_scheduled_occurrence_at_anchor(revision, seed, start_anchor, use_legacy_occurrence_key)
}

fn build_scheduled_occurrence_at_anchor(
    revision: &TaskSeriesRevision,
    seed: &ScheduleSeed,
    start_anchor: PrimitiveDateTime,
    use_legacy_occurrence_key: bool,
) -> AppResult<ScheduledOccurrence> {
    let due_anchor = start_anchor + Duration::seconds(seed.duration_seconds);
    let due_date = due_anchor.date();
    let due_time = if revision.all_day {
        None
    } else {
        Some(due_anchor.time())
    };

    let start_date_string = format_date(start_anchor.date())?;
    let due_date_string = format_date(due_date)?;
    let occurrence_key = if use_legacy_occurrence_key {
        due_date_string.clone()
    } else {
        build_recurrence_occurrence_key(&revision.id, start_anchor, due_anchor)
    };

    Ok(ScheduledOccurrence {
        revision_id: revision.id.clone(),
        occurrence_key,
        start_date: Some(start_date_string),
        start_time: if revision.all_day {
            None
        } else {
            Some(format_time(start_anchor.time())?)
        },
        due_date: due_date_string,
        due_time: due_time.map(format_time).transpose()?,
        due_date_value: due_date,
        due_anchor_value: due_anchor,
    })
}

fn build_recurrence_occurrence_key(
    revision_id: &str,
    start_anchor: PrimitiveDateTime,
    due_anchor: PrimitiveDateTime,
) -> String {
    format!(
        "{}|{}|{}",
        revision_id,
        format_occurrence_anchor(start_anchor),
        format_occurrence_anchor(due_anchor)
    )
}

fn format_occurrence_anchor(value: PrimitiveDateTime) -> String {
    let date = value.date();
    let time = value.time();
    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}",
        date.year(),
        u8::from(date.month()),
        date.day(),
        time.hour(),
        time.minute(),
        time.second()
    )
}

fn initial_occurrence_index(
    recurrence_type: &str,
    first_due_date: Date,
    recurrence_interval: i64,
    window_start: Date,
) -> i64 {
    if window_start <= first_due_date {
        return 0;
    }

    match recurrence_type {
        RECURRENCE_DAY => {
            let diff_days = (window_start - first_due_date).whole_days();
            ceil_div_positive(diff_days, recurrence_interval)
        }
        RECURRENCE_WEEK => {
            let diff_days = (window_start - first_due_date).whole_days();
            ceil_div_positive(diff_days, recurrence_interval * 7)
        }
        RECURRENCE_MONTH => {
            approximate_monthly_index(first_due_date, window_start, recurrence_interval)
        }
        RECURRENCE_YEAR => {
            approximate_monthly_index(first_due_date, window_start, recurrence_interval * 12)
        }
        _ => 0,
    }
}

fn initial_hourly_occurrence_index(
    first_due_anchor: PrimitiveDateTime,
    recurrence_interval: i64,
    window_start_anchor: PrimitiveDateTime,
) -> i64 {
    if window_start_anchor <= first_due_anchor {
        return 0;
    }

    let diff_seconds = (window_start_anchor - first_due_anchor).whole_seconds();
    ceil_div_positive(diff_seconds, recurrence_interval * 3600)
}

fn ceil_div_positive(value: i64, divisor: i64) -> i64 {
    if value <= 0 {
        0
    } else {
        (value + divisor - 1) / divisor
    }
}

fn approximate_monthly_index(first_due_date: Date, window_start: Date, step_months: i64) -> i64 {
    if step_months <= 0 {
        return 0;
    }

    let diff_months = months_between(first_due_date, window_start);
    if diff_months <= 0 {
        0
    } else {
        (diff_months / step_months).saturating_sub(1)
    }
}

fn months_between(start: Date, end: Date) -> i64 {
    let start_month = i64::from(u8::from(start.month()));
    let end_month = i64::from(u8::from(end.month()));
    let base = i64::from(end.year() - start.year()) * 12 + (end_month - start_month);
    if end.day() < start.day() {
        base - 1
    } else {
        base
    }
}

fn shift_recurrence_start(
    base_start: Date,
    recurrence_type: &str,
    recurrence_interval: i64,
    occurrence_index: i64,
) -> AppResult<Date> {
    match recurrence_type {
        RECURRENCE_HOUR => Err(AppError::State(
            "按小时重复应使用时间锚点展开，不应走日期位移逻辑".to_string(),
        )),
        RECURRENCE_DAY => Ok(base_start + Duration::days(recurrence_interval * occurrence_index)),
        RECURRENCE_WEEK => {
            Ok(base_start + Duration::days(recurrence_interval * occurrence_index * 7))
        }
        RECURRENCE_MONTH => add_months_clamped(base_start, recurrence_interval * occurrence_index),
        RECURRENCE_YEAR => {
            add_months_clamped(base_start, recurrence_interval * occurrence_index * 12)
        }
        other => Err(AppError::Validation(format!(
            "当前仅支持 day、week、month、year 重复，收到: {other}"
        ))),
    }
}

fn shift_hourly_recurrence_start(
    base_start_anchor: PrimitiveDateTime,
    recurrence_interval: i64,
    occurrence_index: i64,
) -> PrimitiveDateTime {
    base_start_anchor + Duration::hours(recurrence_interval * occurrence_index)
}

fn add_months_clamped(date: Date, month_delta: i64) -> AppResult<Date> {
    let source_month = i64::from(u8::from(date.month())) - 1;
    let absolute_month = i64::from(date.year()) * 12 + source_month + month_delta;
    let target_year = absolute_month.div_euclid(12) as i32;
    let target_month_zero = absolute_month.rem_euclid(12);
    let target_month = Month::try_from((target_month_zero + 1) as u8)
        .map_err(|error| AppError::Time(format!("计算重复月份失败: {error}")))?;
    let target_day = date.day().min(days_in_month(target_year, target_month));

    Date::from_calendar_date(target_year, target_month, target_day)
        .map_err(|error| AppError::Time(format!("计算重复日期失败: {error}")))
}

fn days_in_month(year: i32, month: Month) -> u8 {
    match month {
        Month::January
        | Month::March
        | Month::May
        | Month::July
        | Month::August
        | Month::October
        | Month::December => 31,
        Month::April | Month::June | Month::September | Month::November => 30,
        Month::February => {
            if is_leap_year(year) {
                29
            } else {
                28
            }
        }
    }
}

fn is_leap_year(year: i32) -> bool {
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

fn reconstruct_task_schedule(
    revision: &TaskSeriesRevision,
) -> AppResult<(
    Option<String>,
    Option<String>,
    String,
    Option<String>,
    String,
)> {
    let seed = build_schedule_seed(revision)?;
    let occurrence = build_scheduled_occurrence(revision, &seed, seed.effective_from, true)?;

    Ok((
        occurrence.start_date,
        occurrence.start_time,
        occurrence.due_date.clone(),
        occurrence.due_time,
        occurrence.occurrence_key,
    ))
}

fn parse_date(value: &str, field_name: &str) -> AppResult<Date> {
    Date::parse(value, DATE_FORMAT).map_err(|error| {
        AppError::Validation(format!("{field_name}格式无效，应为 YYYY-MM-DD: {error}"))
    })
}

fn parse_time(value: &str, field_name: &str) -> AppResult<Time> {
    Time::parse(value, TIME_FORMAT)
        .map_err(|error| AppError::Validation(format!("{field_name}格式无效，应为 HH:MM: {error}")))
}

fn format_time(value: Time) -> AppResult<String> {
    value
        .format(TIME_FORMAT)
        .map_err(|error| AppError::Time(format!("格式化时间失败: {error}")))
}

fn format_date(value: Date) -> AppResult<String> {
    value
        .format(DATE_FORMAT)
        .map_err(|error| AppError::Time(format!("格式化日期失败: {error}")))
}

fn time_to_seconds(value: Time) -> i64 {
    (value.hour() as i64 * 3600) + (value.minute() as i64 * 60) + value.second() as i64
}

fn seconds_to_time(value: i64) -> AppResult<Time> {
    if !(0..=86_399).contains(&value) {
        return Err(AppError::State(
            "数据库中的时间秒数超出有效范围".to_string(),
        ));
    }

    Time::parse(
        &format!(
            "{:02}:{:02}:{:02}",
            value / 3600,
            (value % 3600) / 60,
            value % 60
        ),
        &Iso8601::TIME,
    )
    .map_err(|error| AppError::Time(format!("解析秒数失败: {error}")))
}

fn normalize_optional_text(value: Option<String>) -> Option<String> {
    value.and_then(|text| {
        let trimmed = text.trim().to_string();
        if trimmed.is_empty() {
            None
        } else {
            Some(trimmed)
        }
    })
}

fn normalize_status(value: &str) -> AppResult<&str> {
    match value {
        STATUS_PENDING => Ok(STATUS_PENDING),
        STATUS_COMPLETED => Ok(STATUS_COMPLETED),
        STATUS_CANCELLED => Ok(STATUS_CANCELLED),
        _ => Err(AppError::Validation(
            "任务状态仅支持 pending、completed、cancelled".to_string(),
        )),
    }
}

fn today_utc() -> Date {
    time::OffsetDateTime::now_utc().date()
}

fn sort_key(task: &TaskListItemDto) -> (String, String, i64, String) {
    (
        task.due_date.clone(),
        task.due_time.clone().unwrap_or_else(|| "00:00".to_string()),
        task.priority.unwrap_or(999),
        task.occurrence_key.clone(),
    )
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;
    use time::Time;
    use uuid::Uuid;

    use super::{
        build_schedule_seed, build_scheduled_occurrence, shift_recurrence_start, TaskCreateInput,
        TaskService, TaskSetStatusInput, TaskUpdateInput, UpcomingQueryInput, TASK_KIND_RECURRING,
    };
    use crate::{
        db::{now_rfc3339, Database},
        domain::{TaskOccurrenceOverride, TaskSeries, TaskSeriesRevision},
        repository::{
            tag_repository::TagRepository,
            task_occurrence_override_repository::TaskOccurrenceOverrideRepository,
            task_series_repository::TaskSeriesRepository,
            task_series_revision_repository::TaskSeriesRevisionRepository,
        },
    };

    fn insert_recurring_task(
        database: &Database,
        title: &str,
        effective_from: &str,
        recurrence_type: &str,
        recurrence_interval: i64,
        recurrence_until: Option<&str>,
    ) -> (TaskSeries, TaskSeriesRevision) {
        insert_recurring_task_with_schedule(
            database,
            title,
            effective_from,
            recurrence_type,
            recurrence_interval,
            recurrence_until,
            true,
            None,
            None,
            None,
        )
    }

    fn insert_recurring_task_with_schedule(
        database: &Database,
        title: &str,
        effective_from: &str,
        recurrence_type: &str,
        recurrence_interval: i64,
        recurrence_until: Option<&str>,
        all_day: bool,
        start_time: Option<Time>,
        due_time: Option<Time>,
        duration_seconds: Option<i64>,
    ) -> (TaskSeries, TaskSeriesRevision) {
        let now = now_rfc3339().expect("should build timestamp");
        let series = TaskSeries {
            id: Uuid::new_v4().to_string(),
            kind: TASK_KIND_RECURRING.to_string(),
            created_at: now.clone(),
            updated_at: now.clone(),
            archived_at: None,
        };
        let revision = TaskSeriesRevision {
            id: Uuid::new_v4().to_string(),
            series_id: series.id.clone(),
            effective_from: effective_from.to_string(),
            effective_until: None,
            title: title.to_string(),
            note: Some("重复任务".to_string()),
            tag_id: None,
            priority: Some(2),
            all_day,
            start_at_time_part: start_time.map(super::time_to_seconds),
            due_at_time_part: due_time.map(super::time_to_seconds),
            duration_seconds,
            recurrence_type: Some(recurrence_type.to_string()),
            recurrence_interval: Some(recurrence_interval),
            recurrence_rule_json: None,
            recurrence_until: recurrence_until.map(str::to_string),
            danger_offset_value: None,
            danger_offset_unit: None,
            danger_use_workday: false,
            created_at: now.clone(),
            updated_at: now,
        };

        database
            .with_transaction(|transaction| {
                TaskSeriesRepository::create(transaction, &series)?;
                TaskSeriesRevisionRepository::create(transaction, &revision)?;
                Ok(())
            })
            .expect("should insert recurring task");

        (series, revision)
    }

    #[test]
    fn create_and_get_single_task_round_trip() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "整理周报".to_string(),
                note: Some("优先处理".to_string()),
                tag_id: None,
                priority: Some(2),
                all_day: false,
                start_date: Some("2026-04-13".to_string()),
                start_time: Some("09:00".to_string()),
                due_date: "2026-04-14".to_string(),
                due_time: Some("18:30".to_string()),
            },
        )
        .expect("should create task");

        let detail = TaskService::get_task_detail(&database, &created.series_id)
            .expect("should get detail")
            .expect("detail should exist");

        assert_eq!(detail.title, "整理周报");
        assert_eq!(detail.note.as_deref(), Some("优先处理"));
        assert_eq!(detail.start_date.as_deref(), Some("2026-04-13"));
        assert_eq!(detail.start_time.as_deref(), Some("09:00"));
        assert_eq!(detail.due_date, "2026-04-14");
        assert_eq!(detail.due_time.as_deref(), Some("18:30"));
        assert_eq!(detail.status, "pending");
    }

    #[test]
    fn create_task_validates_tag_existence() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let result = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "无效标签".to_string(),
                note: None,
                tag_id: Some("missing-tag".to_string()),
                priority: None,
                all_day: true,
                start_date: None,
                start_time: None,
                due_date: "2026-04-13".to_string(),
                due_time: None,
            },
        );

        assert!(result.is_err());
    }

    #[test]
    fn create_task_accepts_existing_tag() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let tag = database
            .with_connection(|connection| TagRepository::create(connection, "工作", None, 0))
            .expect("should create tag");
        let tag_id = tag.id.clone();

        let created = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "带标签任务".to_string(),
                note: None,
                tag_id: Some(tag_id.clone()),
                priority: Some(1),
                all_day: true,
                start_date: Some("2026-04-13".to_string()),
                start_time: None,
                due_date: "2026-04-15".to_string(),
                due_time: None,
            },
        )
        .expect("should create task");

        assert_eq!(created.tag_id.as_deref(), Some(tag_id.as_str()));
        assert_eq!(created.due_date, "2026-04-15");
        assert_eq!(created.due_time, None);
    }

    #[test]
    fn update_task_updates_single_task_fields() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "原始标题".to_string(),
                note: None,
                tag_id: None,
                priority: Some(1),
                all_day: false,
                start_date: Some("2026-04-13".to_string()),
                start_time: Some("08:00".to_string()),
                due_date: "2026-04-13".to_string(),
                due_time: Some("18:00".to_string()),
            },
        )
        .expect("should create task");

        let updated = TaskService::update_task(
            &database,
            TaskUpdateInput {
                series_id: created.series_id.clone(),
                title: "更新后标题".to_string(),
                note: Some("已修改".to_string()),
                tag_id: None,
                priority: Some(3),
                all_day: false,
                start_date: Some("2026-04-14".to_string()),
                start_time: Some("09:30".to_string()),
                due_date: "2026-04-15".to_string(),
                due_time: Some("20:15".to_string()),
            },
        )
        .expect("should update task");

        assert_eq!(updated.title, "更新后标题");
        assert_eq!(updated.note.as_deref(), Some("已修改"));
        assert_eq!(updated.start_date.as_deref(), Some("2026-04-14"));
        assert_eq!(updated.due_date, "2026-04-15");
        assert_eq!(updated.due_time.as_deref(), Some("20:15"));
    }

    #[test]
    fn set_status_updates_detail_status() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "状态测试".to_string(),
                note: None,
                tag_id: None,
                priority: None,
                all_day: true,
                start_date: Some("2026-04-13".to_string()),
                start_time: None,
                due_date: "2026-04-13".to_string(),
                due_time: None,
            },
        )
        .expect("should create task");

        let completed = TaskService::set_status(
            &database,
            TaskSetStatusInput {
                series_id: created.series_id.clone(),
                status: "completed".to_string(),
            },
        )
        .expect("should set completed");
        assert_eq!(completed.status, "completed");
        assert!(completed.completed_at.is_some());

        let pending = TaskService::set_status(
            &database,
            TaskSetStatusInput {
                series_id: created.series_id.clone(),
                status: "pending".to_string(),
            },
        )
        .expect("should reset status");
        assert_eq!(pending.status, "pending");
        assert!(pending.completed_at.is_none());
    }

    #[test]
    fn delete_task_removes_detail() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "待删除".to_string(),
                note: None,
                tag_id: None,
                priority: None,
                all_day: true,
                start_date: Some("2026-04-13".to_string()),
                start_time: None,
                due_date: "2026-04-13".to_string(),
                due_time: None,
            },
        )
        .expect("should create task");

        TaskService::delete_task(&database, &created.series_id).expect("should delete task");

        let detail = TaskService::get_task_detail(&database, &created.series_id)
            .expect("should query detail");
        assert!(detail.is_none());
    }

    #[test]
    fn upcoming_query_filters_and_sorts_single_tasks() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "第三个".to_string(),
                note: None,
                tag_id: None,
                priority: Some(3),
                all_day: false,
                start_date: Some("2026-04-15".to_string()),
                start_time: Some("11:00".to_string()),
                due_date: "2026-04-16".to_string(),
                due_time: Some("10:00".to_string()),
            },
        )
        .expect("should create task 1");

        TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "第一个".to_string(),
                note: None,
                tag_id: None,
                priority: Some(1),
                all_day: false,
                start_date: Some("2026-04-13".to_string()),
                start_time: Some("09:00".to_string()),
                due_date: "2026-04-14".to_string(),
                due_time: Some("09:30".to_string()),
            },
        )
        .expect("should create task 2");

        TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "范围外".to_string(),
                note: None,
                tag_id: None,
                priority: Some(2),
                all_day: true,
                start_date: Some("2026-05-01".to_string()),
                start_time: None,
                due_date: "2026-05-01".to_string(),
                due_time: None,
            },
        )
        .expect("should create task 3");

        let tasks = TaskService::upcoming_query(
            &database,
            UpcomingQueryInput {
                start_date: Some("2026-04-13".to_string()),
                day_count: Some(7),
            },
        )
        .expect("should query upcoming");

        assert_eq!(tasks.len(), 2);
        assert_eq!(tasks[0].title, "第一个");
        assert_eq!(tasks[1].title, "第三个");
    }

    #[test]
    fn get_task_editor_returns_editor_projection() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TaskService::create_task(
            &database,
            TaskCreateInput {
                title: "编辑投影".to_string(),
                note: Some("用于表单".to_string()),
                tag_id: None,
                priority: Some(2),
                all_day: false,
                start_date: Some("2026-04-13".to_string()),
                start_time: Some("08:30".to_string()),
                due_date: "2026-04-14".to_string(),
                due_time: Some("19:00".to_string()),
            },
        )
        .expect("should create task");

        let editor = TaskService::get_task_editor(&database, &created.series_id)
            .expect("should get editor")
            .expect("editor should exist");

        assert_eq!(editor.series_id, created.series_id);
        assert_eq!(editor.revision_id, created.revision_id);
        assert_eq!(editor.title, "编辑投影");
        assert_eq!(editor.note.as_deref(), Some("用于表单"));
        assert_eq!(editor.start_date.as_deref(), Some("2026-04-13"));
        assert_eq!(editor.start_time.as_deref(), Some("08:30"));
        assert_eq!(editor.due_date, "2026-04-14");
        assert_eq!(editor.due_time.as_deref(), Some("19:00"));
        assert_eq!(editor.current_status, "pending");
    }

    #[test]
    fn upcoming_query_expands_daily_recurring_tasks_within_window() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        insert_recurring_task(
            &database,
            "隔天回顾",
            "2026-04-10",
            "day",
            2,
            Some("2026-04-18"),
        );

        let tasks = TaskService::upcoming_query(
            &database,
            UpcomingQueryInput {
                start_date: Some("2026-04-13".to_string()),
                day_count: Some(7),
            },
        )
        .expect("should query recurring tasks");

        let due_dates: Vec<String> = tasks.into_iter().map(|item| item.due_date).collect();
        assert_eq!(due_dates, vec!["2026-04-14", "2026-04-16", "2026-04-18"]);
    }

    #[test]
    fn upcoming_query_expands_hourly_recurring_tasks_within_window() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        insert_recurring_task_with_schedule(
            &database,
            "轮询检查",
            "2026-04-10",
            "hour",
            4,
            Some("2026-04-11"),
            false,
            Some(Time::from_hms(20, 0, 0).expect("should build start time")),
            Some(Time::from_hms(21, 0, 0).expect("should build due time")),
            Some(3600),
        );

        let tasks = TaskService::upcoming_query(
            &database,
            UpcomingQueryInput {
                start_date: Some("2026-04-11".to_string()),
                day_count: Some(1),
            },
        )
        .expect("should query hourly recurrence");

        let due_times: Vec<String> = tasks
            .iter()
            .map(|item| {
                item.due_time
                    .clone()
                    .expect("hourly task should have due time")
            })
            .collect();
        assert_eq!(
            due_times,
            vec!["01:00", "05:00", "09:00", "13:00", "17:00", "21:00"]
        );
        assert!(tasks.iter().all(|item| item.due_date == "2026-04-11"));
    }

    #[test]
    fn upcoming_query_clamps_monthly_recurrence_to_month_end() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        insert_recurring_task(
            &database,
            "月底对账",
            "2026-01-31",
            "month",
            1,
            Some("2026-04-30"),
        );

        let tasks = TaskService::upcoming_query(
            &database,
            UpcomingQueryInput {
                start_date: Some("2026-02-01".to_string()),
                day_count: Some(90),
            },
        )
        .expect("should query monthly recurrence");

        let due_dates: Vec<String> = tasks.into_iter().map(|item| item.due_date).collect();
        assert_eq!(due_dates, vec!["2026-02-28", "2026-03-31", "2026-04-30"]);
    }

    #[test]
    fn upcoming_query_applies_override_to_recurring_occurrence() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let (series, revision) =
            insert_recurring_task(&database, "每周复盘", "2026-04-06", "week", 1, None);
        let seed = build_schedule_seed(&revision).expect("should build schedule seed");
        let occurrence = build_scheduled_occurrence(
            &revision,
            &seed,
            shift_recurrence_start(seed.effective_from, "week", 1, 2).expect("should shift date"),
            false,
        )
        .expect("should build occurrence");
        let now = now_rfc3339().expect("should build timestamp");

        database
            .with_transaction(|transaction| {
                TaskOccurrenceOverrideRepository::upsert(
                    transaction,
                    &TaskOccurrenceOverride {
                        id: Uuid::new_v4().to_string(),
                        series_id: series.id.clone(),
                        occurrence_key: occurrence.occurrence_key.clone(),
                        override_start_at: None,
                        override_due_at: None,
                        override_danger_at: None,
                        override_title: Some("每周复盘（已确认）".to_string()),
                        override_note: Some("已单次完成".to_string()),
                        override_tag_id: None,
                        override_priority: Some(1),
                        status: "completed".to_string(),
                        completed_at: Some(now.clone()),
                        cancelled_at: None,
                        detached_as_single: false,
                        created_at: now.clone(),
                        updated_at: now.clone(),
                    },
                )?;
                Ok(())
            })
            .expect("should persist occurrence override");

        let tasks = TaskService::upcoming_query(
            &database,
            UpcomingQueryInput {
                start_date: Some("2026-04-20".to_string()),
                day_count: Some(14),
            },
        )
        .expect("should query recurring tasks with override");

        let overridden = tasks
            .into_iter()
            .find(|item| item.occurrence_key == occurrence.occurrence_key)
            .expect("overridden occurrence should exist");

        assert_eq!(overridden.title, "每周复盘（已确认）");
        assert_eq!(overridden.note.as_deref(), Some("已单次完成"));
        assert_eq!(overridden.priority, Some(1));
        assert_eq!(overridden.status, "completed");
    }
}
