mod db;
mod domain;
mod error;
mod repository;
mod service;

use db::{BootstrapStatus, Database};
use error::{CommandError, CommandResult};
use service::holiday_service::{HolidayDto, HolidayListInput, HolidayService, HolidayUpsertInput};
use service::platform_service::{self, RegisteredNotifications};
use service::reminder_service::{ReminderPlan, ReminderService};
use service::settings_service::{SettingItemDto, SettingsDto, SettingsService, SettingsSetInput};
use service::sync_service::{
    SaveCheckResult, SyncMetaItemDto, SyncMetaSetInput, SyncOutcome, SyncService, SyncStatusDto,
};
use service::tag_service::{TagCreateInput, TagDto, TagService, TagUpdateInput};
use service::task_service::{
    CalendarDayDto, TaskCreateInput, TaskDetailDto, TaskEditorDto, TaskListItemDto, TaskService,
    TaskSetOccurrenceDangerInput, TaskSetOccurrenceStatusInput, TaskSetStatusInput, TaskUpdateInput,
    TaskUpdateTemplateFromInput, UpcomingQueryInput,
};
use tauri::{AppHandle, Manager, State, Wry};
use time::OffsetDateTime;

struct AppState {
    database: Database,
}

#[tauri::command]
fn greet(name: &str) -> String {
    format!("你好，{}。Tauri 主线骨架已就绪。", name)
}

#[tauri::command]
fn app_get_bootstrap_status(state: State<'_, AppState>) -> CommandResult<BootstrapStatus> {
    state
        .database
        .bootstrap_status()
        .map_err(CommandError::from)
}

#[tauri::command]
fn tag_list(state: State<'_, AppState>) -> CommandResult<Vec<TagDto>> {
    TagService::list(&state.database).map_err(CommandError::from)
}

