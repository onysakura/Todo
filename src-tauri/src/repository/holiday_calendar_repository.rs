use rusqlite::{params, Connection};

use crate::{db::now_rfc3339, domain::HolidayCalendarDay, error::AppResult};

pub struct HolidayCalendarRepository;

impl HolidayCalendarRepository {
    pub fn list_between(
        connection: &Connection,
        start_date: &str,
        end_date: &str,
    ) -> AppResult<Vec<HolidayCalendarDay>> {
        let mut statement = connection.prepare(
            r#"
        SELECT date, day_type, name, source, updated_at
        FROM holiday_calendar
        WHERE date >= ?1 AND date <= ?2
        ORDER BY date ASC
      "#,
        )?;

        let rows = statement.query_map([start_date, end_date], |row| {
            Ok(HolidayCalendarDay {
                date: row.get(0)?,
                day_type: row.get(1)?,
                name: row.get(2)?,
                source: row.get(3)?,
                updated_at: row.get(4)?,
            })
        })?;

        let mut days = Vec::new();
        for row in rows {
            days.push(row?);
        }
        Ok(days)
    }

    pub fn upsert(
        connection: &Connection,
        date: &str,
        day_type: &str,
        name: Option<&str>,
        source: Option<&str>,
    ) -> AppResult<()> {
        connection.execute(
            r#"
        INSERT INTO holiday_calendar(date, day_type, name, source, updated_at)
        VALUES (?1, ?2, ?3, ?4, ?5)
        ON CONFLICT(date) DO UPDATE SET
          day_type = excluded.day_type,
          name = excluded.name,
          source = excluded.source,
          updated_at = excluded.updated_at
      "#,
            params![date, day_type, name, source, now_rfc3339()?],
        )?;

        Ok(())
    }

    pub fn delete(connection: &Connection, date: &str) -> AppResult<()> {
        connection.execute("DELETE FROM holiday_calendar WHERE date = ?1", [date])?;
        Ok(())
    }
}
