use rusqlite::{params, Connection};
use uuid::Uuid;

use crate::{db::now_rfc3339, domain::Tag, error::AppResult};

pub struct TagRepository;

impl TagRepository {
    #[cfg_attr(not(test), allow(dead_code))]
    pub fn create(
        connection: &Connection,
        name: &str,
        color_value: Option<&str>,
        sort_order: i64,
    ) -> AppResult<Tag> {
        let tag = Tag {
            id: Uuid::new_v4().to_string(),
            name: name.to_string(),
            color_value: color_value.map(str::to_string),
            sort_order,
            created_at: now_rfc3339()?,
            updated_at: now_rfc3339()?,
        };

        connection.execute(
            r#"
        INSERT INTO tag(id, name, color_value, sort_order, created_at, updated_at)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6)
      "#,
            params![
                tag.id,
                tag.name,
                tag.color_value,
                tag.sort_order,
                tag.created_at,
                tag.updated_at
            ],
        )?;

        Ok(tag)
    }

    pub fn list(connection: &Connection) -> AppResult<Vec<Tag>> {
        let mut statement = connection.prepare(
            r#"
        SELECT id, name, color_value, sort_order, created_at, updated_at
        FROM tag
        ORDER BY sort_order ASC, name COLLATE NOCASE ASC
      "#,
        )?;

        let rows = statement.query_map([], |row| {
            Ok(Tag {
                id: row.get(0)?,
                name: row.get(1)?,
                color_value: row.get(2)?,
                sort_order: row.get(3)?,
                created_at: row.get(4)?,
                updated_at: row.get(5)?,
            })
        })?;

        let mut tags = Vec::new();
        for row in rows {
            tags.push(row?);
        }
        Ok(tags)
    }

    pub fn get_by_id(connection: &Connection, id: &str) -> AppResult<Option<Tag>> {
        let mut statement = connection.prepare(
            r#"
        SELECT id, name, color_value, sort_order, created_at, updated_at
        FROM tag
        WHERE id = ?1
      "#,
        )?;

        let mut rows = statement.query([id])?;
        if let Some(row) = rows.next()? {
            return Ok(Some(Tag {
                id: row.get(0)?,
                name: row.get(1)?,
                color_value: row.get(2)?,
                sort_order: row.get(3)?,
                created_at: row.get(4)?,
                updated_at: row.get(5)?,
            }));
        }

        Ok(None)
    }

    pub fn get_by_name(connection: &Connection, name: &str) -> AppResult<Option<Tag>> {
        let mut statement = connection.prepare(
            r#"
        SELECT id, name, color_value, sort_order, created_at, updated_at
        FROM tag
        WHERE name = ?1
      "#,
        )?;

        let mut rows = statement.query([name])?;
        if let Some(row) = rows.next()? {
            return Ok(Some(Tag {
                id: row.get(0)?,
                name: row.get(1)?,
                color_value: row.get(2)?,
                sort_order: row.get(3)?,
                created_at: row.get(4)?,
                updated_at: row.get(5)?,
            }));
        }

        Ok(None)
    }

    pub fn update(
        connection: &Connection,
        id: &str,
        name: &str,
        color_value: Option<&str>,
        sort_order: i64,
    ) -> AppResult<()> {
        connection.execute(
            r#"
        UPDATE tag
        SET
          name = ?2,
          color_value = ?3,
          sort_order = ?4,
          updated_at = ?5
        WHERE id = ?1
      "#,
            params![id, name, color_value, sort_order, now_rfc3339()?],
        )?;

        Ok(())
    }

    pub fn delete(connection: &Connection, id: &str) -> AppResult<()> {
        connection.execute("DELETE FROM tag WHERE id = ?1", [id])?;
        Ok(())
    }
}
