use serde::{Deserialize, Serialize};

use crate::{
    db::Database,
    domain::AppSetting,
    error::{AppError, AppResult},
    repository::app_settings_repository::AppSettingsRepository,
};

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SettingItemDto {
    pub key: String,
    pub value_json: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SettingsDto {
    pub items: Vec<SettingItemDto>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SettingsSetInput {
    pub key: String,
    pub value_json: String,
}

pub struct SettingsService;

impl SettingsService {
    pub fn get(database: &Database) -> AppResult<SettingsDto> {
        database.with_connection(|connection| {
            let items = AppSettingsRepository::list(connection)?
                .into_iter()
                .map(map_setting)
                .collect();
            Ok(SettingsDto { items })
        })
    }

    pub fn set(database: &Database, input: SettingsSetInput) -> AppResult<SettingItemDto> {
        let key = normalize_key(&input.key)?;
        let value_json = normalize_value_json(&input.value_json)?;

        database.with_transaction(|transaction| {
            AppSettingsRepository::upsert(transaction, &key, &value_json)?;
            let setting = AppSettingsRepository::get(transaction, &key)?
                .ok_or_else(|| AppError::State("设置写入后读取失败".to_string()))?;
            Ok(map_setting(setting))
        })
    }

    pub fn delete(database: &Database, key: &str) -> AppResult<()> {
        let key = normalize_key(key)?;

        database.with_transaction(|transaction| {
            AppSettingsRepository::delete(transaction, &key)?;
            Ok(())
        })
    }
}

fn normalize_key(value: &str) -> AppResult<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("设置键不能为空".to_string()));
    }
    Ok(trimmed.to_string())
}

fn normalize_value_json(value: &str) -> AppResult<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("设置值不能为空".to_string()));
    }
    serde_json::from_str::<serde_json::Value>(trimmed)
        .map_err(|error| AppError::Validation(format!("设置值必须是合法 JSON: {error}")))?;
    Ok(trimmed.to_string())
}

fn map_setting(setting: AppSetting) -> SettingItemDto {
    SettingItemDto {
        key: setting.key,
        value_json: setting.value_json,
        updated_at: setting.updated_at,
    }
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;

    use super::{SettingsDto, SettingsService, SettingsSetInput};
    use crate::db::Database;

    #[test]
    fn set_and_get_settings() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        SettingsService::set(
            &database,
            SettingsSetInput {
                key: "display.compactMode".to_string(),
                value_json: "true".to_string(),
            },
        )
        .expect("should set setting");

        let settings: SettingsDto = SettingsService::get(&database).expect("should get settings");
        assert_eq!(settings.items.len(), 1);
        assert_eq!(settings.items[0].key, "display.compactMode");
        assert_eq!(settings.items[0].value_json, "true");
    }

    #[test]
    fn delete_setting_removes_item() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        SettingsService::set(
            &database,
            SettingsSetInput {
                key: "sync.autoRun".to_string(),
                value_json: "{\"enabled\":true}".to_string(),
            },
        )
        .expect("should set setting");

        SettingsService::delete(&database, "sync.autoRun").expect("should delete setting");

        let settings = SettingsService::get(&database).expect("should get settings");
        assert!(settings.items.is_empty());
    }
}
