use rusqlite::{params, Connection, OptionalExtension};

use crate::{db::now_rfc3339, domain::SyncMetaEntry, error::AppResult};

pub struct SyncMetaRepository;

impl SyncMetaRepository {
    pub fn get(connection: &Connection, key: &str) -> AppResult<Option<SyncMetaEntry>> {
        let mut statement = connection.prepare(
            r#"
        SELECT key, value, updated_at
        FROM sync_meta
        WHERE key = ?1
      "#,
        )?;

        let entry = statement
            .query_row([key], |row| {
                Ok(SyncMetaEntry {
                    key: row.get(0)?,
                    value: row.get(1)?,
                    updated_at: row.get(2)?,
                })
            })
            .optional()?;

        Ok(entry)
    }

    pub fn get_device_id(connection: &Connection) -> AppResult<String> {
        Ok(Self::get(connection, "device_id")?
            .map(|entry| entry.value)
            .unwrap_or_default())
    }

    pub fn upsert(connection: &Connection, key: &str, value: &str) -> AppResult<()> {
        connection.execute(
            r#"
        INSERT INTO sync_meta(key, value, updated_at)
        VALUES (?1, ?2, ?3)
        ON CONFLICT(key) DO UPDATE SET
          value = excluded.value,
          updated_at = excluded.updated_at
      "#,
            params![key, value, now_rfc3339()?],
        )?;

        Ok(())
    }
}
