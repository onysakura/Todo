#![allow(dead_code)]

use rusqlite::{params, Connection};

use crate::{domain::TaskSeriesRevision, error::AppResult};

pub struct TaskSeriesRevisionRepository;

impl TaskSeriesRevisionRepository {
    pub fn create(connection: &Connection, revision: &TaskSeriesRevision) -> AppResult<()> {
        connection.execute(
            r#"
        INSERT INTO task_series_revision(
          id,
          series_id,
          effective_from,
          effective_until,
          title,
          note,
          tag_id,
          priority,
          all_day,
          start_at_time_part,
          due_at_time_part,
          duration_seconds,
          recurrence_type,
          recurrence_interval,
          recurrence_rule_json,
          recurrence_until,
          danger_offset_value,
          danger_offset_unit,
          danger_use_workday,
          created_at,
          updated_at
        )
        VALUES (
          ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11,
          ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21
        )
      "#,
            params![
                revision.id,
                revision.series_id,
                revision.effective_from,
                revision.effective_until,
                revision.title,
                revision.note,
                revision.tag_id,
                revision.priority,
                revision.all_day,
                revision.start_at_time_part,
                revision.due_at_time_part,
                revision.duration_seconds,
                revision.recurrence_type,
                revision.recurrence_interval,
                revision.recurrence_rule_json,
                revision.recurrence_until,
                revision.danger_offset_value,
                revision.danger_offset_unit,
                revision.danger_use_workday,
                revision.created_at,
                revision.updated_at
            ],
        )?;

        Ok(())
    }

    pub fn list_by_series_id(
        connection: &Connection,
        series_id: &str,
    ) -> AppResult<Vec<TaskSeriesRevision>> {
        let mut statement = connection.prepare(
            r#"
        SELECT
          id,
          series_id,
          effective_from,
          effective_until,
          title,
          note,
          tag_id,
          priority,
          all_day,
          start_at_time_part,
          due_at_time_part,
          duration_seconds,
          recurrence_type,
          recurrence_interval,
          recurrence_rule_json,
          recurrence_until,
          danger_offset_value,
          danger_offset_unit,
          danger_use_workday,
          created_at,
          updated_at
        FROM task_series_revision
        WHERE series_id = ?1
        ORDER BY effective_from ASC, created_at ASC
      "#,
        )?;

        let rows = statement.query_map([series_id], |row| {
            Ok(TaskSeriesRevision {
                id: row.get(0)?,
                series_id: row.get(1)?,
                effective_from: row.get(2)?,
                effective_until: row.get(3)?,
                title: row.get(4)?,
                note: row.get(5)?,
                tag_id: row.get(6)?,
                priority: row.get(7)?,
                all_day: row.get(8)?,
                start_at_time_part: row.get(9)?,
                due_at_time_part: row.get(10)?,
                duration_seconds: row.get(11)?,
                recurrence_type: row.get(12)?,
                recurrence_interval: row.get(13)?,
                recurrence_rule_json: row.get(14)?,
                recurrence_until: row.get(15)?,
                danger_offset_value: row.get(16)?,
                danger_offset_unit: row.get(17)?,
                danger_use_workday: row.get(18)?,
                created_at: row.get(19)?,
                updated_at: row.get(20)?,
            })
        })?;

        let mut revisions = Vec::new();
        for row in rows {
            revisions.push(row?);
        }
        Ok(revisions)
    }
}
