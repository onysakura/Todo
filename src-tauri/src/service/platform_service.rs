use std::collections::{HashMap, HashSet};
use std::sync::Mutex;

use serde::Serialize;
use tauri::{AppHandle, Manager, Wry};
use thiserror::Error;
use time::format_description;
use time::OffsetDateTime;

use crate::service::reminder_service::{ReminderKind, ReminderPlan};

/// 平台能力错误。
#[derive(Debug, Error)]
pub enum PlatformError {
    /// 当前平台不支持该能力（如 Android 暂未实现托盘/通知调度）。
    #[error("当前平台不支持该能力")]
    NotSupported,
    #[error("平台权限被拒绝: {0}")]
    PermissionDenied(String),
    #[error("平台错误: {0}")]
    Platform(String),
}

pub type PlatformResult<T> = Result<T, PlatformError>;

/// 单条通知规格。
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct NotificationSpec {
    /// 稳定标识，格式 `series_id::occurrence_key::kind`。
    pub key: String,
    pub title: String,
    pub body: String,
    /// 触发时间，无时区 ISO 字符串 `YYYY-MM-DDTHH:MM:SS`。
    pub trigger_at: String,
}

/// 已注册的通知任务句柄（desktop 用 tokio 延迟任务实现定时触发）。
pub struct RegisteredNotifications {
    handles: Mutex<HashMap<String, tauri::async_runtime::JoinHandle<()>>>,
}

impl RegisteredNotifications {
    pub fn new() -> Self {
        Self {
            handles: Mutex::new(HashMap::new()),
        }
    }
}

impl Default for RegisteredNotifications {
    fn default() -> Self {
        Self::new()
    }
}

const ISO_FORMAT: &str = "[year]-[month]-[day]T[hour]:[minute]:[second]";

/// 将提醒计划转换为通知规格列表（纯函数，便于测试）。
pub fn plan_to_specs(plan: &ReminderPlan) -> Vec<NotificationSpec> {
    plan.items
        .iter()
        .map(|item| {
            let kind_str = match item.kind {
                ReminderKind::Danger => "danger",
                ReminderKind::Due => "due",
            };
            let kind_label = match item.kind {
                ReminderKind::Danger => "危险日",
                ReminderKind::Due => "截止",
            };
            NotificationSpec {
                key: format!("{}::{}::{}", item.series_id, item.occurrence_key, kind_str),
                title: format!("{}：{}", kind_label, item.title),
                body: item.payload.clone().unwrap_or_default(),
                trigger_at: item.trigger_at.clone(),
            }
        })
        .collect()
}

/// 显示主窗口；若窗口已销毁则在 desktop 端重新创建。
pub fn show_main_window(app: &AppHandle<Wry>) -> PlatformResult<()> {
    if let Some(window) = app.get_web_window("main") {
        window
            .show()
            .map_err(|error| PlatformError::Platform(error.to_string()))?;
        window
            .set_focus()
            .map_err(|error| PlatformError::Platform(error.to_string()))?;
        return Ok(());
    }
    #[cfg(not(mobile))]
    {
        create_main_window(app)?;
        return Ok(());
    }
    #[cfg(mobile)]
    {
        let _ = app;
        Err(PlatformError::NotSupported)
    }
}

/// 销毁主窗口（保留进程）。
pub fn close_main_window(app: &AppHandle<Wry>) -> PlatformResult<()> {
    if let Some(window) = app.get_web_window("main") {
        window
            .destroy()
            .map_err(|error| PlatformError::Platform(error.to_string()))?;
    }
    Ok(())
}

/// 取消全部已注册通知。
pub fn cancel_all_notifications(app: &AppHandle<Wry>) -> PlatformResult<()> {
    #[cfg(not(mobile))]
    {
        let registered = app.state::<RegisteredNotifications>();
        let mut map = registered
            .handles
            .lock()
            .map_err(|error| PlatformError::Platform(error.to_string()))?;
        for (_key, handle) in map.drain() {
            handle.abort();
        }
        Ok(())
    }
    #[cfg(mobile)]
    {
        let _ = app;
        Err(PlatformError::NotSupported)
    }
}

