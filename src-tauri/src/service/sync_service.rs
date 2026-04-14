use serde::{Deserialize, Serialize};

use crate::{
    db::Database,
    domain::SyncMetaEntry,
    error::{AppError, AppResult},
    repository::sync_meta_repository::SyncMetaRepository,
};

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SyncMetaItemDto {
    pub key: String,
    pub value: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SyncStatusDto {
    pub remote_etag: Option<String>,
    pub remote_version: Option<String>,
    pub last_sync_at: Option<String>,
    pub local_dirty: bool,
    pub dirty_base_remote_etag: Option<String>,
    pub last_sync_result: Option<String>,
    pub device_id: Option<String>,
    pub raw_items: Vec<SyncMetaItemDto>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SyncMetaSetInput {
    pub key: String,
    pub value: String,
}

pub struct SyncService;

impl SyncService {
    pub fn get_status(database: &Database) -> AppResult<SyncStatusDto> {
        database.with_connection(|connection| {
            let items = SyncMetaRepository::list(connection)?;
            let raw_items: Vec<SyncMetaItemDto> = items.into_iter().map(map_entry).collect();

            Ok(SyncStatusDto {
                remote_etag: lookup(&raw_items, "remote_etag"),
                remote_version: lookup(&raw_items, "remote_version"),
                last_sync_at: lookup(&raw_items, "last_sync_at"),
                local_dirty: lookup(&raw_items, "local_dirty")
                    .map(|value| value == "true")
                    .unwrap_or(false),
                dirty_base_remote_etag: lookup(&raw_items, "dirty_base_remote_etag"),
                last_sync_result: lookup(&raw_items, "last_sync_result"),
                device_id: lookup(&raw_items, "device_id"),
                raw_items,
            })
        })
    }

    pub fn set_meta(database: &Database, input: SyncMetaSetInput) -> AppResult<SyncMetaItemDto> {
        let key = normalize_key(&input.key)?;
        let value = normalize_value(&input.value)?;

        database.with_transaction(|transaction| {
            SyncMetaRepository::upsert(transaction, &key, &value)?;
            let entry = SyncMetaRepository::get(transaction, &key)?
                .ok_or_else(|| AppError::State("同步元数据写入后读取失败".to_string()))?;
            Ok(map_entry(entry))
        })
    }

    pub fn delete_meta(database: &Database, key: &str) -> AppResult<()> {
        let key = normalize_key(key)?;

        database.with_transaction(|transaction| {
            SyncMetaRepository::delete(transaction, &key)?;
            Ok(())
        })
    }
}

fn normalize_key(value: &str) -> AppResult<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("同步元数据键不能为空".to_string()));
    }
    Ok(trimmed.to_string())
}

fn normalize_value(value: &str) -> AppResult<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("同步元数据值不能为空".to_string()));
    }
    Ok(trimmed.to_string())
}

fn map_entry(entry: SyncMetaEntry) -> SyncMetaItemDto {
    SyncMetaItemDto {
        key: entry.key,
        value: entry.value,
        updated_at: entry.updated_at,
    }
}

fn lookup(items: &[SyncMetaItemDto], key: &str) -> Option<String> {
    items
        .iter()
        .find(|item| item.key == key)
        .map(|item| item.value.clone())
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;

    use super::{SyncMetaSetInput, SyncService};
    use crate::db::Database;

    #[test]
    fn get_status_reflects_written_values() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        SyncService::set_meta(
            &database,
            SyncMetaSetInput {
                key: "remote_etag".to_string(),
                value: "etag-001".to_string(),
            },
        )
        .expect("should set etag");
        SyncService::set_meta(
            &database,
            SyncMetaSetInput {
                key: "local_dirty".to_string(),
                value: "true".to_string(),
            },
        )
        .expect("should set dirty flag");

        let status = SyncService::get_status(&database).expect("should get status");
        assert_eq!(status.remote_etag.as_deref(), Some("etag-001"));
        assert!(status.local_dirty);
    }

    #[test]
    fn delete_meta_removes_value_from_status() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        SyncService::set_meta(
            &database,
            SyncMetaSetInput {
                key: "last_sync_result".to_string(),
                value: "success".to_string(),
            },
        )
        .expect("should set status");

        SyncService::delete_meta(&database, "last_sync_result").expect("should delete meta");

        let status = SyncService::get_status(&database).expect("should get status");
        assert_eq!(status.last_sync_result, None);
    }
}
