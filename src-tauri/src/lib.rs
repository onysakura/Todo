mod db;
mod domain;
mod error;
mod repository;
mod service;

use db::{BootstrapStatus, Database};
use error::{CommandError, CommandResult};
use service::holiday_service::{HolidayDto, HolidayListInput, HolidayService, HolidayUpsertInput};
use service::settings_service::{SettingItemDto, SettingsDto, SettingsService, SettingsSetInput};
use service::sync_service::{SyncMetaItemDto, SyncMetaSetInput, SyncService, SyncStatusDto};
use service::tag_service::{TagCreateInput, TagDto, TagService, TagUpdateInput};
use service::task_service::{
    CalendarDayDto, TaskCreateInput, TaskDetailDto, TaskEditorDto, TaskListItemDto, TaskService,
    TaskSetOccurrenceStatusInput, TaskSetStatusInput, TaskUpdateInput, TaskUpdateTemplateFromInput,
    UpcomingQueryInput,
};
use tauri::{Manager, State};

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
fn tag_create(state: State<'_, AppState>, input: TagCreateInput) -> CommandResult<TagDto> {
    TagService::create(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn tag_update(state: State<'_, AppState>, input: TagUpdateInput) -> CommandResult<TagDto> {
    TagService::update(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn tag_delete(state: State<'_, AppState>, id: String) -> CommandResult<()> {
    TagService::delete(&state.database, &id).map_err(CommandError::from)
}

#[tauri::command]
fn settings_get(state: State<'_, AppState>) -> CommandResult<SettingsDto> {
    SettingsService::get(&state.database).map_err(CommandError::from)
}

#[tauri::command]
fn settings_set(
    state: State<'_, AppState>,
    input: SettingsSetInput,
) -> CommandResult<SettingItemDto> {
    SettingsService::set(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn settings_delete(state: State<'_, AppState>, key: String) -> CommandResult<()> {
    SettingsService::delete(&state.database, &key).map_err(CommandError::from)
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
fn task_create(state: State<'_, AppState>, input: TaskCreateInput) -> CommandResult<TaskDetailDto> {
    TaskService::create_task(&state.database, input).map_err(CommandError::from)
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
fn task_update(state: State<'_, AppState>, input: TaskUpdateInput) -> CommandResult<TaskDetailDto> {
    TaskService::update_task(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn task_delete(state: State<'_, AppState>, series_id: String) -> CommandResult<()> {
    TaskService::delete_task(&state.database, &series_id).map_err(CommandError::from)
}

#[tauri::command]
fn task_set_status(
    state: State<'_, AppState>,
    input: TaskSetStatusInput,
) -> CommandResult<TaskDetailDto> {
    TaskService::set_status(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn task_set_occurrence_status(
    state: State<'_, AppState>,
    input: TaskSetOccurrenceStatusInput,
) -> CommandResult<TaskDetailDto> {
    TaskService::set_occurrence_status(&state.database, input).map_err(CommandError::from)
}

#[tauri::command]
fn task_update_template_from(
    state: State<'_, AppState>,
    input: TaskUpdateTemplateFromInput,
) -> CommandResult<TaskDetailDto> {
    TaskService::update_template_from(&state.database, input).map_err(CommandError::from)
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

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::default()
                .level(log::LevelFilter::Info)
                .build(),
        )
        .setup(|app| {
            let database = Database::open_for_app(app.handle())?;
            app.manage(AppState { database });
            Ok(())
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
            task_update_template_from,
            upcoming_query,
            task_calendar_query
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
