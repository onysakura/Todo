use rusqlite::{params, Connection, OptionalExtension};

use crate::{db::now_rfc3339, domain::AppSetting, error::AppResult};

pub struct AppSettingsRepository;

impl AppSettingsRepository {
    pub fn list(connection: &Connection) -> AppResult<Vec<AppSetting>> {
        let mut statement = connection.prepare(
            r#"
        SELECT key, value_json, updated_at
        FROM app_settings
        ORDER BY key ASC
      "#,
        )?;

        let rows = statement.query_map([], |row| {
            Ok(AppSetting {
                key: row.get(0)?,
                value_json: row.get(1)?,
                updated_at: row.get(2)?,
            })
        })?;

        let mut settings = Vec::new();
        for row in rows {
            settings.push(row?);
        }
        Ok(settings)
    }

    pub fn get(connection: &Connection, key: &str) -> AppResult<Option<AppSetting>> {
        let mut statement = connection.prepare(
            r#"
        SELECT key, value_json, updated_at
        FROM app_settings
        WHERE key = ?1
      "#,
        )?;

        let setting = statement
            .query_row([key], |row| {
                Ok(AppSetting {
                    key: row.get(0)?,
                    value_json: row.get(1)?,
                    updated_at: row.get(2)?,
                })
            })
            .optional()?;

        Ok(setting)
    }

    pub fn upsert(connection: &Connection, key: &str, value_json: &str) -> AppResult<()> {
        connection.execute(
            r#"
        INSERT INTO app_settings(key, value_json, updated_at)
        VALUES (?1, ?2, ?3)
        ON CONFLICT(key) DO UPDATE SET
          value_json = excluded.value_json,
          updated_at = excluded.updated_at
      "#,
            params![key, value_json, now_rfc3339()?],
        )?;

        Ok(())
    }

    pub fn delete(connection: &Connection, key: &str) -> AppResult<()> {
        connection.execute("DELETE FROM app_settings WHERE key = ?1", [key])?;
        Ok(())
    }
}
