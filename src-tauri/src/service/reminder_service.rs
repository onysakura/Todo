use serde::{Deserialize, Serialize};
use time::format_description;
use time::{Date, Month, OffsetDateTime, Time};

use crate::{
    db::Database,
    error::{AppError, AppResult},
    service::task_service::{TaskListItemDto, TaskService, UpcomingQueryInput},
};

const ISO_FORMAT: &str = "[year]-[month]-[day]T[hour]:[minute]:[second]";
const DATE_FORMAT: &str = "[year]-[month]-[day]";
const TIME_FORMAT: &str = "[hour]:[minute]";

/// 提醒种类：`danger`（危险日）/ `due`（截止）。
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum ReminderKind {
    Danger,
    Due,
}

/// 单条提醒项。
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct ReminderItem {
    pub series_id: String,
    pub occurrence_key: String,
    pub title: String,
    /// 触发时间，无时区 ISO 字符串 `YYYY-MM-DDTHH:MM:SS`（与 `danger_at` 锚点一致）。
    pub trigger_at: String,
    pub kind: ReminderKind,
    /// 通知正文，取任务备注；为空则为 `None`。
    pub payload: Option<String>,
}

/// 一次提醒计划计算结果。
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct ReminderPlan {
    pub items: Vec<ReminderItem>,
    pub window_start: String,
    pub window_end: String,
}

pub struct ReminderService;

impl ReminderService {
    /// 计算落在 `[window_start, window_end]` 内的近期提醒项。
    ///
    /// 内部复用 `TaskService::upcoming_query` 投影（按天覆盖整个窗口跨度），
    /// 再按精确到分钟的 `danger_at`（优先）或 `due_at` 过滤。
    /// 每个未完成实例最多产生一条提醒：`danger_at` 命中则取 `danger`，否则取 `due`。
    pub fn compute_reminder_plan(
        database: &Database,
        window_start: OffsetDateTime,
        window_end: OffsetDateTime,
    ) -> AppResult<ReminderPlan> {
        let iso_fmt = format_description::parse(ISO_FORMAT)
            .map_err(|error| AppError::Time(error.to_string()))?;
        let date_fmt = format_description::parse(DATE_FORMAT)
            .map_err(|error| AppError::Time(error.to_string()))?;

        if window_end < window_start {
            return Ok(ReminderPlan {
                items: Vec::new(),
                window_start: window_start.format(&iso_fmt)
                    .map_err(|error| AppError::Time(error.to_string()))?,
                window_end: window_end.format(&iso_fmt)
                    .map_err(|error| AppError::Time(error.to_string()))?,
            });
        }

        let start_date = window_start.date();
        let end_date = window_end.date();
        let day_count = ((end_date - start_date).whole_days() as u32) + 1;
        let start_date_str = start_date.format(&date_fmt)
            .map_err(|error| AppError::Time(error.to_string()))?;

        let items = TaskService::upcoming_query(
            database,
            UpcomingQueryInput {
                start_date: Some(start_date_str),
                day_count: Some(day_count),
            },
        )?;

        let mut reminders: Vec<ReminderItem> = Vec::new();
        for item in items.iter().filter(|item| item.status == "pending") {
            if let Some(reminder) = build_reminder_for_item(item, window_start, window_end, &iso_fmt)? {
                reminders.push(reminder);
            }
        }

        reminders.sort_by(|left, right| left.trigger_at.cmp(&right.trigger_at));

        Ok(ReminderPlan {
            items: reminders,
            window_start: window_start.format(&iso_fmt)
                .map_err(|error| AppError::Time(error.to_string()))?,
            window_end: window_end.format(&iso_fmt)
                .map_err(|error| AppError::Time(error.to_string()))?,
        })
    }
}

