mod migrations;

use std::{
    fs,
    path::{Path, PathBuf},
    sync::Mutex,
};

use rusqlite::{params, Connection, OptionalExtension};
use serde::Serialize;
use tauri::{AppHandle, Manager};
use time::OffsetDateTime;
use uuid::Uuid;

use crate::{
    error::{AppError, AppResult},
    repository::{sync_meta_repository::SyncMetaRepository, tag_repository::TagRepository},
};

use self::migrations::MIGRATIONS;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct BootstrapStatus {
    pub database_path: String,
    pub schema_version: i64,
    pub table_count: usize,
    pub tables: Vec<String>,
    pub device_id: String,
    pub tag_count: usize,
}

pub struct Database {
    path: PathBuf,
    connection: Mutex<Connection>,
}

impl Database {
    pub fn open_for_app(app: &AppHandle) -> AppResult<Self> {
        let app_data_dir = app
            .path()
            .app_data_dir()
            .map_err(|error| AppError::Path(error.to_string()))?;

        fs::create_dir_all(&app_data_dir)?;

        let db_path = app_data_dir.join("todo.data.sqlite3");
        Self::open_at(&db_path)
    }

    pub fn open_at(path: &Path) -> AppResult<Self> {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)?;
        }

        let connection = Connection::open(path)?;
        connection.execute_batch(
            r#"
        PRAGMA foreign_keys = ON;
        PRAGMA journal_mode = WAL;
        PRAGMA synchronous = NORMAL;
      "#,
        )?;
        connection.busy_timeout(std::time::Duration::from_secs(5))?;

        let database = Self {
            path: path.to_path_buf(),
            connection: Mutex::new(connection),
        };

        database.run_migrations()?;
        database.ensure_device_id()?;

        Ok(database)
    }

    pub fn bootstrap_status(&self) -> AppResult<BootstrapStatus> {
        let schema_version = self.schema_version()?;
        let tables = self.list_tables()?;
        let device_id = self.with_connection(SyncMetaRepository::get_device_id)?;
        let tag_count =
            self.with_connection(|connection| Ok(TagRepository::list(connection)?.len()))?;

        Ok(BootstrapStatus {
            database_path: self.path.display().to_string(),
            schema_version,
            table_count: tables.len(),
            tables,
            device_id,
            tag_count,
        })
    }

    pub fn list_tags(&self) -> AppResult<Vec<crate::domain::Tag>> {
        self.with_connection(TagRepository::list)
    }

    pub fn with_connection<T>(&self, f: impl FnOnce(&Connection) -> AppResult<T>) -> AppResult<T> {
        let guard = self
            .connection
            .lock()
            .map_err(|_| AppError::State("数据库连接锁已损坏".to_string()))?;
        f(&guard)
    }

    #[cfg_attr(not(test), allow(dead_code))]
    pub fn with_transaction<T>(
        &self,
        f: impl FnOnce(&rusqlite::Transaction<'_>) -> AppResult<T>,
    ) -> AppResult<T> {
        let guard = self
            .connection
            .lock()
            .map_err(|_| AppError::State("数据库连接锁已损坏".to_string()))?;
        let transaction = guard.unchecked_transaction()?;
        let result = f(&transaction)?;
        transaction.commit()?;
        Ok(result)
    }

    fn ensure_device_id(&self) -> AppResult<()> {
        self.with_connection(|connection| {
            if SyncMetaRepository::get_device_id(connection)?.is_empty() {
                let device_id = Uuid::new_v4().to_string();
                SyncMetaRepository::upsert(connection, "device_id", &device_id)?;
            }

            Ok(())
        })
    }

    fn list_tables(&self) -> AppResult<Vec<String>> {
        self.with_connection(|connection| {
            let mut statement = connection.prepare(
                r#"
          SELECT name
          FROM sqlite_master
          WHERE type = 'table'
            AND name NOT LIKE 'sqlite_%'
          ORDER BY name
        "#,
            )?;

            let rows = statement.query_map([], |row| row.get::<_, String>(0))?;
            let mut tables = Vec::new();
            for row in rows {
                tables.push(row?);
            }
            Ok(tables)
        })
    }

    fn schema_version(&self) -> AppResult<i64> {
        self.with_connection(|connection| {
            let version = connection
                .query_row(
                    "SELECT COALESCE(MAX(version), 0) FROM schema_migrations",
                    [],
                    |row| row.get::<_, i64>(0),
                )
                .optional()?
                .unwrap_or(0);

            Ok(version)
        })
    }

    fn run_migrations(&self) -> AppResult<()> {
        self.with_connection(|connection| {
            connection.execute_batch(
                r#"
          CREATE TABLE IF NOT EXISTS schema_migrations (
            version INTEGER PRIMARY KEY,
            applied_at TEXT NOT NULL
          );
        "#,
            )?;

            let current_version = connection
                .query_row(
                    "SELECT COALESCE(MAX(version), 0) FROM schema_migrations",
                    [],
                    |row| row.get::<_, i64>(0),
                )
                .optional()?
                .unwrap_or(0);

            for migration in MIGRATIONS {
                if migration.version <= current_version {
                    continue;
                }

                let tx = connection.unchecked_transaction()?;
                tx.execute_batch(migration.sql)?;
                tx.execute(
                    "INSERT INTO schema_migrations(version, applied_at) VALUES (?1, ?2)",
                    params![migration.version, now_rfc3339()?],
                )?;
                tx.commit()?;
            }

            Ok(())
        })
    }
}

