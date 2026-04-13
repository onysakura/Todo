pub struct Migration {
    pub version: i64,
    pub sql: &'static str,
}

pub const MIGRATIONS: &[Migration] = &[Migration {
    version: 1,
    sql: r#"
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS task_series (
      id TEXT PRIMARY KEY,
      kind TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      archived_at TEXT
    );

    CREATE TABLE IF NOT EXISTS task_series_revision (
      id TEXT PRIMARY KEY,
      series_id TEXT NOT NULL,
      effective_from TEXT NOT NULL,
      effective_until TEXT,
      title TEXT NOT NULL,
      note TEXT,
      tag_id TEXT,
      priority INTEGER,
      all_day INTEGER NOT NULL DEFAULT 0,
      start_at_time_part INTEGER,
      due_at_time_part INTEGER,
      duration_seconds INTEGER,
      recurrence_type TEXT,
      recurrence_interval INTEGER,
      recurrence_rule_json TEXT,
      recurrence_until TEXT,
      danger_offset_value INTEGER,
      danger_offset_unit TEXT,
      danger_use_workday INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY(series_id) REFERENCES task_series(id),
      FOREIGN KEY(tag_id) REFERENCES tag(id)
    );

    CREATE TABLE IF NOT EXISTS task_occurrence_override (
      id TEXT PRIMARY KEY,
      series_id TEXT NOT NULL,
      occurrence_key TEXT NOT NULL,
      override_start_at TEXT,
      override_due_at TEXT,
      override_danger_at TEXT,
      override_title TEXT,
      override_note TEXT,
      override_tag_id TEXT,
      override_priority INTEGER,
      status TEXT NOT NULL,
      completed_at TEXT,
      cancelled_at TEXT,
      detached_as_single INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY(series_id) REFERENCES task_series(id),
      FOREIGN KEY(override_tag_id) REFERENCES tag(id),
      UNIQUE(series_id, occurrence_key)
    );

    CREATE TABLE IF NOT EXISTS tag (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      color_value TEXT,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS holiday_calendar (
      date TEXT PRIMARY KEY,
      day_type TEXT NOT NULL,
      name TEXT,
      source TEXT,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS sync_meta (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value_json TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_revision_series_effective_from
      ON task_series_revision(series_id, effective_from);

    CREATE INDEX IF NOT EXISTS idx_override_series_occurrence
      ON task_occurrence_override(series_id, occurrence_key);

    CREATE INDEX IF NOT EXISTS idx_tag_sort_order
      ON tag(sort_order, name);

    CREATE INDEX IF NOT EXISTS idx_holiday_day_type
      ON holiday_calendar(day_type, date);
  "#,
}];