fn build_reminder_for_item(
    item: &TaskListItemDto,
    window_start: OffsetDateTime,
    window_end: OffsetDateTime,
    iso_fmt: &time::format_description::BorrowedFormatItem,
) -> AppResult<Option<ReminderItem>> {
    let danger_dt = item
        .danger_at
        .as_deref()
        .map(|raw| parse_iso(raw))
        .transpose()?;

    if let Some(trigger) = danger_dt {
        if trigger >= window_start && trigger <= window_end {
            return Ok(Some(ReminderItem {
                series_id: item.series_id.clone(),
                occurrence_key: item.occurrence_key.clone(),
                title: item.title.clone(),
                trigger_at: trigger.format(iso_fmt).map_err(|e| AppError::Time(e.to_string()))?,
                kind: ReminderKind::Danger,
                payload: item.note.clone(),
            }));
        }
    }

    if let Some(due_dt) = build_due_datetime(item)? {
        if due_dt >= window_start && due_dt <= window_end {
            return Ok(Some(ReminderItem {
                series_id: item.series_id.clone(),
                occurrence_key: item.occurrence_key.clone(),
                title: item.title.clone(),
                trigger_at: due_dt.format(iso_fmt).map_err(|e| AppError::Time(e.to_string()))?,
                kind: ReminderKind::Due,
                payload: item.note.clone(),
            }));
        }
    }

    Ok(None)
}

/// 由 `due_date` + `due_time` 构造截止触发时间；全天任务用 `00:00`。
fn build_due_datetime(item: &TaskListItemDto) -> AppResult<Option<OffsetDateTime>> {
    let date_fmt = format_description::parse(DATE_FORMAT)
        .map_err(|error| AppError::Time(error.to_string()))?;
    let time_fmt = format_description::parse(TIME_FORMAT)
        .map_err(|error| AppError::Time(error.to_string()))?;

    let date = Date::parse(&item.due_date, &date_fmt)
        .map_err(|error| AppError::Time(format!("解析截止日期失败 {date}: {error}", date = item.due_date)))?;

    let time = if item.all_day {
        Time::from_hms(0, 0, 0).map_err(|e| AppError::Time(e.to_string()))?
    } else if let Some(raw_time) = item.due_time.as_deref() {
        Time::parse(raw_time, &time_fmt)
            .map_err(|error| AppError::Time(format!("解析截止时间失败 {time}: {error}", time = raw_time)))?
    } else {
        Time::from_hms(0, 0, 0).map_err(|e| AppError::Time(e.to_string()))?
    };

    Ok(Some(date.with_time(time).assume_utc()))
}

