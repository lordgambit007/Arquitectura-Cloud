use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(FromRow, Serialize)]
pub struct Employee {
    pub id: Uuid,
    pub name: String,
    pub role: String,
    pub email: String,
    pub salary: rust_decimal::Decimal,
    pub avatar_url: Option<String>,
    pub created_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Deserialize)]
pub struct CreateEmployee {
    pub name: String,
    pub role: String,
    pub email: String,
    pub salary: f64,
    pub avatar_url: Option<String>,
}

#[derive(Deserialize)]
pub struct UpdateEmployee {
    pub name: Option<String>,
    pub role: Option<String>,
    pub salary: Option<f64>,
    pub avatar_url: Option<String>,
}
