//! 远端存储抽象与远端元数据模型。
//!
//! 同步采用整库快照：远端维护 `todo.meta.json`（元数据）与 `todo.data.sqlite3`（数据快照）。
//! 核心同步逻辑通过 [`RemoteStore`] trait 访问远端，便于在测试中注入假实现，不依赖真实网络。

use serde::{Deserialize, Serialize};

use crate::error::AppResult;

/// 远端 `todo.meta.json` 模型。
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct RemoteMeta {
    /// 单调递增的版本标识（采用时间戳）。
    pub version: String,
    /// 远端最近更新时间（RFC3339）。
    pub updated_at: String,
    /// 快照字节校验值（hex sha256）。
    pub checksum: String,
    /// 写入该版本的设备标识。
    pub device_id: String,
    /// 快照对应的 schema 版本。
    pub schema_version: i64,
}

/// 拉取到的远端元数据（含服务端 etag）。
#[derive(Debug, Clone)]
pub struct FetchedMeta {
    pub etag: Option<String>,
    pub meta: RemoteMeta,
}

/// 拉取到的远端快照（含服务端 etag 与字节）。
#[derive(Debug, Clone)]
pub struct FetchedSnapshot {
    pub etag: Option<String>,
    pub bytes: Vec<u8>,
}

/// 远端存储抽象。
///
/// - `fetch_meta` 返回 `Ok(None)` 表示远端尚无数据（404）。
/// - 推送方法返回服务端 etag（若服务端提供）。
pub trait RemoteStore {
    fn fetch_meta(&self) -> AppResult<Option<FetchedMeta>>;
    fn push_meta(&self, meta: &RemoteMeta) -> AppResult<Option<String>>;
    fn fetch_snapshot(&self) -> AppResult<FetchedSnapshot>;
    fn push_snapshot(&self, bytes: &[u8]) -> AppResult<Option<String>>;
}