#[tauri::command]
fn tag_create(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TagCreateInput,
) -> CommandResult<TagDto> {
    let result = TagService::create(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn tag_update(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TagUpdateInput,
) -> CommandResult<TagDto> {
    let result = TagService::update(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn tag_delete(app: AppHandle<Wry>, state: State<'_, AppState>, id: String) -> CommandResult<()> {
    TagService::delete(&state.database, &id).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(())
}

#[tauri::command]
fn settings_get(state: State<'_, AppState>) -> CommandResult<SettingsDto> {
    SettingsService::get(&state.database).map_err(CommandError::from)
}

#[tauri::command]
fn settings_set(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: SettingsSetInput,
) -> CommandResult<SettingItemDto> {
    let result = SettingsService::set(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn settings_delete(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    key: String,
) -> CommandResult<()> {
    SettingsService::delete(&state.database, &key).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(())
}

#[tauri::command]
fn sync_status_get(state: State<'_, AppState>) -> CommandResult<SyncStatusDto> {
    SyncService::get_status(&state.database).map_err(CommandError::from)
}

#[tauri::command]
fn sync_meta_set(
    state: State<'_, AppState>,
    input: SyncMetaSetInput,
) -> CommandResult<SyncMetaItemDto> {
    SyncService::set_meta(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn sync_meta_delete(state: State<'_, AppState>, key: String) -> CommandResult<()> {
    SyncService::delete_meta(&state.database, &key).map_err(CommandError::from)
}

#[tauri::command]
fn sync_run(app: AppHandle<Wry>, state: State<'_, AppState>) -> CommandResult<SyncOutcome> {
    let store = SyncService::build_store(&state.database).map_err(CommandError::from)?;
    let outcome = SyncService::run_sync(&state.database, &store).map_err(CommandError::from)?;
    // 同步成功后重建提醒（远端可能引入新任务或修改截止/危险日）
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(outcome)
}

#[tauri::command]
fn sync_check_before_save(state: State<'_, AppState>) -> CommandResult<SaveCheckResult> {
    let store = SyncService::build_store(&state.database).map_err(CommandError::from)?;
    SyncService::check_before_save(&state.database, &store).map_err(CommandError::from)
}

#[tauri::command]
fn sync_mark_dirty(state: State<'_, AppState>) -> CommandResult<()> {
    SyncService::mark_dirty(&state.database).map_err(CommandError::from)
}

#[tauri::command]
fn holiday_list(
    state: State<'_, AppState>,
    input: HolidayListInput,
) -> CommandResult<Vec<HolidayDto>> {
    HolidayService::list(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn holiday_upsert(
    state: State<'_, AppState>,
    input: HolidayUpsertInput,
) -> CommandResult<HolidayDto> {
    HolidayService::upsert(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn holiday_delete(state: State<'_, AppState>, date: String) -> CommandResult<()> {
    HolidayService::delete(&state.database, &date).map_err(CommandError::from)
}

#[tauri::command]
fn task_create(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TaskCreateInput,
) -> CommandResult<TaskDetailDto> {
    let result = TaskService::create_task(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn task_get_detail(
    state: State<'_, AppState>,
    series_id: String,
) -> CommandResult<Option<TaskDetailDto>> {
    TaskService::get_task_detail(&state.database, &series_id).map_err(CommandError::from)
}

#[tauri::command]
fn task_get_editor(
    state: State<'_, AppState>,
    series_id: String,
) -> CommandResult<Option<TaskEditorDto>> {
    TaskService::get_task_editor(&state.database, &series_id).map_err(CommandError::from)
}

#[tauri::command]
fn task_get_occurrence_detail(
    state: State<'_, AppState>,
    series_id: String,
    occurrence_key: String,
) -> CommandResult<Option<TaskDetailDto>> {
    TaskService::get_occurrence_detail(&state.database, &series_id, &occurrence_key)
        .map_err(CommandError::from)
}

#[tauri::command]
fn task_get_occurrence_editor(
    state: State<'_, AppState>,
    series_id: String,
    occurrence_key: String,
) -> CommandResult<Option<TaskEditorDto>> {
    TaskService::get_occurrence_editor(&state.database, &series_id, &occurrence_key)
        .map_err(CommandError::from)
}

#[tauri::command]
fn task_update(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TaskUpdateInput,
) -> CommandResult<TaskDetailDto> {
    let result = TaskService::update_task(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn task_delete(app: AppHandle<Wry>, state: State<'_, AppState>, series_id: String) -> CommandResult<()> {
    TaskService::delete_task(&state.database, &series_id).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(())
}

#[tauri::command]
fn task_set_status(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TaskSetStatusInput,
) -> CommandResult<TaskDetailDto> {
    let result = TaskService::set_status(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn task_set_occurrence_status(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TaskSetOccurrenceStatusInput,
) -> CommandResult<TaskDetailDto> {
    let result =
        TaskService::set_occurrence_status(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn task_set_occurrence_danger(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TaskSetOccurrenceDangerInput,
) -> CommandResult<TaskDetailDto> {
    let result =
        TaskService::set_occurrence_danger(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn task_update_template_from(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
    input: TaskUpdateTemplateFromInput,
) -> CommandResult<TaskDetailDto> {
    let result =
        TaskService::update_template_from(&state.database, input).map_err(CommandError::from)?;
    rebuild_reminders_best_effort(&app, &state.database);
    Ok(result)
}

#[tauri::command]
fn upcoming_query(
    state: State<'_, AppState>,
    input: UpcomingQueryInput,
) -> CommandResult<Vec<TaskListItemDto>> {
    TaskService::upcoming_query(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn task_calendar_query(
    state: State<'_, AppState>,
    input: UpcomingQueryInput,
) -> CommandResult<Vec<CalendarDayDto>> {
    TaskService::calendar_query(&state.database, input).map_err(CommandError::from)
}

/// 手动触发提醒重建：计算近期计划并交给平台调度，返回计划供前端展示。
/// 若 `reminder.enabled` 为 false，仅取消已有通知，仍返回计划供前端预览。
#[tauri::command]
fn reminder_rebuild(
    app: AppHandle<Wry>,
    state: State<'_, AppState>,
) -> CommandResult<ReminderPlan> {
    let plan = compute_default_plan(&state.database)?;
    if read_reminder_enabled(&state.database) {
        platform_service::schedule_reminder_plan(&app, &plan)?;
    } else {
        let _ = platform_service::cancel_all_notifications(&app);
    }
    let _ = SyncService::set_meta(
        &state.database,
        SyncMetaSetInput {
            key: "last_reminder_rebuild_at".to_string(),
            value: db::now_rfc3339()?,
        },
    );
    Ok(plan)
}

/// 预览近期提醒计划（不调度），供前端展示。
#[tauri::command]
fn reminder_preview(
    state: State<'_, AppState>,
    window_hours: Option<i64>,
) -> CommandResult<ReminderPlan> {
    let hours = window_hours
        .filter(|value| *value > 0)
        .unwrap_or_else(|| read_reminder_window_hours(&state.database));
    let now = OffsetDateTime::now_utc();
    let end = now + time::Duration::hours(hours);
    ReminderService::compute_reminder_plan(&state.database, now, end).map_err(CommandError::from)
}

// ---------------------------------------------------------------------------
// 提醒重建辅助函数
// ---------------------------------------------------------------------------

/// 按默认提醒窗口（`reminder.windowHours`，缺省 24h）计算近期提醒计划。
fn compute_default_plan(database: &Database) -> CommandResult<ReminderPlan> {
    let window_hours = read_reminder_window_hours(database);
    let now = OffsetDateTime::now_utc();
    let end = now + time::Duration::hours(window_hours);
    ReminderService::compute_reminder_plan(database, now, end).map_err(CommandError::from)
}

/// 读取一个字符串型 settings（值以 JSON 字符串形式存储）。
fn read_string_setting(database: &Database, key: &str) -> Option<String> {
    SettingsService::get(database)
        .ok()?
        .items
        .into_iter()
        .find(|item| item.key == key)
        .and_then(|item| serde_json::from_str::<String>(&item.value_json).ok())
}

/// 读取提醒窗口小时数（默认 24）。
fn read_reminder_window_hours(database: &Database) -> i64 {
    read_string_setting(database, "reminder.windowHours")
        .and_then(|value| value.parse::<i64>().ok())
        .filter(|value| *value > 0)
        .unwrap_or(24)
}

/// 读取提醒是否启用（默认 true）。
fn read_reminder_enabled(database: &Database) -> bool {
    read_string_setting(database, "reminder.enabled")
        .map(|value| value == "true")
        .unwrap_or(true)
}

/// 读取后台同步间隔分钟数（默认 15，最小 5）。
fn read_sync_interval_minutes(database: &Database) -> i64 {
    read_string_setting(database, "sync.intervalMinutes")
        .and_then(|value| value.parse::<i64>().ok())
        .filter(|value| *value >= 5)
        .unwrap_or(15)
}

/// 计算近期提醒计划并交给平台调度，记录 `last_reminder_rebuild_at`。
/// 若 `reminder.enabled` 为 false，仅取消已有通知，不重新调度。
fn rebuild_reminders(app: &AppHandle<Wry>, database: &Database) -> CommandResult<()> {
    if !read_reminder_enabled(database) {
        let _ = platform_service::cancel_all_notifications(app);
        return Ok(());
    }
    let plan = compute_default_plan(database)?;
    platform_service::schedule_reminder_plan(app, &plan)?;
    let _ = SyncService::set_meta(
        database,
        SyncMetaSetInput {
            key: "last_reminder_rebuild_at".to_string(),
            value: db::now_rfc3339()?,
        },
    );
    Ok(())
}

/// best-effort 版本：失败仅日志降级，不阻断主流程；mobile 端 `NotSupported` 静默忽略。
fn rebuild_reminders_best_effort(app: &AppHandle<Wry>, database: &Database) {
    if let Err(error) = rebuild_reminders(app, database) {
        if error.code != "platform_not_supported" {
            log::warn!("提醒重建失败 [{}]: {}", error.code, error.message);
        }
    }
}

/// 后台定时同步循环（desktop 专用）：每轮读取间隔、执行同步、重建提醒。
async fn run_background_sync_loop(app: AppHandle<Wry>) {
    loop {
        // 读取间隔（不持有 state 跨 await）
        let interval_minutes = match app.try_state::<AppState>() {
            Some(state) => read_sync_interval_minutes(&state.database),
            None => {
                tokio::time::sleep(std::time::Duration::from_secs(60)).await;
                continue;
            }
        };
        tokio::time::sleep(std::time::Duration::from_secs(
            (interval_minutes * 60) as u64,
        ))
        .await;

        // 执行同步 + 重建提醒
        let outcome = match app.try_state::<AppState>() {
            Some(state) => {
                let store = match SyncService::build_store(&state.database) {
                    Ok(store) => store,
                    Err(error) => {
                        log::warn!("后台同步构建 store 失败: {}", error);
                        continue;
                    }
                };
                SyncService::run_sync(&state.database, &store)
            }
            None => continue,
        };

        match outcome {
            Ok(result) => {
                log::info!("后台同步完成: {:?}", result.action);
                if let Some(state) = app.try_state::<AppState>() {
                    rebuild_reminders_best_effort(&app, &state.database);
                }
            }
            Err(error) => {
                log::warn!("后台同步失败: {}", error);
            }
        }
    }
}

// ---------------------------------------------------------------------------
// 托盘菜单（desktop 专用）
// ---------------------------------------------------------------------------

/// 构建 Windows 系统托盘：显示窗口 / 手动同步 / 退出。
#[cfg(not(mobile))]
fn setup_tray(app: &AppHandle<Wry>) -> tauri::Result<()> {
    use tauri::menu::{Menu, MenuItem, PredefinedMenuItem};
    use tauri::tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent};

    let show_item = MenuItem::with_id(app, "show", "显示窗口", true, None::<&str>)?;
    let sync_item = MenuItem::with_id(app, "sync", "手动同步", true, None::<&str>)?;
    let separator = PredefinedMenuItem::separator(app)?;
    let quit_item = MenuItem::with_id(app, "quit", "退出", true, None::<&str>)?;
    let menu = Menu::with_items(app, &[&show_item, &sync_item, &separator, &quit_item])?;

    let mut builder = TrayIconBuilder::with_id("main-tray")
        .menu(&menu)
        .tooltip("Todo")
        .on_menu_event(|app, event| match event.id().as_ref() {
            "show" => {
                if let Err(error) = platform_service::show_main_window(app) {
                    log::warn!("显示窗口失败: {}", error);
                }
            }
            "sync" => {
                if let Some(state) = app.try_state::<AppState>() {
                    match SyncService::build_store(&state.database) {
                        Ok(store) => match SyncService::run_sync(&state.database, &store) {
                            Ok(outcome) => log::info!("托盘手动同步完成: {:?}", outcome.action),
                            Err(error) => log::warn!("托盘手动同步失败: {}", error),
                        },
                        Err(error) => log::warn!("托盘手动同步构建 store 失败: {}", error),
                    }
                    rebuild_reminders_best_effort(app, &state.database);
                }
            }
            "quit" => {
                app.exit(0);
            }
            _ => {}
        })
        .on_tray_icon_event(|tray, event| {
            if let TrayIconEvent::Click {
                button: MouseButton::Left,
                button_state: MouseButtonState::Up,
                ..
            } = event
            {
                if let Err(error) = platform_service::show_main_window(tray.app_handle()) {
                    log::warn!("托盘唤起窗口失败: {}", error);
                }
            }
        });

    if let Some(icon) = app.default_window_icon() {
        builder = builder.icon(icon.clone());
    }

    builder.build(app)?;
    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::default()
                .level(log::LevelFilter::Info)
                .build(),
        )
        .plugin(tauri_plugin_notification::init())
        .setup(|app| {
            let database = Database::open_for_app(app.handle())?;
            app.manage(AppState { database });
            app.manage(RegisteredNotifications::new());

            // desktop 端构建系统托盘
            #[cfg(not(mobile))]
            {
                setup_tray(app.handle())?;
            }

            // desktop 端启动后台定时同步
            if platform_service::run_background_sync_if_allowed() {
                let app_handle = app.handle().clone();
                tauri::async_runtime::spawn(run_background_sync_loop(app_handle));
            }

            Ok(())
        })
        .on_window_event(|window, event| {
            if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                // desktop：阻止默认关闭，改为销毁窗口（保留进程供托盘/后台使用）
                #[cfg(not(mobile))]
                {
                    if window.label() == "main" {
                        api.prevent_close();
                        let _ = window.destroy();
                    }
                }
            }
        })
        .invoke_handler(tauri::generate_handler![
            greet,
            app_get_bootstrap_status,
            tag_list,
            tag_create,
            tag_update,
            tag_delete,
            settings_get,
            settings_set,
            settings_delete,
            sync_status_get,
            sync_meta_set,
            sync_meta_delete,
            sync_run,
            sync_check_before_save,
            sync_mark_dirty,
            holiday_list,
            holiday_upsert,
            holiday_delete,
            task_create,
            task_get_detail,
            task_get_editor,
            task_get_occurrence_detail,
            task_get_occurrence_editor,
            task_update,
            task_delete,
            task_set_status,
            task_set_occurrence_status,
            task_set_occurrence_danger,
            task_update_template_from,
            upcoming_query,
            task_calendar_query,
            reminder_rebuild,
            reminder_preview
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
