use actix_web::{get, HttpResponse, web};
use sqlx::PgPool;

#[get("/db_ping")]
pub async fn db_ping(pool: web::Data<PgPool>) -> HttpResponse {
    // intenta un SELECT 1 rápido; si hay problemas de red/SSL/credenciales, fallará aquí
    match sqlx::query_scalar::<_, i32>("SELECT 1")
        .fetch_one(pool.get_ref())
        .await
    {
        Ok(_) => HttpResponse::Ok().json(serde_json::json!({
            "code": "DB_OK",
            "message": "DB connection OK"
        })),
        Err(e) => HttpResponse::InternalServerError().json(serde_json::json!({
            "code": "DB_ERROR",
            "message": format!("DB error: {e}")
        })),
    }
}
