#![allow(dead_code)]

use rusqlite::{params, Connection, OptionalExtension};

use crate::{domain::TaskOccurrenceOverride, error::AppResult};

pub struct TaskOccurrenceOverrideRepository;

impl TaskOccurrenceOverrideRepository {
    pub fn upsert(
        connection: &Connection,
        override_record: &TaskOccurrenceOverride,
    ) -> AppResult<()> {
        connection.execute(
            r#"
        INSERT INTO task_occurrence_override(
          id,
          series_id,
          occurrence_key,
          override_start_at,
          override_due_at,
          override_danger_at,
          override_title,
          override_note,
          override_tag_id,
          override_priority,
          status,
          completed_at,
          cancelled_at,
          detached_as_single,
          created_at,
          updated_at
        )
        VALUES (
          ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8,
          ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16
        )
        ON CONFLICT(series_id, occurrence_key) DO UPDATE SET
          override_start_at = excluded.override_start_at,
          override_due_at = excluded.override_due_at,
          override_danger_at = excluded.override_danger_at,
          override_title = excluded.override_title,
          override_note = excluded.override_note,
          override_tag_id = excluded.override_tag_id,
          override_priority = excluded.override_priority,
          status = excluded.status,
          completed_at = excluded.completed_at,
          cancelled_at = excluded.cancelled_at,
          detached_as_single = excluded.detached_as_single,
          updated_at = excluded.updated_at
      "#,
            params![
                override_record.id,
                override_record.series_id,
                override_record.occurrence_key,
                override_record.override_start_at,
                override_record.override_due_at,
                override_record.override_danger_at,
                override_record.override_title,
                override_record.override_note,
                override_record.override_tag_id,
                override_record.override_priority,
                override_record.status,
                override_record.completed_at,
                override_record.cancelled_at,
                override_record.detached_as_single,
                override_record.created_at,
                override_record.updated_at
            ],
        )?;

        Ok(())
    }

    pub fn get_by_series_and_occurrence(
        connection: &Connection,
        series_id: &str,
        occurrence_key: &str,
    ) -> AppResult<Option<TaskOccurrenceOverride>> {
        let mut statement = connection.prepare(
            r#"
        SELECT
          id,
          series_id,
          occurrence_key,
          override_start_at,
          override_due_at,
          override_danger_at,
          override_title,
          override_note,
          override_tag_id,
          override_priority,
          status,
          completed_at,
          cancelled_at,
          detached_as_single,
          created_at,
          updated_at
        FROM task_occurrence_override
        WHERE series_id = ?1 AND occurrence_key = ?2
      "#,
        )?;

        let record = statement
            .query_row([series_id, occurrence_key], |row| {
                Ok(TaskOccurrenceOverride {
                    id: row.get(0)?,
                    series_id: row.get(1)?,
                    occurrence_key: row.get(2)?,
                    override_start_at: row.get(3)?,
                    override_due_at: row.get(4)?,
                    override_danger_at: row.get(5)?,
                    override_title: row.get(6)?,
                    override_note: row.get(7)?,
                    override_tag_id: row.get(8)?,
                    override_priority: row.get(9)?,
                    status: row.get(10)?,
                    completed_at: row.get(11)?,
                    cancelled_at: row.get(12)?,
                    detached_as_single: row.get(13)?,
                    created_at: row.get(14)?,
                    updated_at: row.get(15)?,
                })
            })
            .optional()?;

        Ok(record)
    }

    pub fn delete_by_series_id(connection: &Connection, series_id: &str) -> AppResult<()> {
        connection.execute(
            "DELETE FROM task_occurrence_override WHERE series_id = ?1",
            [series_id],
        )?;
        Ok(())
    }
}
