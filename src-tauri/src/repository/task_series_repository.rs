#![allow(dead_code)]

use rusqlite::{params, Connection, OptionalExtension};

use crate::{domain::TaskSeries, error::AppResult};

pub struct TaskSeriesRepository;

impl TaskSeriesRepository {
    pub fn create(connection: &Connection, series: &TaskSeries) -> AppResult<()> {
        connection.execute(
            r#"
        INSERT INTO task_series(id, kind, created_at, updated_at, archived_at)
        VALUES (?1, ?2, ?3, ?4, ?5)
      "#,
            params![
                series.id,
                series.kind,
                series.created_at,
                series.updated_at,
                series.archived_at
            ],
        )?;

        Ok(())
    }

    pub fn get_by_id(connection: &Connection, id: &str) -> AppResult<Option<TaskSeries>> {
        let mut statement = connection.prepare(
            r#"
        SELECT id, kind, created_at, updated_at, archived_at
        FROM task_series
        WHERE id = ?1
      "#,
        )?;

        let series = statement
            .query_row([id], |row| {
                Ok(TaskSeries {
                    id: row.get(0)?,
                    kind: row.get(1)?,
                    created_at: row.get(2)?,
                    updated_at: row.get(3)?,
                    archived_at: row.get(4)?,
                })
            })
            .optional()?;

        Ok(series)
    }
}
