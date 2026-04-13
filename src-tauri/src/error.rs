use serde::Serialize;
use thiserror::Error;

pub type AppResult<T> = Result<T, AppError>;
pub type CommandResult<T> = Result<T, CommandError>;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("数据库错误: {0}")]
    Database(#[from] rusqlite::Error),
    #[error("IO 错误: {0}")]
    Io(#[from] std::io::Error),
    #[error("路径解析失败: {0}")]
    Path(String),
    #[error("应用状态错误: {0}")]
    State(String),
    #[error("时间格式化失败: {0}")]
    Time(String),
    #[error("参数校验失败: {0}")]
    Validation(String),
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CommandError {
    pub code: &'static str,
    pub message: String,
}

impl From<AppError> for CommandError {
    fn from(value: AppError) -> Self {
        let code = match value {
            AppError::Database(_) => "database_error",
            AppError::Io(_) => "io_error",
            AppError::Path(_) => "path_error",
            AppError::State(_) => "state_error",
            AppError::Time(_) => "time_error",
            AppError::Validation(_) => "validation_error",
        };

        Self {
            code,
            message: value.to_string(),
        }
    }
}
