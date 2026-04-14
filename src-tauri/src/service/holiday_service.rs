use serde::{Deserialize, Serialize};

use crate::{
    db::Database,
    domain::HolidayCalendarDay,
    error::{AppError, AppResult},
    repository::holiday_calendar_repository::HolidayCalendarRepository,
};

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct HolidayDto {
    pub date: String,
    pub day_type: String,
    pub name: Option<String>,
    pub source: Option<String>,
    pub updated_at: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HolidayListInput {
    pub start_date: String,
    pub end_date: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HolidayUpsertInput {
    pub date: String,
    pub day_type: String,
    pub name: Option<String>,
    pub source: Option<String>,
}

pub struct HolidayService;

impl HolidayService {
    pub fn list(database: &Database, input: HolidayListInput) -> AppResult<Vec<HolidayDto>> {
        let start_date = normalize_date(&input.start_date, "开始日期")?;
        let end_date = normalize_date(&input.end_date, "结束日期")?;
        if start_date > end_date {
            return Err(AppError::Validation("开始日期不能晚于结束日期".to_string()));
        }

        database.with_connection(|connection| {
            let days = HolidayCalendarRepository::list_between(connection, &start_date, &end_date)?;
            Ok(days.into_iter().map(map_day).collect())
        })
    }

    pub fn upsert(database: &Database, input: HolidayUpsertInput) -> AppResult<HolidayDto> {
        let date = normalize_date(&input.date, "节假日日期")?;
        let day_type = normalize_day_type(&input.day_type)?;
        let name = normalize_optional(input.name);
        let source = normalize_optional(input.source);

        database.with_transaction(|transaction| {
            HolidayCalendarRepository::upsert(
                transaction,
                &date,
                &day_type,
                name.as_deref(),
                source.as_deref(),
            )?;

            let day = HolidayCalendarRepository::list_between(transaction, &date, &date)?
                .into_iter()
                .next()
                .ok_or_else(|| AppError::State("节假日写入后读取失败".to_string()))?;
            Ok(map_day(day))
        })
    }

    pub fn delete(database: &Database, date: &str) -> AppResult<()> {
        let date = normalize_date(date, "节假日日期")?;
        database.with_transaction(|transaction| {
            HolidayCalendarRepository::delete(transaction, &date)?;
            Ok(())
        })
    }
}

fn normalize_date(value: &str, field_name: &str) -> AppResult<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation(format!("{field_name}不能为空")));
    }
    if trimmed.len() != 10 || &trimmed[4..5] != "-" || &trimmed[7..8] != "-" {
        return Err(AppError::Validation(format!(
            "{field_name}格式应为 YYYY-MM-DD"
        )));
    }
    Ok(trimmed.to_string())
}

fn normalize_day_type(value: &str) -> AppResult<String> {
    let trimmed = value.trim();
    match trimmed {
        "workday" | "holiday" | "weekend" => Ok(trimmed.to_string()),
        _ => Err(AppError::Validation(
            "dayType 仅支持 workday、holiday、weekend".to_string(),
        )),
    }
}

fn normalize_optional(value: Option<String>) -> Option<String> {
    value.and_then(|item| {
        let trimmed = item.trim().to_string();
        if trimmed.is_empty() {
            None
        } else {
            Some(trimmed)
        }
    })
}

fn map_day(day: HolidayCalendarDay) -> HolidayDto {
    HolidayDto {
        date: day.date,
        day_type: day.day_type,
        name: day.name,
        source: day.source,
        updated_at: day.updated_at,
    }
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;

    use super::{HolidayListInput, HolidayService, HolidayUpsertInput};
    use crate::db::Database;

    #[test]
    fn upsert_and_list_holidays() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        HolidayService::upsert(
            &database,
            HolidayUpsertInput {
                date: "2026-10-01".to_string(),
                day_type: "holiday".to_string(),
                name: Some("国庆节".to_string()),
                source: Some("manual".to_string()),
            },
        )
        .expect("should upsert holiday");

        let items = HolidayService::list(
            &database,
            HolidayListInput {
                start_date: "2026-10-01".to_string(),
                end_date: "2026-10-07".to_string(),
            },
        )
        .expect("should list holidays");

        assert_eq!(items.len(), 1);
        assert_eq!(items[0].day_type, "holiday");
        assert_eq!(items[0].name.as_deref(), Some("国庆节"));
    }

    #[test]
    fn delete_holiday_removes_record() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        HolidayService::upsert(
            &database,
            HolidayUpsertInput {
                date: "2026-05-01".to_string(),
                day_type: "holiday".to_string(),
                name: Some("劳动节".to_string()),
                source: None,
            },
        )
        .expect("should upsert holiday");

        HolidayService::delete(&database, "2026-05-01").expect("should delete holiday");

        let items = HolidayService::list(
            &database,
            HolidayListInput {
                start_date: "2026-05-01".to_string(),
                end_date: "2026-05-01".to_string(),
            },
        )
        .expect("should list holidays");

        assert!(items.is_empty());
    }
}