pub fn now_rfc3339() -> AppResult<String> {
    OffsetDateTime::now_utc()
        .format(&time::format_description::well_known::Rfc3339)
        .map_err(|error| AppError::Time(error.to_string()))
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;
    use uuid::Uuid;

    use super::Database;
    use crate::{
        domain::{TaskOccurrenceOverride, TaskSeries, TaskSeriesRevision},
        error::AppError,
        repository::{
            sync_meta_repository::SyncMetaRepository, tag_repository::TagRepository,
            task_occurrence_override_repository::TaskOccurrenceOverrideRepository,
            task_series_repository::TaskSeriesRepository,
            task_series_revision_repository::TaskSeriesRevisionRepository,
        },
    };

    #[test]
    fn initializes_database_and_runs_migrations() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");

        let database = Database::open_at(&db_path).expect("should open database");
        let status = database
            .bootstrap_status()
            .expect("should read bootstrap status");

        assert_eq!(status.schema_version, 1);
        assert!(status.tables.contains(&"task_series".to_string()));
        assert!(status.tables.contains(&"sync_meta".to_string()));
        assert!(!status.device_id.is_empty());
    }

    #[test]
    fn tag_repository_supports_create_and_list() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        database
            .with_connection(|connection| {
                TagRepository::create(connection, "收件箱", Some("#335CFF"), 0)?;
                TagRepository::create(connection, "工作", None, 1)?;
                Ok(())
            })
            .expect("should insert tags");

        let tags = database.list_tags().expect("should list tags");
        assert_eq!(tags.len(), 2);
        assert_eq!(tags[0].name, "收件箱");
        assert_eq!(tags[1].name, "工作");
    }

    #[test]
    fn sync_meta_repository_persists_device_id() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let first = database
            .with_connection(SyncMetaRepository::get_device_id)
            .expect("should load device id");
        let second = database
            .with_connection(SyncMetaRepository::get_device_id)
            .expect("should load device id again");

        assert!(!first.is_empty());
        assert_eq!(first, second);
    }

    #[test]
    fn task_repositories_support_round_trip() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let now = super::now_rfc3339().expect("should build timestamp");
        let series_id = Uuid::new_v4().to_string();

        let series = TaskSeries {
            id: series_id.clone(),
            kind: "single".to_string(),
            created_at: now.clone(),
            updated_at: now.clone(),
            archived_at: None,
        };
        let revision = TaskSeriesRevision {
            id: Uuid::new_v4().to_string(),
            series_id: series_id.clone(),
            effective_from: "2026-04-13".to_string(),
            effective_until: None,
            title: "验证数据层".to_string(),
            note: Some("阶段 2".to_string()),
            tag_id: None,
            priority: Some(1),
            all_day: false,
            start_at_time_part: Some(32400),
            due_at_time_part: Some(64800),
            duration_seconds: Some(32400),
            recurrence_type: None,
            recurrence_interval: None,
            recurrence_rule_json: None,
            recurrence_until: None,
            danger_offset_value: Some(1),
            danger_offset_unit: Some("day".to_string()),
            danger_use_workday: false,
            created_at: now.clone(),
            updated_at: now.clone(),
        };
        let occurrence = TaskOccurrenceOverride {
            id: Uuid::new_v4().to_string(),
            series_id: series_id.clone(),
            occurrence_key: "2026-04-13".to_string(),
            override_start_at: Some("2026-04-13T09:00:00Z".to_string()),
            override_due_at: Some("2026-04-13T18:00:00Z".to_string()),
            override_danger_at: Some("2026-04-12T18:00:00Z".to_string()),
            override_title: Some("验证数据层已完成".to_string()),
            override_note: None,
            override_tag_id: None,
            override_priority: Some(2),
            status: "completed".to_string(),
            completed_at: Some("2026-04-13T10:00:00Z".to_string()),
            cancelled_at: None,
            detached_as_single: false,
            created_at: now.clone(),
            updated_at: now.clone(),
        };

        database
            .with_transaction(|transaction| {
                TaskSeriesRepository::create(transaction, &series)?;
                TaskSeriesRevisionRepository::create(transaction, &revision)?;
                TaskOccurrenceOverrideRepository::upsert(transaction, &occurrence)?;
                Ok(())
            })
            .expect("should persist task graph in transaction");

        let loaded_series = database
            .with_connection(|connection| TaskSeriesRepository::get_by_id(connection, &series_id))
            .expect("should load series")
            .expect("series should exist");
        assert_eq!(loaded_series.kind, "single");

        let revisions = database
            .with_connection(|connection| {
                TaskSeriesRevisionRepository::list_by_series_id(connection, &series_id)
            })
            .expect("should load revisions");
        assert_eq!(revisions.len(), 1);
        assert_eq!(revisions[0].title, "验证数据层");

        let loaded_occurrence = database
            .with_connection(|connection| {
                TaskOccurrenceOverrideRepository::get_by_series_and_occurrence(
                    connection,
                    &series_id,
                    "2026-04-13",
                )
            })
            .expect("should load occurrence")
            .expect("occurrence should exist");
        assert_eq!(loaded_occurrence.status, "completed");
    }

    #[test]
    fn transaction_rolls_back_on_error() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let now = super::now_rfc3339().expect("should build timestamp");
        let series_id = Uuid::new_v4().to_string();

        let result: Result<(), AppError> = database.with_transaction(|transaction| {
            TaskSeriesRepository::create(
                transaction,
                &TaskSeries {
                    id: series_id.clone(),
                    kind: "single".to_string(),
                    created_at: now.clone(),
                    updated_at: now.clone(),
                    archived_at: None,
                },
            )?;

            Err(AppError::State("触发回滚".to_string()))
        });

        assert!(result.is_err());

        let loaded_series = database
            .with_connection(|connection| TaskSeriesRepository::get_by_id(connection, &series_id))
            .expect("should query series");
        assert!(loaded_series.is_none());
    }
}
