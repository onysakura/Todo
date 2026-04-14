use serde::{Deserialize, Serialize};

use crate::{
    db::Database,
    domain::Tag,
    error::{AppError, AppResult},
    repository::tag_repository::TagRepository,
};

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TagDto {
    pub id: String,
    pub name: String,
    pub color_value: Option<String>,
    pub sort_order: i64,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TagCreateInput {
    pub name: String,
    pub color_value: Option<String>,
    pub sort_order: i64,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TagUpdateInput {
    pub id: String,
    pub name: String,
    pub color_value: Option<String>,
    pub sort_order: i64,
}

pub struct TagService;

impl TagService {
    pub fn list(database: &Database) -> AppResult<Vec<TagDto>> {
        database.with_connection(|connection| {
            let tags = TagRepository::list(connection)?;
            Ok(tags.into_iter().map(map_tag).collect())
        })
    }

    pub fn create(database: &Database, input: TagCreateInput) -> AppResult<TagDto> {
        let name = normalize_name(&input.name)?;
        let color_value = normalize_color_value(input.color_value)?;

        database.with_transaction(|transaction| {
            if TagRepository::get_by_name(transaction, &name)?.is_some() {
                return Err(AppError::Validation("标签名称已存在".to_string()));
            }

            let tag = TagRepository::create(
                transaction,
                &name,
                color_value.as_deref(),
                input.sort_order,
            )?;

            Ok(map_tag(tag))
        })
    }

    pub fn update(database: &Database, input: TagUpdateInput) -> AppResult<TagDto> {
        let name = normalize_name(&input.name)?;
        let color_value = normalize_color_value(input.color_value)?;

        database.with_transaction(|transaction| {
            let _existing = TagRepository::get_by_id(transaction, &input.id)?
                .ok_or_else(|| AppError::Validation("标签不存在".to_string()))?;

            if let Some(tag) = TagRepository::get_by_name(transaction, &name)? {
                if tag.id != input.id {
                    return Err(AppError::Validation("标签名称已存在".to_string()));
                }
            }

            TagRepository::update(
                transaction,
                &input.id,
                &name,
                color_value.as_deref(),
                input.sort_order,
            )?;

            let updated = TagRepository::get_by_id(transaction, &input.id)?
                .ok_or_else(|| AppError::State("标签更新后读取失败".to_string()))?;
            Ok(map_tag(updated))
        })
    }

    pub fn delete(database: &Database, id: &str) -> AppResult<()> {
        database.with_transaction(|transaction| {
            let _existing = TagRepository::get_by_id(transaction, id)?
                .ok_or_else(|| AppError::Validation("标签不存在".to_string()))?;
            TagRepository::delete(transaction, id)?;
            Ok(())
        })
    }
}

fn normalize_name(value: &str) -> AppResult<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("标签名称不能为空".to_string()));
    }
    Ok(trimmed.to_string())
}

fn normalize_color_value(value: Option<String>) -> AppResult<Option<String>> {
    let Some(color) = value else {
        return Ok(None);
    };

    let trimmed = color.trim();
    if trimmed.is_empty() {
        return Ok(None);
    }

    if !trimmed.starts_with('#') || !(trimmed.len() == 7 || trimmed.len() == 9) {
        return Err(AppError::Validation(
            "标签颜色格式应为 #RRGGBB 或 #RRGGBBAA".to_string(),
        ));
    }

    Ok(Some(trimmed.to_uppercase()))
}

fn map_tag(tag: Tag) -> TagDto {
    TagDto {
        id: tag.id,
        name: tag.name,
        color_value: tag.color_value,
        sort_order: tag.sort_order,
    }
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;

    use super::{TagCreateInput, TagService, TagUpdateInput};
    use crate::db::Database;

    #[test]
    fn create_and_list_tags() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        TagService::create(
            &database,
            TagCreateInput {
                name: "收件箱".to_string(),
                color_value: Some("#335cff".to_string()),
                sort_order: 0,
            },
        )
        .expect("should create tag");

        let tags = TagService::list(&database).expect("should list tags");
        assert_eq!(tags.len(), 1);
        assert_eq!(tags[0].name, "收件箱");
        assert_eq!(tags[0].color_value.as_deref(), Some("#335CFF"));
    }

    #[test]
    fn update_tag_changes_fields() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TagService::create(
            &database,
            TagCreateInput {
                name: "工作".to_string(),
                color_value: None,
                sort_order: 1,
            },
        )
        .expect("should create tag");

        let updated = TagService::update(
            &database,
            TagUpdateInput {
                id: created.id,
                name: "工作-更新".to_string(),
                color_value: Some("#112233".to_string()),
                sort_order: 2,
            },
        )
        .expect("should update tag");

        assert_eq!(updated.name, "工作-更新");
        assert_eq!(updated.color_value.as_deref(), Some("#112233"));
        assert_eq!(updated.sort_order, 2);
    }

    #[test]
    fn delete_tag_removes_it_from_list() {
        let temp_dir = tempdir().expect("should create temp dir");
        let db_path = temp_dir.path().join("todo.data.sqlite3");
        let database = Database::open_at(&db_path).expect("should open database");

        let created = TagService::create(
            &database,
            TagCreateInput {
                name: "待删除标签".to_string(),
                color_value: None,
                sort_order: 0,
            },
        )
        .expect("should create tag");

        TagService::delete(&database, &created.id).expect("should delete tag");

        let tags = TagService::list(&database).expect("should list tags");
        assert!(tags.is_empty());
    }
}
