use serde::{Deserialize, Serialize};
use time::{
    format_description::well_known::Iso8601, macros::format_description, Date, Duration,
    PrimitiveDateTime, Time,
};
use uuid::Uuid;

use crate::{
    db::{now_rfc3339, Database},
    domain::{TaskSeries, TaskSeriesRevision},
    error::{AppError, AppResult},
    repository::{
        tag_repository::TagRepository,
        task_occurrence_override_repository::TaskOccurrenceOverrideRepository,
        task_series_repository::TaskSeriesRepository,
        task_series_revision_repository::TaskSeriesRevisionRepository,
    },
};

const STATUS_PENDING: &str = "pending";
const TASK_KIND_SINGLE: &str = "single";
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
        database.with_connection(|connection| {
            let series = match TaskSeriesRepository::get_by_id(connection, series_id)? {
                Some(series) => series,
                None => return Ok(None),
            };

            let mut revisions =
                TaskSeriesRevisionRepository::list_by_series_id(connection, series_id)?;
            let revision = revisions
                .drain(..)
                .next()
                .ok_or_else(|| AppError::State("任务缺少版本段数据".to_string()))?;

            let (start_date, start_time, due_date, due_time, occurrence_key) =
                reconstruct_task_schedule(&revision)?;

            let occurrence_override =
                TaskOccurrenceOverrideRepository::get_by_series_and_occurrence(
                    connection,
                    series_id,
                    &occurrence_key,
                )?;

            let detail = TaskDetailDto {
                series_id: series.id,
                revision_id: revision.id,
                occurrence_key,
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
            };

            Ok(Some(detail))
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
    let effective_from = parse_date(&revision.effective_from, "版本开始日期")?;
    let start_time = revision
        .start_at_time_part
        .map(seconds_to_time)
        .transpose()?;
    let duration = revision.duration_seconds.unwrap_or(0);
    let due_anchor = PrimitiveDateTime::new(effective_from, start_time.unwrap_or(Time::MIDNIGHT))
        + Duration::seconds(duration);
    let due_date = due_anchor.date();
    let due_time = if revision.all_day {
        None
    } else if let Some(value) = revision.due_at_time_part {
        Some(seconds_to_time(value)?)
    } else {
        Some(due_anchor.time())
    };

    let start_date = Some(
        effective_from
            .format(DATE_FORMAT)
            .map_err(|error| AppError::Time(format!("格式化开始日期失败: {error}")))?,
    );
    let start_time = start_time.map(format_time).transpose()?;
    let due_date_string = due_date
        .format(DATE_FORMAT)
        .map_err(|error| AppError::Time(format!("格式化截止日期失败: {error}")))?;
    let due_time_string = due_time.map(format_time).transpose()?;

    Ok((
        start_date,
        start_time,
        due_date_string.clone(),
        due_time_string,
        due_date_string,
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

#[cfg(test)]
mod tests {
    use tempfile::tempdir;

    use super::{TaskCreateInput, TaskService};
    use crate::{db::Database, repository::tag_repository::TagRepository};

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
}
