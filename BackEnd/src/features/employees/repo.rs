use super::models::*;
use sqlx::{PgPool};
use uuid::Uuid;
use rust_decimal::Decimal;
use rust_decimal::prelude::ToPrimitive;


pub async fn list(pool: &PgPool) -> Result<Vec<Employee>, sqlx::Error> {
    sqlx::query_as::<_, Employee>("SELECT * FROM employees ORDER BY created_at DESC")
        .fetch_all(pool).await
}

pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Employee, sqlx::Error> {
    sqlx::query_as::<_, Employee>("SELECT * FROM employees WHERE id = $1")
        .bind(id).fetch_one(pool).await
}

pub async fn create(pool: &PgPool, data: CreateEmployee) -> Result<Employee, sqlx::Error> {
    sqlx::query_as::<_, Employee>(
        r#"INSERT INTO employees (name, role, email, salary, avatar_url)
           VALUES ($1,$2,$3,$4,$5) RETURNING *"#)
        .bind(&data.name)
        .bind(&data.role)
        .bind(&data.email)
        .bind(Decimal::try_from(data.salary).unwrap_or(Decimal::ZERO))
        .bind(&data.avatar_url)
        .fetch_one(pool).await
}

pub async fn update(pool: &PgPool, id: Uuid, data: UpdateEmployee) -> Result<Employee, sqlx::Error> {
    // actualización parcial
    let existing = get_by_id(pool, id).await?;
    let name = data.name.unwrap_or(existing.name);
    let role = data.role.unwrap_or(existing.role);
    let salary = Decimal::try_from(data.salary.unwrap_or(existing.salary.to_f64().unwrap_or(0.0)))
        .unwrap_or(existing.salary);
    let avatar_url = data.avatar_url.or(existing.avatar_url);

    sqlx::query_as::<_, Employee>(
        r#"UPDATE employees
           SET name=$1, role=$2, salary=$3, avatar_url=$4
           WHERE id=$5 RETURNING *"#)
        .bind(name).bind(role).bind(salary).bind(avatar_url).bind(id)
        .fetch_one(pool).await
}

pub async fn delete(pool: &PgPool, id: Uuid) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM employees WHERE id = $1").bind(id).execute(pool).await?;
    Ok(())
}
