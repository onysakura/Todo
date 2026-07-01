use std::{cell::RefCell, fs, path::PathBuf};

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

use crate::{
    db::{now_rfc3339, Database},
    domain::SyncMetaEntry,
    error::{AppError, AppResult},
    repository::sync_meta_repository::SyncMetaRepository,
    service::remote_store::{FetchedMeta, RemoteMeta, RemoteStore},
    service::settings_service::{SettingsDto, SettingsService},
    service::webdav_store::WebDavRemoteStore,
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
    pub last_recovery_path: Option<String>,
    pub last_recovery_at: Option<String>,
    pub last_recovery_reason: Option<String>,
    pub raw_items: Vec<SyncMetaItemDto>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SyncMetaSetInput {
    pub key: String,
    pub value: String,
}

/// 一次同步执行的结果摘要。
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SyncOutcome {
    /// pushed / pulled / up_to_date / conflict_recovered / error
    pub action: String,
    pub message: String,
    pub recovery_path: Option<String>,
}

impl SyncOutcome {
    fn pushed(message: &str) -> Self {
        Self {
            action: "pushed".to_string(),
            message: message.to_string(),
            recovery_path: None,
        }
    }
    fn pulled(message: &str) -> Self {
        Self {
            action: "pulled".to_string(),
            message: message.to_string(),
            recovery_path: None,
        }
    }
    fn up_to_date(message: &str) -> Self {
        Self {
            action: "up_to_date".to_string(),
            message: message.to_string(),
            recovery_path: None,
        }
    }
    fn conflict_recovered(message: &str, path: String) -> Self {
        Self {
            action: "conflict_recovered".to_string(),
            message: message.to_string(),
            recovery_path: Some(path),
        }
    }
    fn error(message: String) -> Self {
        Self {
            action: "error".to_string(),
            message,
            recovery_path: None,
        }
    }
}

/// 在线保存前检查结果。
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SaveCheckResult {
    /// ok / conflict / offline
    pub status: String,
    pub message: String,
}

impl SaveCheckResult {
    fn ok(message: &str) -> Self {
        Self {
            status: "ok".to_string(),
            message: message.to_string(),
        }
    }
    fn conflict(message: &str) -> Self {
        Self {
            status: "conflict".to_string(),
            message: message.to_string(),
        }
    }
    fn offline(message: String) -> Self {
        Self {
            status: "offline".to_string(),
            message,
        }
    }
}

const REMOTE_ETAG: &str = "remote_etag";
const REMOTE_VERSION: &str = "remote_version";
const LAST_SYNC_AT: &str = "last_sync_at";
const LOCAL_DIRTY: &str = "local_dirty";
const DIRTY_BASE_REMOTE_ETAG: &str = "dirty_base_remote_etag";
const LAST_SYNC_RESULT: &str = "last_sync_result";
const LAST_RECOVERY_PATH: &str = "last_recovery_path";
const LAST_RECOVERY_AT: &str = "last_recovery_at";
const LAST_RECOVERY_REASON: &str = "last_recovery_reason";

pub struct SyncService;

impl SyncService {
    pub fn get_status(database: &Database) -> AppResult<SyncStatusDto> {
        database.with_connection(|connection| {
            let items = SyncMetaRepository::list(connection)?;
            let raw_items: Vec<SyncMetaItemDto> = items.into_iter().map(map_entry).collect();

            Ok(SyncStatusDto {
                remote_etag: lookup(&raw_items, REMOTE_ETAG),
                remote_version: lookup(&raw_items, REMOTE_VERSION),
                last_sync_at: lookup(&raw_items, LAST_SYNC_AT),
                local_dirty: lookup(&raw_items, LOCAL_DIRTY)
                    .map(|value| value == "true")
                    .unwrap_or(false),
                dirty_base_remote_etag: lookup(&raw_items, DIRTY_BASE_REMOTE_ETAG),
                last_sync_result: lookup(&raw_items, LAST_SYNC_RESULT),
                device_id: lookup(&raw_items, "device_id"),
                last_recovery_path: lookup(&raw_items, LAST_RECOVERY_PATH),
                last_recovery_at: lookup(&raw_items, LAST_RECOVERY_AT),
                last_recovery_reason: lookup(&raw_items, LAST_RECOVERY_REASON),
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

    /// 执行一次同步（启动 / 手动 / 保存后触发）。
    pub fn run_sync(database: &Database, store: &dyn RemoteStore) -> AppResult<SyncOutcome> {
        let baseline_version = read_meta_value(database, REMOTE_VERSION)?;
        let local_dirty = read_bool(database, LOCAL_DIRTY)?;
        let device_id = database.with_connection(SyncMetaRepository::get_device_id)?;
        let schema_version = database.schema_version()?;

        let remote = match store.fetch_meta() {
            Ok(value) => value,
            Err(error) => {
                record_result(database, &format!("error: {error}"))?;
                return Ok(SyncOutcome::error(format!("同步失败：{error}")));
            }
        };

        let outcome = match remote {
            None => {
                push_local(database, store, &device_id, schema_version)?;
                SyncOutcome::pushed("已将本地数据上传至远端")
            }
            Some(fetched) => {
                let remote_unchanged = baseline_version
                    .as_ref()
                    .map(|value| value == &fetched.meta.version)
                    .unwrap_or(false);

                if remote_unchanged {
                    if local_dirty {
                        push_local(database, store, &device_id, schema_version)?;
                        SyncOutcome::pushed("本地改动已上传至远端")
                    } else {
                        set_last_sync(database, "success")?;
                        SyncOutcome::up_to_date("已是最新")
                    }
                } else if local_dirty {
                    let recovery = export_recovery(database)?;
                    pull_remote(database, store, &fetched)?;
                    record_recovery(
                        database,
                        &recovery,
                        "远端已变化，本地离线改动已转为恢复副本",
                    )?;
                    SyncOutcome::conflict_recovered(
                        "远端已变化，本地离线改动已转为恢复副本",
                        recovery.to_string_lossy().to_string(),
                    )
                } else {
                    pull_remote(database, store, &fetched)?;
                    SyncOutcome::pulled("已从远端拉取最新数据")
                }
            }
        };

        Ok(outcome)
    }

    /// 在线保存前检查：远端未变化或为空时允许保存；远端已变化时拦截；网络不通时按离线处理。
    pub fn check_before_save(
        database: &Database,
        store: &dyn RemoteStore,
    ) -> AppResult<SaveCheckResult> {
        let baseline_version = read_meta_value(database, REMOTE_VERSION)?;

        match store.fetch_meta() {
            Err(error) => Ok(SaveCheckResult::offline(format!("无法连接远端：{error}"))),
            Ok(None) => Ok(SaveCheckResult::ok("远端为空，可安全保存")),
            Ok(Some(fetched)) => {
                let unchanged = baseline_version.as_deref() == Some(fetched.meta.version.as_str());
                if unchanged {
                    Ok(SaveCheckResult::ok("远端未变化，可安全保存"))
                } else {
                    Ok(SaveCheckResult::conflict("远端已变化，请先同步"))
                }
            }
        }
    }

    /// 标记本地存在待推送的改动（保存后调用，离线场景下尤为关键）。
    pub fn mark_dirty(database: &Database) -> AppResult<()> {
        let baseline_etag = read_meta_value(database, REMOTE_ETAG)?;
        write_bool(database, LOCAL_DIRTY, true)?;
        if let Some(etag) = baseline_etag {
            write_meta_value(database, DIRTY_BASE_REMOTE_ETAG, &etag)?;
        }
        Ok(())
    }

    /// 从 `app_settings` 读取 WebDAV 配置并构建远端存储。
    pub fn build_store(database: &Database) -> AppResult<WebDavRemoteStore> {
        let settings = SettingsService::get(database)?;
        let url = setting_string(&settings, "sync.webdavUrl")?
            .ok_or_else(|| AppError::Validation("未配置 WebDAV 地址".to_string()))?;
        let user = setting_string(&settings, "sync.webdavUser")?.unwrap_or_default();
        let password = setting_string(&settings, "sync.webdavPassword")?.unwrap_or_default();
        Ok(WebDavRemoteStore::new(&url, &user, &password))
    }
}

fn push_local(
    database: &Database,
    store: &dyn RemoteStore,
    device_id: &str,
    schema_version: i64,
) -> AppResult<()> {
    let upload_path = recovery_dir(database).join("upload.snapshot.sqlite3");
    let _ = fs::remove_file(&upload_path);
    database.export_snapshot(&upload_path)?;
    let bytes = fs::read(&upload_path)?;
    let checksum = hex_sha256(&bytes);

    store.push_snapshot(&bytes)?;

    let now = now_rfc3339()?;
    let meta = RemoteMeta {
        version: now.clone(),
        updated_at: now.clone(),
        checksum,
        device_id: device_id.to_string(),
        schema_version,
    };
    let meta_etag = store.push_meta(&meta)?;

    set_optional_meta(database, REMOTE_ETAG, meta_etag.as_deref())?;
    write_meta_value(database, REMOTE_VERSION, &meta.version)?;
    write_meta_value(database, LAST_SYNC_AT, &now)?;

    // 并发写校验：重新导出比对 checksum，仅当推送期间无新写入时才清除 dirty。
    let verify_path = recovery_dir(database).join("verify.snapshot.sqlite3");
    let _ = fs::remove_file(&verify_path);
    database.export_snapshot(&verify_path)?;
    let verify_checksum = hex_sha256(&fs::read(&verify_path)?);
    let _ = fs::remove_file(&verify_path);
    let _ = fs::remove_file(&upload_path);
    write_bool(database, LOCAL_DIRTY, verify_checksum != meta.checksum)?;

    record_result(database, "success")?;
    Ok(())
}

fn pull_remote(database: &Database, store: &dyn RemoteStore, fetched: &FetchedMeta) -> AppResult<()> {
    let snapshot = store.fetch_snapshot()?;
    let actual_checksum = hex_sha256(&snapshot.bytes);
    if actual_checksum != fetched.meta.checksum {
        return Err(AppError::Sync(
            "远端快照校验失败，已保留本地数据".to_string(),
        ));
    }

    let temp_path = recovery_dir(database).join("download.snapshot.sqlite3");
    let _ = fs::remove_file(&temp_path);
    fs::write(&temp_path, &snapshot.bytes)?;
    database.import_snapshot(&temp_path)?;
    let _ = fs::remove_file(&temp_path);

    set_optional_meta(database, REMOTE_ETAG, fetched.etag.as_deref())?;
    write_meta_value(database, REMOTE_VERSION, &fetched.meta.version)?;
    write_meta_value(database, LAST_SYNC_AT, &now_rfc3339()?)?;
    write_bool(database, LOCAL_DIRTY, false)?;
    record_result(database, "success")?;
    Ok(())
}

fn export_recovery(database: &Database) -> AppResult<PathBuf> {
    let dir = recovery_dir(database);
    let stamp = now_rfc3339()?.replace([':', '.'], "-");
    let path = dir.join(format!("todo.data.recovery.{stamp}.sqlite3"));
    database.export_snapshot(&path)?;
    Ok(path)
}

fn record_recovery(database: &Database, path: &PathBuf, reason: &str) -> AppResult<()> {
    write_meta_value(database, LAST_RECOVERY_PATH, &path.to_string_lossy())?;
    write_meta_value(database, LAST_RECOVERY_AT, &now_rfc3339()?)?;
    write_meta_value(database, LAST_RECOVERY_REASON, reason)?;
    Ok(())
}

fn recovery_dir(database: &Database) -> PathBuf {
    let mut path = database
        .path()
        .parent()
        .map(|value| value.to_path_buf())
        .unwrap_or_default();
    path.push("recovery");
    let _ = fs::create_dir_all(&path);
    path
}

fn read_meta_value(database: &Database, key: &str) -> AppResult<Option<String>> {
    database.with_connection(|connection| {
        Ok(SyncMetaRepository::get(connection, key)?.map(|entry| entry.value))
    })
}

fn write_meta_value(database: &Database, key: &str, value: &str) -> AppResult<()> {
    database.with_transaction(|transaction| {
        SyncMetaRepository::upsert(transaction, key, value)?;
        Ok(())
    })
}

fn set_optional_meta(database: &Database, key: &str, value: Option<&str>) -> AppResult<()> {
    match value {
        Some(value) => write_meta_value(database, key, value),
        None => database.with_transaction(|transaction| {
            SyncMetaRepository::delete(transaction, key)?;
            Ok(())
        }),
    }
}

fn read_bool(database: &Database, key: &str) -> AppResult<bool> {
    Ok(read_meta_value(database, key)?
        .map(|value| value == "true")
        .unwrap_or(false))
}

fn write_bool(database: &Database, key: &str, value: bool) -> AppResult<()> {
    write_meta_value(database, key, if value { "true" } else { "false" })
}

fn record_result(database: &Database, result: &str) -> AppResult<()> {
    write_meta_value(database, LAST_SYNC_RESULT, result)
}

fn set_last_sync(database: &Database, result: &str) -> AppResult<()> {
    write_meta_value(database, LAST_SYNC_AT, &now_rfc3339()?)?;
    write_meta_value(database, LAST_SYNC_RESULT, result)?;
    Ok(())
}

fn setting_string(settings: &SettingsDto, key: &str) -> AppResult<Option<String>> {
    match settings.items.iter().find(|item| item.key == key) {
        None => Ok(None),
        Some(item) => Ok(Some(serde_json::from_str::<String>(&item.value_json)?)),
    }
}

fn hex_sha256(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    let result = hasher.finalize();
    result.iter().map(|byte| format!("{byte:02x}")).collect()
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
    use std::cell::RefCell;

    use tempfile::tempdir;

    use super::{SaveCheckResult, SyncMetaSetInput, SyncOutcome, SyncService};
    use crate::db::Database;
    use crate::error::AppError;
    use crate::repository::tag_repository::TagRepository;
    use crate::service::remote_store::{
        FetchedMeta, FetchedSnapshot, RemoteMeta, RemoteStore,
    };

    /// 内存版远端存储，用于不依赖真实网络的同步集成测试。
    struct FakeRemoteStore {
        meta: RefCell<Option<RemoteMeta>>,
        meta_etag: RefCell<Option<String>>,
        snapshot: RefCell<Option<Vec<u8>>>,
        fetch_meta_error: RefCell<Option<String>>,
        fetch_snapshot_error: RefCell<Option<String>>,
        next_etag: RefCell<usize>,
    }

    impl FakeRemoteStore {
        fn new() -> Self {
            Self {
                meta: RefCell::new(None),
                meta_etag: RefCell::new(None),
                snapshot: RefCell::new(None),
                fetch_meta_error: RefCell::new(None),
                fetch_snapshot_error: RefCell::new(None),
                next_etag: RefCell::new(1),
            }
        }

        fn set_remote(&self, meta: RemoteMeta, bytes: Vec<u8>) {
            *self.meta.borrow_mut() = Some(meta);
            *self.snapshot.borrow_mut() = Some(bytes);
            let mut next = self.next_etag.borrow_mut();
            *self.meta_etag.borrow_mut() = Some(format!("etag-{}", *next));
            *next += 1;
        }

        fn clear_remote(&self) {
            *self.meta.borrow_mut() = None;
            *self.meta_etag.borrow_mut() = None;
            *self.snapshot.borrow_mut() = None;
        }

        fn set_fetch_meta_error(&self, message: &str) {
            *self.fetch_meta_error.borrow_mut() = Some(message.to_string());
        }

        fn set_fetch_snapshot_error(&self, message: &str) {
            *self.fetch_snapshot_error.borrow_mut() = Some(message.to_string());
        }

        fn next_etag(&self) -> String {
            let mut next = self.next_etag.borrow_mut();
            let value = format!("etag-{}", *next);
            *next += 1;
            value
        }

        fn remote_meta(&self) -> Option<RemoteMeta> {
            self.meta.borrow().clone()
        }
    }

    impl RemoteStore for FakeRemoteStore {
        fn fetch_meta(&self) -> Result<Option<FetchedMeta>, AppError> {
            if let Some(message) = self.fetch_meta_error.borrow().as_ref() {
                return Err(AppError::Sync(message.clone()));
            }
            Ok(self
                .meta
                .borrow()
                .as_ref()
                .map(|meta| FetchedMeta {
                    etag: self.meta_etag.borrow().clone(),
                    meta: meta.clone(),
                }))
        }

        fn push_meta(&self, meta: &RemoteMeta) -> Result<Option<String>, AppError> {
            *self.meta.borrow_mut() = Some(meta.clone());
            let etag = self.next_etag();
            *self.meta_etag.borrow_mut() = Some(etag.clone());
            Ok(Some(etag))
        }

        fn fetch_snapshot(&self) -> Result<FetchedSnapshot, AppError> {
            if let Some(message) = self.fetch_snapshot_error.borrow().as_ref() {
                return Err(AppError::Sync(message.clone()));
            }
            Ok(FetchedSnapshot {
                etag: self.meta_etag.borrow().clone(),
                bytes: self
                    .snapshot
                    .borrow()
                    .clone()
                    .ok_or_else(|| AppError::Sync("远端快照不存在".to_string()))?,
            })
        }

        fn push_snapshot(&self, bytes: &[u8]) -> Result<Option<String>, AppError> {
            *self.snapshot.borrow_mut() = Some(bytes.to_vec());
            Ok(Some(self.next_etag()))
        }
    }

    fn sha256_hex(bytes: &[u8]) -> String {
        use sha2::{Digest, Sha256};
        let mut hasher = Sha256::new();
        hasher.update(bytes);
        let result = hasher.finalize();
        result.iter().map(|byte| format!("{byte:02x}")).collect()
    }

    fn tag_names(database: &Database) -> Vec<String> {
        database
            .with_connection(TagRepository::list)
            .expect("should list tags")
            .into_iter()
            .map(|tag| tag.name)
            .collect()
    }

    fn export_db_bytes(database: &Database) -> Vec<u8> {
        let dir = tempdir().expect("should create temp dir");
        let path = dir.path().join("export.sqlite3");
        database.export_snapshot(&path).expect("should export");
        std::fs::read(&path).expect("should read export")
    }

    fn remote_meta_with(database: &Database, version: &str) -> RemoteMeta {
        let bytes = export_db_bytes(database);
        let checksum = sha256_hex(&bytes);
        RemoteMeta {
            version: version.to_string(),
            updated_at: "2026-07-01T00:00:00Z".to_string(),
            checksum,
            device_id: "remote-device".to_string(),
            schema_version: database.schema_version().expect("schema version"),
        }
    }

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

    #[test]
    fn initial_push_when_remote_empty() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        database
            .with_connection(|c| TagRepository::create(c, "本地标签", None, 0))
            .expect("should create tag");
        let store = FakeRemoteStore::new();

        let outcome = SyncService::run_sync(&database, &store).expect("should run sync");

        assert_eq!(outcome.action, "pushed");
        assert!(store.remote_meta().is_some());
        let status = SyncService::get_status(&database).expect("should get status");
        assert!(status.remote_version.is_some());
        assert!(!status.local_dirty);
        assert_eq!(status.last_sync_result.as_deref(), Some("success"));
    }

    #[test]
    fn up_to_date_when_remote_unchanged() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();

        SyncService::run_sync(&database, &store).expect("initial push");
        let outcome = SyncService::run_sync(&database, &store).expect("second sync");

        assert_eq!(outcome.action, "up_to_date");
    }

    #[test]
    fn push_when_local_dirty_and_remote_unchanged() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();

        SyncService::run_sync(&database, &store).expect("initial push");
        let first_version = SyncService::get_status(&database)
            .expect("status")
            .remote_version
            .clone();

        SyncService::mark_dirty(&database).expect("should mark dirty");
        let outcome = SyncService::run_sync(&database, &store).expect("dirty sync");

        assert_eq!(outcome.action, "pushed");
        let status = SyncService::get_status(&database).expect("status");
        assert!(!status.local_dirty);
        // 版本号应更新（推送生成新版本）
        assert_ne!(status.remote_version.as_deref(), first_version.as_deref());
    }

    #[test]
    fn pull_when_remote_changed_and_not_dirty() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        database
            .with_connection(|c| TagRepository::create(c, "本地标签", None, 0))
            .expect("should create tag");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");

        // 另一台设备的数据覆盖远端
        let remote_dir = tempdir().expect("should create remote temp dir");
        let remote_db_path = remote_dir.path().join("todo.data.sqlite3");
        let remote_db = Database::open_at(&remote_db_path).expect("should open remote db");
        remote_db
            .with_connection(|c| TagRepository::create(c, "远端标签", None, 0))
            .expect("should create remote tag");
        store.set_remote(remote_meta_with(&remote_db, "remote-v2"), export_db_bytes(&remote_db));

        let outcome = SyncService::run_sync(&database, &store).expect("pull sync");

        assert_eq!(outcome.action, "pulled");
        assert_eq!(tag_names(&database), vec!["远端标签".to_string()]);
        let status = SyncService::get_status(&database).expect("status");
        assert_eq!(status.remote_version.as_deref(), Some("remote-v2"));
        assert!(!status.local_dirty);
    }

    #[test]
    fn conflict_recovery_when_dirty_and_remote_changed() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        database
            .with_connection(|c| TagRepository::create(c, "本地标签", None, 0))
            .expect("should create tag");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");

        SyncService::mark_dirty(&database).expect("mark dirty");

        let remote_dir = tempdir().expect("should create remote temp dir");
        let remote_db_path = remote_dir.path().join("todo.data.sqlite3");
        let remote_db = Database::open_at(&remote_db_path).expect("should open remote db");
        remote_db
            .with_connection(|c| TagRepository::create(c, "远端标签", None, 0))
            .expect("should create remote tag");
        store.set_remote(remote_meta_with(&remote_db, "remote-v2"), export_db_bytes(&remote_db));

        let outcome = SyncService::run_sync(&database, &store).expect("conflict sync");

        assert_eq!(outcome.action, "conflict_recovered");
        assert!(outcome.recovery_path.is_some());
        // 本地已被远端覆盖
        assert_eq!(tag_names(&database), vec!["远端标签".to_string()]);
        let status = SyncService::get_status(&database).expect("status");
        assert!(!status.local_dirty);
        assert!(status.last_recovery_path.is_some());
        assert!(status.last_recovery_reason.is_some());
        // 恢复副本文件存在
        let recovery_path = status.last_recovery_path.unwrap();
        assert!(std::fs::metadata(&recovery_path).is_ok());
    }

    #[test]
    fn network_error_keeps_dirty_and_records_result() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();
        store.set_fetch_meta_error("连接超时");

        SyncService::mark_dirty(&database).expect("mark dirty");
        let outcome = SyncService::run_sync(&database, &store).expect("should return outcome");

        assert_eq!(outcome.action, "error");
        let status = SyncService::get_status(&database).expect("status");
        assert!(status.local_dirty);
        assert!(status.last_sync_result.as_deref().unwrap().starts_with("error"));
    }

    #[test]
    fn checksum_mismatch_preserves_local() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        database
            .with_connection(|c| TagRepository::create(c, "本地标签", None, 0))
            .expect("should create tag");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");

        // 远端 meta 声明的 checksum 与实际快照不符
        let remote_dir = tempdir().expect("should create remote temp dir");
        let remote_db_path = remote_dir.path().join("todo.data.sqlite3");
        let remote_db = Database::open_at(&remote_db_path).expect("should open remote db");
        remote_db
            .with_connection(|c| TagRepository::create(c, "远端标签", None, 0))
            .expect("should create remote tag");
        let bytes = export_db_bytes(&remote_db);
        let mut meta = remote_meta_with(&remote_db, "remote-v2");
        meta.checksum = "deadbeef".to_string();
        store.set_remote(meta, bytes);

        let result = SyncService::run_sync(&database, &store);

        assert!(result.is_err());
        // 本地保留原数据
        assert_eq!(tag_names(&database), vec!["本地标签".to_string()]);
    }

    #[test]
    fn check_before_save_returns_ok_when_remote_unchanged() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");

        let result = SyncService::check_before_save(&database, &store).expect("check");
        assert_eq!(result.status, "ok");
    }

    #[test]
    fn check_before_save_returns_conflict_when_remote_changed() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");

        let remote_dir = tempdir().expect("should create remote temp dir");
        let remote_db_path = remote_dir.path().join("todo.data.sqlite3");
        let remote_db = Database::open_at(&remote_db_path).expect("should open remote db");
        store.set_remote(remote_meta_with(&remote_db, "remote-v2"), export_db_bytes(&remote_db));

        let result = SyncService::check_before_save(&database, &store).expect("check");
        assert_eq!(result.status, "conflict");
    }

    #[test]
    fn check_before_save_returns_offline_on_network_error() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();
        store.set_fetch_meta_error("连接超时");

        let result = SyncService::check_before_save(&database, &store).expect("check");
        assert_eq!(result.status, "offline");
    }

    #[test]
    fn check_before_save_ok_when_remote_empty() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();

        let result = SyncService::check_before_save(&database, &store).expect("check");
        assert_eq!(result.status, "ok");
    }

    #[test]
    fn mark_dirty_sets_dirty_and_base_etag() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");
        let baseline_etag = SyncService::get_status(&database)
            .expect("status")
            .remote_etag
            .clone();

        SyncService::mark_dirty(&database).expect("mark dirty");

        let status = SyncService::get_status(&database).expect("status");
        assert!(status.local_dirty);
        assert_eq!(status.dirty_base_remote_etag, baseline_etag);
    }

    #[test]
    fn device_id_preserved_after_pull() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");
        let local_device_id = SyncService::get_status(&database)
            .expect("status")
            .device_id
            .clone()
            .expect("device id");
        let store = FakeRemoteStore::new();
        SyncService::run_sync(&database, &store).expect("initial push");

        let remote_dir = tempdir().expect("should create remote temp dir");
        let remote_db_path = remote_dir.path().join("todo.data.sqlite3");
        let remote_db = Database::open_at(&remote_db_path).expect("should open remote db");
        store.set_remote(remote_meta_with(&remote_db, "remote-v2"), export_db_bytes(&remote_db));

        SyncService::run_sync(&database, &store).expect("pull");

        let after = SyncService::get_status(&database).expect("status");
        assert_eq!(after.device_id.as_deref(), Some(local_device_id.as_str()));
    }

    #[test]
    fn save_check_result_variants_serialize() {
        let ok = SaveCheckResult::ok("ok");
        assert_eq!(ok.status, "ok");
        let conflict = SaveCheckResult::conflict("c");
        assert_eq!(conflict.status, "conflict");
        let offline = SaveCheckResult::offline("o".to_string());
        assert_eq!(offline.status, "offline");
    }

    #[test]
    fn sync_outcome_variants_build() {
        assert_eq!(SyncOutcome::pushed("x").action, "pushed");
        assert_eq!(SyncOutcome::pulled("x").action, "pulled");
        assert_eq!(SyncOutcome::up_to_date("x").action, "up_to_date");
        assert_eq!(
            SyncOutcome::conflict_recovered("x", "p".to_string()).action,
            "conflict_recovered"
        );
        assert_eq!(SyncOutcome::error("x".to_string()).action, "error");
    }
}