/// 先取消全部已注册通知，再按计划重新调度。
pub fn schedule_reminder_plan(
    app: &AppHandle<Wry>,
    plan: &ReminderPlan,
) -> PlatformResult<()> {
    #[cfg(not(mobile))]
    {
        use tauri_plugin_notification::NotificationExt;

        let specs = plan_to_specs(plan);
        let registered = app.state::<RegisteredNotifications>();
        let mut map = registered
            .handles
            .lock()
            .map_err(|error| PlatformError::Platform(error.to_string()))?;

        // 取消上一轮已注册任务，避免重复触发。
        for (_key, handle) in map.drain() {
            handle.abort();
        }

        let iso_fmt = format_description::parse(ISO_FORMAT)
            .map_err(|error| PlatformError::Platform(error.to_string()))?;
        let now = OffsetDateTime::now_utc();

        for spec in specs {
            let trigger = match OffsetDateTime::parse(&spec.trigger_at, &iso_fmt) {
                Ok(value) => value,
                Err(_) => continue,
            };
            if trigger <= now {
                // 已过期的提醒跳过，避免历史提醒刷屏。
                continue;
            }
            let seconds = (trigger - now).whole_seconds();
            if seconds < 0 {
                continue;
            }
            let duration = std::time::Duration::from_secs(seconds as u64);
            let app_handle = app.clone();
            let key = spec.key.clone();
            let title = spec.title.clone();
            let body = spec.body.clone();
            let handle = tauri::async_runtime::spawn(async move {
                tokio::time::sleep(duration).await;
                let _ = app_handle
                    .notification()
                    .builder()
                    .identifier(&key)
                    .title(&title)
                    .body(&body)
                    .show();
            });
            map.insert(spec.key, handle);
        }
        Ok(())
    }
    #[cfg(mobile)]
    {
        let _ = (app, plan);
        Err(PlatformError::NotSupported)
    }
}

/// 在 desktop 端重建主窗口（窗口已销毁时唤起使用）。
#[cfg(not(mobile))]
fn create_main_window(app: &AppHandle<Wry>) -> PlatformResult<()> {
    use tauri::WebviewUrl;
    use tauri::WebviewWindowBuilder;

    let window = WebviewWindowBuilder::new(app, "main", WebviewUrl::App("index.html".into()))
        .title("Todo")
        .inner_size(1280.0, 860.0)
        .min_inner_size(960.0, 640.0)
        .build()
        .map_err(|error| PlatformError::Platform(error.to_string()))?;
    window
        .set_focus()
        .map_err(|error| PlatformError::Platform(error.to_string()))?;
    Ok(())
}

/// 后台同步是否被允许（mobile 默认不允许，desktop 允许）。
pub fn run_background_sync_if_allowed() -> bool {
    #[cfg(not(mobile))]
    {
        true
    }
    #[cfg(mobile)]
    {
        false
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::service::reminder_service::{ReminderItem, ReminderKind, ReminderPlan};

    fn make_plan(items: Vec<ReminderItem>) -> ReminderPlan {
        ReminderPlan {
            items,
            window_start: "2026-07-02T08:00:00".to_string(),
            window_end: "2026-07-02T11:00:00".to_string(),
        }
    }

    #[test]
    fn plan_to_specs_uses_stable_key_and_localized_title() {
        let plan = make_plan(vec![ReminderItem {
            series_id: "s1".to_string(),
            occurrence_key: "2026-07-02".to_string(),
            title: "整理周报".to_string(),
            trigger_at: "2026-07-02T09:00:00".to_string(),
            kind: ReminderKind::Danger,
            payload: Some("周五前".to_string()),
        }]);
        let specs = plan_to_specs(&plan);
        assert_eq!(specs.len(), 1);
        assert_eq!(specs[0].key, "s1::2026-07-02::danger");
        assert_eq!(specs[0].title, "危险日：整理周报");
        assert_eq!(specs[0].body, "周五前");
    }

    #[test]
    fn plan_to_specs_due_kind_maps_to_due_key() {
        let plan = make_plan(vec![ReminderItem {
            series_id: "s2".to_string(),
            occurrence_key: "2026-07-02".to_string(),
            title: "提交日报".to_string(),
            trigger_at: "2026-07-02T10:00:00".to_string(),
            kind: ReminderKind::Due,
            payload: None,
        }]);
        let specs = plan_to_specs(&plan);
        assert_eq!(specs[0].key, "s2::2026-07-02::due");
        assert_eq!(specs[0].title, "截止：提交日报");
        assert_eq!(specs[0].body, "");
    }

    #[test]
    fn plan_to_specs_empty_plan_yields_empty_specs() {
        let plan = make_plan(vec![]);
        let specs = plan_to_specs(&plan);
        assert!(specs.is_empty());
    }

    #[test]
    fn plan_to_specs_preserves_order() {
        let plan = make_plan(vec![
            ReminderItem {
                series_id: "a".to_string(),
                occurrence_key: "k1".to_string(),
                title: "A".to_string(),
                trigger_at: "2026-07-02T08:30:00".to_string(),
                kind: ReminderKind::Danger,
                payload: None,
            },
            ReminderItem {
                series_id: "b".to_string(),
                occurrence_key: "k2".to_string(),
                title: "B".to_string(),
                trigger_at: "2026-07-02T10:00:00".to_string(),
                kind: ReminderKind::Due,
                payload: None,
            },
        ]);
        let specs = plan_to_specs(&plan);
        assert_eq!(specs.len(), 2);
        assert_eq!(specs[0].key, "a::k1::danger");
        assert_eq!(specs[1].key, "b::k2::due");
    }

    #[test]
    fn registered_notifications_starts_empty() {
        let registered = RegisteredNotifications::new();
        let map = registered.handles.lock().unwrap();
        let keys: HashSet<&String> = map.keys().collect();
        assert!(keys.is_empty());
    }
}
