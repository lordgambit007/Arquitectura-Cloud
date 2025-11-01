use actix_web::{get, HttpResponse};
use tokio::net::TcpStream;
use tokio::time::{timeout, Duration};

#[get("/tcp_ping")]
pub async fn tcp_ping() -> HttpResponse {
    let host = "t1-backend-db.cwvokqm8k8pc.us-east-1.rds.amazonaws.com:5432";
    match timeout(Duration::from_secs(3), TcpStream::connect(host)).await {
        Ok(Ok(_sock)) => HttpResponse::Ok().json(serde_json::json!({
            "code":"TCP_OK",
            "message":"TCP connect OK to 5432"
        })),
        Ok(Err(e)) => HttpResponse::InternalServerError().json(serde_json::json!({
            "code":"TCP_ERR",
            "message": format!("TCP connect error: {e}")
        })),
        Err(_) => HttpResponse::GatewayTimeout().json(serde_json::json!({
            "code":"TCP_TIMEOUT",
            "message":"TCP connect timed out (3s)"
        })),
    }
}
