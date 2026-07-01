//! WebDAV 远端存储实现（基于 `ureq`）。
//!
//! 仅由 Rust 侧访问，前端不直接连接 WebDAV。404 视为远端尚无数据。

use base64::Engine;

use crate::error::{AppError, AppResult};

use super::remote_store::{FetchedMeta, FetchedSnapshot, RemoteMeta, RemoteStore};

const META_FILE: &str = "todo.meta.json";
const SNAPSHOT_FILE: &str = "todo.data.sqlite3";

/// 基于 HTTP Basic 认证的 WebDAV 远端存储。
pub struct WebDavRemoteStore {
    base_url: String,
    auth_header: String,
}

impl WebDavRemoteStore {
    pub fn new(base_url: &str, user: &str, password: &str) -> Self {
        Self {
            base_url: base_url.trim_end_matches('/').to_string(),
            auth_header: build_basic_auth(user, password),
        }
    }

    fn meta_url(&self) -> String {
        format!("{}/{}", self.base_url, META_FILE)
    }

    fn snapshot_url(&self) -> String {
        format!("{}/{}", self.base_url, SNAPSHOT_FILE)
    }
}

impl RemoteStore for WebDavRemoteStore {
    fn fetch_meta(&self) -> AppResult<Option<FetchedMeta>> {
        let response = match ureq::get(&self.meta_url())
            .set("Authorization", &self.auth_header)
            .call()
        {
            Ok(response) => response,
            Err(ureq::Error::Status(404, _)) => return Ok(None),
            Err(error) => {
                return Err(AppError::Sync(format!("远端元数据拉取失败: {error}")));
            }
        };
        let etag = response.header("etag").map(|value| value.to_string());
        let body = response
            .into_string()
            .map_err(|error| AppError::Sync(format!("远端元数据读取失败: {error}")))?;
        let meta: RemoteMeta = serde_json::from_str(&body)
            .map_err(|error| AppError::Sync(format!("远端元数据解析失败: {error}")))?;
        Ok(Some(FetchedMeta { etag, meta }))
    }

    fn push_meta(&self, meta: &RemoteMeta) -> AppResult<Option<String>> {
        let body = serde_json::to_string(meta)?;
        let response = ureq::put(&self.meta_url())
            .set("Authorization", &self.auth_header)
            .set("Content-Type", "application/json")
            .send_string(&body)
            .map_err(|error| AppError::Sync(format!("远端元数据推送失败: {error}")))?;
        Ok(response.header("etag").map(|value| value.to_string()))
    }

    fn fetch_snapshot(&self) -> AppResult<FetchedSnapshot> {
        let response = ureq::get(&self.snapshot_url())
            .set("Authorization", &self.auth_header)
            .call()
            .map_err(|error| AppError::Sync(format!("远端快照拉取失败: {error}")))?;
        let etag = response.header("etag").map(|value| value.to_string());
        let bytes = response
            .into_bytes()
            .map_err(|error| AppError::Sync(format!("远端快照读取失败: {error}")))?;
        Ok(FetchedSnapshot { etag, bytes })
    }

    fn push_snapshot(&self, bytes: &[u8]) -> AppResult<Option<String>> {
        let response = ureq::put(&self.snapshot_url())
            .set("Authorization", &self.auth_header)
            .set("Content-Type", "application/octet-stream")
            .send_bytes(bytes)
            .map_err(|error| AppError::Sync(format!("远端快照推送失败: {error}")))?;
        Ok(response.header("etag").map(|value| value.to_string()))
    }
}

fn build_basic_auth(user: &str, password: &str) -> String {
    let credentials = format!("{user}:{password}");
    let encoded = base64::engine::general_purpose::STANDARD.encode(credentials.as_bytes());
    format!("Basic {encoded}")
}
