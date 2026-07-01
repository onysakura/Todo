//! 危险日与工作日计算服务。
//!
//! 危险日以截止时间为锚点倒推，支持：
//! - 提前若干小时（`hour`）
//! - 提前若干自然日（`day`，`use_workday = false`）
//! - 按工作日倒推（`day`，`use_workday = true`）
//!
//! 若实例存在单次危险日覆盖（`override_danger_at`），则该实例不再按模板重新计算。
//!
//! `danger_at` 统一采用无时区 ISO 字符串 `YYYY-MM-DDTHH:MM:SS`，与 `occurrence_key` 锚点格式一致。

use std::collections::HashMap;

use time::{macros::format_description, Date, Duration, PrimitiveDateTime, Weekday};

use crate::{
    domain::{HolidayCalendarDay, TaskSeriesRevision},
    error::{AppError, AppResult},
    repository::holiday_calendar_repository::HolidayCalendarRepository,
};

const DANGER_UNIT_HOUR: &str = "hour";
const DANGER_UNIT_DAY: &str = "day";
const DAY_TYPE_WORKDAY: &str = "workday";
const DANGER_ANCHOR_FORMAT: &[time::format_description::FormatItem<'static>] =
    format_description!("[year]-[month]-[day]T[hour]:[minute]:[second]");
const DATE_KEY_FORMAT: &[time::format_description::FormatItem<'static>] =
    format_description!("[year]-[month]-[day]");

/// 危险日偏移单位。
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DangerOffsetUnit {
    Hour,
    Day,
}

/// 危险日规则：以截止时间为锚点倒推。
#[derive(Debug, Clone)]
pub struct DangerRule {
    pub offset_value: i64,
    pub offset_unit: DangerOffsetUnit,
    pub use_workday: bool,
}

/// 写入校验：严格解析前端输入的危险日偏移字段。
/// 返回 `None` 表示未配置危险日。
pub fn validate_danger_input(
    offset_value: Option<i64>,
    offset_unit: Option<String>,
    use_workday: bool,
) -> AppResult<Option<DangerRule>> {
    let Some(value) = offset_value else {
        if offset_unit.is_some() || use_workday {
            return Err(AppError::Validation(
                "危险日偏移值缺失时，偏移单位与工作日开关必须为空".to_string(),
            ));
        }
        return Ok(None);
    };

    if value < 0 {
        return Err(AppError::Validation("危险日偏移值不能为负数".to_string()));
    }

    let unit_str = offset_unit
        .as_deref()
        .ok_or_else(|| AppError::Validation("危险日偏移单位缺失".to_string()))?;
    let offset_unit = match unit_str {
        DANGER_UNIT_HOUR => DangerOffsetUnit::Hour,
        DANGER_UNIT_DAY => DangerOffsetUnit::Day,
        other => {
            return Err(AppError::Validation(format!(
                "危险日偏移单位仅支持 hour、day，收到: {other}"
            )))
        }
    };

    if use_workday && offset_unit != DangerOffsetUnit::Day {
        return Err(AppError::Validation(
            "按工作日倒推仅支持天单位".to_string(),
        ));
    }

    Ok(Some(DangerRule {
        offset_value: value,
        offset_unit,
        use_workday,
    }))
}

/// 投影读取：宽容解析版本段中的危险日规则。
/// 脏数据（单位缺失、单位无效、负值、`use_workday` 与单位不匹配等）统一返回 `None`，
/// 避免单条脏数据拖垮整个投影查询。
pub fn resolve_danger_rule(revision: &TaskSeriesRevision) -> Option<DangerRule> {
    let value = revision.danger_offset_value?;
    if value < 0 {
        return None;
    }
    let unit_str = revision.danger_offset_unit.as_deref()?;
    let offset_unit = match unit_str {
        DANGER_UNIT_HOUR => DangerOffsetUnit::Hour,
        DANGER_UNIT_DAY => DangerOffsetUnit::Day,
        _ => return None,
    };
    if revision.danger_use_workday && offset_unit != DangerOffsetUnit::Day {
        return None;
    }
    Some(DangerRule {
        offset_value: value,
        offset_unit,
        use_workday: revision.danger_use_workday,
    })
}

/// 计算危险日时间点（格式化为 `YYYY-MM-DDTHH:MM:SS` 字符串）。
///
/// 优先级：`override_danger_at` > 模板规则计算 > `None`。
pub fn compute_danger_at(
    due_anchor: PrimitiveDateTime,
    rule: Option<&DangerRule>,
    override_danger_at: Option<&str>,
    workday_calculator: &WorkdayCalculator,
) -> AppResult<Option<String>> {
    if let Some(override_str) = override_danger_at {
        let parsed = parse_danger_anchor(override_str)?;
        return Ok(Some(format_danger_anchor(parsed)?));
    }
    let Some(rule) = rule else {
        return Ok(None);
    };
    let danger = match rule.offset_unit {
        DangerOffsetUnit::Hour => due_anchor - Duration::hours(rule.offset_value),
        DangerOffsetUnit::Day => {
            if rule.use_workday {
                workday_calculator.shift_back_workdays(due_anchor, rule.offset_value)?
            } else {
                due_anchor - Duration::days(rule.offset_value)
            }
        }
    };
    Ok(Some(format_danger_anchor(danger)?))
}

/// 解析危险日时间字符串为 `PrimitiveDateTime`。
pub fn parse_danger_anchor(value: &str) -> AppResult<PrimitiveDateTime> {
    PrimitiveDateTime::parse(value, DANGER_ANCHOR_FORMAT).map_err(|error| {
        AppError::Validation(format!(
            "危险日时间格式无效，应为 YYYY-MM-DDTHH:MM:SS: {error}"
        ))
    })
}

/// 格式化危险日时间字符串。
pub fn format_danger_anchor(value: PrimitiveDateTime) -> AppResult<String> {
    value
        .format(DANGER_ANCHOR_FORMAT)
        .map_err(|error| AppError::Time(format!("格式化危险日时间失败: {error}")))
}

/// 工作日计算器：基于 `holiday_calendar` 判定工作日，无记录时按周末 fallback。
pub struct WorkdayCalculator {
    holidays: HashMap<String, HolidayCalendarDay>,
}

impl WorkdayCalculator {
    /// 从数据库加载指定区间的节假日数据。
    pub fn load(
        connection: &rusqlite::Connection,
        range_start: Date,
        range_end: Date,
    ) -> AppResult<Self> {
        let start_str = format_date_key(range_start)?;
        let end_str = format_date_key(range_end)?;
        let days = HolidayCalendarRepository::list_between(connection, &start_str, &end_str)?;
        let mut holidays = HashMap::new();
        for day in days {
            holidays.insert(day.date, day);
        }
        Ok(Self { holidays })
    }

    /// 判定某日是否工作日。
    /// - `holiday_calendar` 有记录：`workday` 类型为工作日（调休上班），其余为非工作日。
    /// - 无记录：按周几 fallback，周一到周五为工作日，周六周日为非工作日。
    pub fn is_workday(&self, date: Date) -> AppResult<bool> {
        let date_str = format_date_key(date)?;
        if let Some(day) = self.holidays.get(&date_str) {
            return Ok(day.day_type == DAY_TYPE_WORKDAY);
        }
        Ok(!is_weekend(date))
    }

    /// 从锚点向前倒推 N 个工作日，保留锚点的时间部分。
    pub fn shift_back_workdays(
        &self,
        anchor: PrimitiveDateTime,
        count: i64,
    ) -> AppResult<PrimitiveDateTime> {
        if count < 0 {
            return Err(AppError::Validation("工作日倒推数不能为负数".to_string()));
        }
        if count == 0 {
            return Ok(anchor);
        }
        let anchor_time = anchor.time();
        let mut cursor = anchor.date();
        let mut remaining = count;
        while remaining > 0 {
            cursor = cursor
                .previous_day()
                .ok_or_else(|| AppError::Time("工作日倒推越界".to_string()))?;
            if self.is_workday(cursor)? {
                remaining -= 1;
            }
        }
        Ok(PrimitiveDateTime::new(cursor, anchor_time))
    }
}

fn format_date_key(date: Date) -> AppResult<String> {
    date.format(DATE_KEY_FORMAT)
        .map_err(|error| AppError::Time(format!("格式化日期失败: {error}")))
}

fn is_weekend(date: Date) -> bool {
    matches!(date.weekday(), Weekday::Saturday | Weekday::Sunday)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::db::Database;
    use tempfile::tempdir;
    use time::Time;

    fn date(year: i32, month: u8, day: u8) -> Date {
        time::Date::from_calendar_date(year, time::Month::try_from(month).unwrap(), day).unwrap()
    }

    fn anchor(year: i32, month: u8, day: u8, hour: u8, minute: u8) -> PrimitiveDateTime {
        PrimitiveDateTime::new(
            date(year, month, day),
            Time::from_hms(hour, minute, 0).unwrap(),
        )
    }

    fn empty_calculator() -> WorkdayCalculator {
        let temp_dir = tempdir().unwrap();
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).unwrap();
        database
            .with_connection(|c| WorkdayCalculator::load(c, date(2026, 1, 1), date(2026, 12, 31)))
            .unwrap()
    }

    #[test]
    fn validate_danger_input_rejects_inconsistent_fields() {
        assert!(validate_danger_input(None, Some("day".to_string()), false).is_err());
        assert!(validate_danger_input(None, None, true).is_err());
        assert!(validate_danger_input(Some(-1), Some("day".to_string()), false).is_err());
        assert!(validate_danger_input(Some(1), None, false).is_err());
        assert!(validate_danger_input(Some(1), Some("week".to_string()), false).is_err());
        assert!(validate_danger_input(Some(1), Some("hour".to_string()), true).is_err());
    }

    #[test]
    fn validate_danger_input_accepts_valid_combinations() {
        assert!(validate_danger_input(None, None, false).unwrap().is_none());
        let hour_rule = validate_danger_input(Some(2), Some("hour".to_string()), false).unwrap();
        assert_eq!(hour_rule.unwrap().offset_unit, DangerOffsetUnit::Hour);
        let day_rule = validate_danger_input(Some(1), Some("day".to_string()), false).unwrap();
        assert_eq!(day_rule.unwrap().offset_unit, DangerOffsetUnit::Day);
        let workday_rule =
            validate_danger_input(Some(1), Some("day".to_string()), true).unwrap();
        assert!(workday_rule.unwrap().use_workday);
    }

    #[test]
    fn compute_danger_at_hour_offset() {
        let calc = empty_calculator();
        let due = anchor(2026, 4, 14, 18, 0);
        let rule = DangerRule {
            offset_value: 6,
            offset_unit: DangerOffsetUnit::Hour,
            use_workday: false,
        };
        let danger = compute_danger_at(due, Some(&rule), None, &calc).unwrap();
        assert_eq!(danger.unwrap(), "2026-04-14T12:00:00");
    }

    #[test]
    fn compute_danger_at_calendar_day_offset_preserves_time() {
        let calc = empty_calculator();
        let due = anchor(2026, 4, 14, 18, 30);
        let rule = DangerRule {
            offset_value: 2,
            offset_unit: DangerOffsetUnit::Day,
            use_workday: false,
        };
        let danger = compute_danger_at(due, Some(&rule), None, &calc).unwrap();
        assert_eq!(danger.unwrap(), "2026-04-12T18:30:00");
    }

    #[test]
    fn compute_danger_at_workday_offset_skips_weekend() {
        // due=2026-04-13(周一) 18:00，倒推 1 工作日 → 2026-04-10(周五) 18:00
        let calc = empty_calculator();
        let due = anchor(2026, 4, 13, 18, 0);
        let rule = DangerRule {
            offset_value: 1,
            offset_unit: DangerOffsetUnit::Day,
            use_workday: true,
        };
        let danger = compute_danger_at(due, Some(&rule), None, &calc).unwrap();
        assert_eq!(danger.unwrap(), "2026-04-10T18:00:00");
    }

    #[test]
    fn compute_danger_at_workday_offset_skips_multiple_days() {
        // due=2026-04-14(周二) 09:00，倒推 3 工作日 → 周一 4-13、周五 4-10、周四 4-09 → 2026-04-09T09:00
        let calc = empty_calculator();
        let due = anchor(2026, 4, 14, 9, 0);
        let rule = DangerRule {
            offset_value: 3,
            offset_unit: DangerOffsetUnit::Day,
            use_workday: true,
        };
        let danger = compute_danger_at(due, Some(&rule), None, &calc).unwrap();
        assert_eq!(danger.unwrap(), "2026-04-09T09:00:00");
    }

    #[test]
    fn compute_danger_at_override_takes_precedence() {
        let calc = empty_calculator();
        let due = anchor(2026, 4, 14, 18, 0);
        let rule = DangerRule {
            offset_value: 2,
            offset_unit: DangerOffsetUnit::Day,
            use_workday: false,
        };
        // 模板计算应为 2026-04-12T18:00:00，但覆盖值优先
        let danger =
            compute_danger_at(due, Some(&rule), Some("2026-04-10T09:00:00"), &calc).unwrap();
        assert_eq!(danger.unwrap(), "2026-04-10T09:00:00");
    }

    #[test]
    fn compute_danger_at_returns_none_when_no_rule_and_no_override() {
        let calc = empty_calculator();
        let due = anchor(2026, 4, 14, 18, 0);
        let danger = compute_danger_at(due, None, None, &calc).unwrap();
        assert!(danger.is_none());
    }

    #[test]
    fn workday_calculator_respects_holiday_and_workday_override() {
        // 2026-05-01(周五) 劳动节 holiday，2026-05-09(周六) 调休 workday
        let temp_dir = tempdir().unwrap();
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).unwrap();
        database
            .with_transaction(|tx| {
                HolidayCalendarRepository::upsert(
                    tx,
                    "2026-05-01",
                    "holiday",
                    Some("劳动节"),
                    None,
                )?;
                HolidayCalendarRepository::upsert(
                    tx,
                    "2026-05-09",
                    "workday",
                    Some("调休"),
                    None,
                )?;
                Ok(())
            })
            .unwrap();
        let calc = database
            .with_connection(|c| WorkdayCalculator::load(c, date(2026, 5, 1), date(2026, 5, 10)))
            .unwrap();
        // 周五 5-1 是 holiday → 非工作日
        assert!(!calc.is_workday(date(2026, 5, 1)).unwrap());
        // 周六 5-9 调休 → 工作日
        assert!(calc.is_workday(date(2026, 5, 9)).unwrap());
        // 周日 5-10 无记录 → 非工作日
        assert!(!calc.is_workday(date(2026, 5, 10)).unwrap());
        // 周一 5-4 无记录 → 工作日
        assert!(calc.is_workday(date(2026, 5, 4)).unwrap());
    }

    #[test]
    fn shift_back_workdays_skips_holiday() {
        // due=2026-05-04(周一)，倒推 1 工作日 → 跳过 5-1(周五 holiday) 与周末，到 4-30(周四)
        let temp_dir = tempdir().unwrap();
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).unwrap();
        database
            .with_transaction(|tx| {
                HolidayCalendarRepository::upsert(
                    tx,
                    "2026-05-01",
                    "holiday",
                    Some("劳动节"),
                    None,
                )?;
                Ok(())
            })
            .unwrap();
        let calc = database
            .with_connection(|c| WorkdayCalculator::load(c, date(2026, 4, 25), date(2026, 5, 10)))
            .unwrap();
        let due = anchor(2026, 5, 4, 9, 0);
        let result = calc.shift_back_workdays(due, 1).unwrap();
        assert_eq!(result, anchor(2026, 4, 30, 9, 0));
    }

    #[test]
    fn resolve_danger_rule_tolerates_dirty_data() {
        let mut revision = TaskSeriesRevision {
            id: "r1".to_string(),
            series_id: "s1".to_string(),
            effective_from: "2026-04-13".to_string(),
            effective_until: None,
            title: "t".to_string(),
            note: None,
            tag_id: None,
            priority: None,
            all_day: false,
            start_at_time_part: None,
            due_at_time_part: None,
            duration_seconds: None,
            recurrence_type: None,
            recurrence_interval: None,
            recurrence_rule_json: None,
            recurrence_until: None,
            danger_offset_value: None,
            danger_offset_unit: None,
            danger_use_workday: false,
            created_at: "2026-04-13T00:00:00Z".to_string(),
            updated_at: "2026-04-13T00:00:00Z".to_string(),
        };
        // 未配置
        assert!(resolve_danger_rule(&revision).is_none());
        // 缺单位
        revision.danger_offset_value = Some(1);
        assert!(resolve_danger_rule(&revision).is_none());
        // 非法单位
        revision.danger_offset_unit = Some("week".to_string());
        assert!(resolve_danger_rule(&revision).is_none());
        // 有效天单位
        revision.danger_offset_unit = Some("day".to_string());
        let rule = resolve_danger_rule(&revision).unwrap();
        assert_eq!(rule.offset_unit, DangerOffsetUnit::Day);
        assert_eq!(rule.offset_value, 1);
        // use_workday + hour 不匹配 → None
        revision.danger_offset_unit = Some("hour".to_string());
        revision.danger_use_workday = true;
        assert!(resolve_danger_rule(&revision).is_none());
    }
}
