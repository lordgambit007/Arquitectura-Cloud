use actix_web::{get, post, put, delete, web, HttpResponse};
use uuid::Uuid;
use sqlx::PgPool;

use super::repo;
use super::models::*;

/// Diagnóstico: si esto responde 200, el scope /api/employees está bien montado
#[get("/ping")]
pub async fn ping_employees() -> actix_web::Result<HttpResponse> {
    Ok(HttpResponse::Ok().json(serde_json::json!({"ok": true, "where": "/api/employees/ping"})))
}

/// GET /api/employees
#[get("")]
pub async fn list_employees(pool: web::Data<PgPool>) -> actix_web::Result<HttpResponse> {
    let items = repo::list(pool.get_ref()).await
        .map_err(|e| { eprintln!("list error: {e}"); actix_web::error::ErrorInternalServerError("db") })?;
    Ok(HttpResponse::Ok().json(items))
}

/// GET /api/employees/{id}
#[get("/{id}")]
pub async fn get_employee(path: web::Path<Uuid>, pool: web::Data<PgPool>) -> actix_web::Result<HttpResponse> {
    let item = repo::get_by_id(pool.get_ref(), path.into_inner()).await
        .map_err(|_| actix_web::error::ErrorNotFound("not found"))?;
    Ok(HttpResponse::Ok().json(item))
}

/// POST /api/employees
#[post("")]
pub async fn create_employee(body: web::Json<CreateEmployee>, pool: web::Data<PgPool>) -> actix_web::Result<HttpResponse> {
    let item = repo::create(pool.get_ref(), body.into_inner()).await
        .map_err(|e| { eprintln!("create error: {e}"); actix_web::error::ErrorInternalServerError("db") })?;
    Ok(HttpResponse::Created().json(item))
}

/// PUT /api/employees/{id}
#[put("/{id}")]
pub async fn update_employee(path: web::Path<Uuid>, body: web::Json<UpdateEmployee>, pool: web::Data<PgPool>) -> actix_web::Result<HttpResponse> {
    let item = repo::update(pool.get_ref(), path.into_inner(), body.into_inner()).await
        .map_err(|e| { eprintln!("update error: {e}"); actix_web::error::ErrorInternalServerError("db") })?;
    Ok(HttpResponse::Ok().json(item))
}

/// DELETE /api/employees/{id}
#[delete("/{id}")]
pub async fn delete_employee(path: web::Path<Uuid>, pool: web::Data<PgPool>) -> actix_web::Result<HttpResponse> {
    repo::delete(pool.get_ref(), path.into_inner()).await
        .map_err(|e| { eprintln!("delete error: {e}"); actix_web::error::ErrorInternalServerError("db") })?;
    Ok(HttpResponse::NoContent().finish())
}
