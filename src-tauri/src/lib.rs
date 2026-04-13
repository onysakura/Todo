mod db;
mod domain;
mod error;
mod repository;
mod service;

use db::{BootstrapStatus, Database};
use domain::Tag;
use error::{CommandError, CommandResult};
use service::task_service::{TaskCreateInput, TaskDetailDto, TaskService};
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
fn tag_list(state: State<'_, AppState>) -> CommandResult<Vec<Tag>> {
    state.database.list_tags().map_err(CommandError::from)
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
            task_create,
            task_get_detail
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