fn parse_iso(raw: &str) -> AppResult<OffsetDateTime> {
    let iso_fmt = format_description::parse(ISO_FORMAT)
        .map_err(|error| AppError::Time(error.to_string()))?;
    OffsetDateTime::parse(raw, &iso_fmt)
        .or_else(|_| {
            // 兼容带时区的 ISO 串：先按 Rfc3339 解析再统一为 UTC。
            OffsetDateTime::parse(
                raw,
                &time::format_description::well_known::Rfc3339,
            )
        })
        .map_err(|error| AppError::Time(format!("解析时间失败 {raw}: {error}")))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::service::task_service::{TaskCreateInput, TaskSetStatusInput, TaskService};
    use tempfile::tempdir;

    fn open_temp_database() -> Database {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        Database::open_at(&db_path).expect("should open database")
    }

    fn create_task(
        database: &Database,
        title: &str,
        due_date: &str,
        due_time: Option<&str>,
        all_day: bool,
        danger_offset_value: Option<i64>,
        danger_offset_unit: Option<&str>,
    ) {
        TaskService::create_task(
            database,
            TaskCreateInput {
                title: title.to_string(),
                note: None,
                tag_id: None,
                priority: None,
                all_day,
                start_date: Some(due_date.to_string()),
                start_time: due_time.map(|t| t.to_string()),
                due_date: due_date.to_string(),
                due_time: due_time.map(|t| t.to_string()),
                recurrence_type: None,
                recurrence_interval: None,
                recurrence_until: None,
                danger_offset_value,
                danger_offset_unit: danger_offset_unit.map(|s| s.to_string()),
                danger_use_workday: false,
            },
        )
        .expect("should create task");
    }

    fn window(on: (u32, u8, u8), to: (u32, u8, u8)) -> (OffsetDateTime, OffsetDateTime) {
        let (m1, d1, h1) = on;
        let (m2, d2, h2) = to;
        let start = Date::from_calendar_date(2026, Month::from(m1), d1)
            .unwrap()
            .with_time(Time::from_hms(h1, 0, 0).unwrap())
            .assume_utc();
        let end = Date::from_calendar_date(2026, Month::from(m2), d2)
            .unwrap()
            .with_time(Time::from_hms(h2, 0, 0).unwrap())
            .assume_utc();
        (start, end)
    }

    #[test]
    fn danger_at_in_window_produces_danger_reminder() {
        let database = open_temp_database();
        create_task(&database, "危险日任务", "2026-07-02", Some("10:00"), false, Some(1), Some("hour"));

        let (start, end) = window((7, 2, 8), (7, 2, 11));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");

        assert_eq!(plan.items.len(), 1);
        assert_eq!(plan.items[0].kind, ReminderKind::Danger);
        assert_eq!(plan.items[0].trigger_at, "2026-07-02T09:00:00");
    }

    #[test]
    fn due_at_in_window_without_danger_produces_due_reminder() {
        let database = open_temp_database();
        create_task(&database, "截止任务", "2026-07-02", Some("10:00"), false, None, None);

        let (start, end) = window((7, 2, 8), (7, 2, 11));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");

        assert_eq!(plan.items.len(), 1);
        assert_eq!(plan.items[0].kind, ReminderKind::Due);
        assert_eq!(plan.items[0].trigger_at, "2026-07-02T10:00:00");
    }

    #[test]
    fn completed_or_cancelled_instances_are_skipped() {
        let database = open_temp_database();
        create_task(&database, "已完成", "2026-07-02", Some("10:00"), false, None, None);
        let last = {
            let items = TaskService::upcoming_query(
                &database,
                UpcomingQueryInput { start_date: Some("2026-07-02".to_string()), day_count: Some(1) },
            )
            .expect("query");
            items.last().expect("at least one").series_id.clone()
        };
        TaskService::set_status(
            &database,
            TaskSetStatusInput { series_id: last, status: "completed".to_string() },
        )
        .expect("set status");

        let (start, end) = window((7, 2, 8), (7, 2, 11));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");
        assert!(plan.items.is_empty());
    }

    #[test]
    fn due_outside_time_window_is_filtered() {
        let database = open_temp_database();
        // 截止 14:00 在当天 upcoming_query 范围内，但 reminder 窗口 08:00-11:00 外。
        create_task(&database, "下午任务", "2026-07-02", Some("14:00"), false, None, None);

        let (start, end) = window((7, 2, 8), (7, 2, 11));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");
        assert!(plan.items.is_empty());
    }

    #[test]
    fn danger_at_takes_priority_over_due_at() {
        let database = open_temp_database();
        // danger_at 08:30 与 due_at 09:30 均落在窗口 08:00-11:00 内，应只产生 danger 项。
        create_task(&database, "优先任务", "2026-07-02", Some("09:30"), false, Some(1), Some("hour"));

        let (start, end) = window((7, 2, 8), (7, 2, 11));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");

        assert_eq!(plan.items.len(), 1);
        assert_eq!(plan.items[0].kind, ReminderKind::Danger);
        assert_eq!(plan.items[0].trigger_at, "2026-07-02T08:30:00");
    }

    #[test]
    fn items_sorted_by_trigger_at_ascending() {
        let database = open_temp_database();
        create_task(&database, "截止10点", "2026-07-02", Some("10:00"), false, None, None);
        create_task(&database, "危险08点半", "2026-07-02", Some("09:30"), false, Some(1), Some("hour"));

        let (start, end) = window((7, 2, 8), (7, 2, 11));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");

        assert_eq!(plan.items.len(), 2);
        assert_eq!(plan.items[0].trigger_at, "2026-07-02T08:30:00");
        assert_eq!(plan.items[1].trigger_at, "2026-07-02T10:00:00");
    }

    #[test]
    fn all_day_task_uses_midnight_as_due_trigger() {
        let database = open_temp_database();
        create_task(&database, "全天任务", "2026-07-02", None, true, None, None);

        let (start, end) = window((7, 2, 0), (7, 2, 1));
        let plan = ReminderService::compute_reminder_plan(&database, start, end)
            .expect("should compute plan");

        assert_eq!(plan.items.len(), 1);
        assert_eq!(plan.items[0].kind, ReminderKind::Due);
        assert_eq!(plan.items[0].trigger_at, "2026-07-02T00:00:00");
    }
}
