#![allow(dead_code)]

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TaskSeries {
    pub id: String,
    pub kind: String,
    pub created_at: String,
    pub updated_at: String,
    pub archived_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TaskSeriesRevision {
    pub id: String,
    pub series_id: String,
    pub effective_from: String,
    pub effective_until: Option<String>,
    pub title: String,
    pub note: Option<String>,
    pub tag_id: Option<String>,
    pub priority: Option<i64>,
    pub all_day: bool,
    pub start_at_time_part: Option<i64>,
    pub due_at_time_part: Option<i64>,
    pub duration_seconds: Option<i64>,
    pub recurrence_type: Option<String>,
    pub recurrence_interval: Option<i64>,
    pub recurrence_rule_json: Option<String>,
    pub recurrence_until: Option<String>,
    pub danger_offset_value: Option<i64>,
    pub danger_offset_unit: Option<String>,
    pub danger_use_workday: bool,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct TaskOccurrenceOverride {
    pub id: String,
    pub series_id: String,
    pub occurrence_key: String,
    pub override_start_at: Option<String>,
    pub override_due_at: Option<String>,
    pub override_danger_at: Option<String>,
    pub override_title: Option<String>,
    pub override_note: Option<String>,
    pub override_tag_id: Option<String>,
    pub override_priority: Option<i64>,
    pub status: String,
    pub completed_at: Option<String>,
    pub cancelled_at: Option<String>,
    pub detached_as_single: bool,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Tag {
    pub id: String,
    pub name: String,
    pub color_value: Option<String>,
    pub sort_order: i64,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct HolidayCalendarDay {
    pub date: String,
    pub day_type: String,
    pub name: Option<String>,
    pub source: Option<String>,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SyncMetaEntry {
    pub key: String,
    pub value: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct AppSetting {
    pub key: String,
    pub value_json: String,
    pub updated_at: String,
}
