use actix_web::{web, App, HttpResponse, HttpServer, Responder, get, post};
use serde::Deserialize;
use std::env;

#[derive(Deserialize)]
struct EmailReq {
    to: String,
    subject: String,
    body: String,
}

#[get("/health")]
async fn health() -> impl Responder {
    HttpResponse::Ok().body("ok")
}

#[post("/notify/email")]
async fn notify_email(payload: web::Json<EmailReq>) -> impl Responder {
    if payload.to.trim().is_empty() || !payload.to.contains('@') {
        return HttpResponse::BadRequest().json(serde_json::json!({
            "code":"INVALID_INPUT","message":"Campo 'to' inválido"
        }));
    }

    // Variables de entorno
    let topic_arn = match env::var("SNS_TOPIC_ARN") {
        Ok(v) if !v.is_empty() => v,
        _ => return HttpResponse::InternalServerError().json(serde_json::json!({
            "code":"CONFIG_ERROR","message":"Falta SNS_TOPIC_ARN"
        })),
    };

    // Publicar en SNS
    let cfg = aws_config::load_from_env().await;
    let sns = aws_sdk_sns::Client::new(&cfg);
    let body = serde_json::json!({
        "to": payload.to,
        "subject": payload.subject,
        "body": payload.body
    }).to_string();

    if let Err(e) = sns.publish().topic_arn(topic_arn).message(body).send().await {
        eprintln!("SNS publish error: {e:?}");
        return HttpResponse::InternalServerError().json(serde_json::json!({
            "code":"SNS_ERROR","message":"No se pudo publicar en SNS"
        }));
    }

    HttpResponse::Ok().json(serde_json::json!({
        "status":"queued","via":"sns","message":"OK"
    }))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let host = env::var("BFF_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
    let port: u16 = env::var("BFF_PORT").ok().and_then(|v| v.parse().ok()).unwrap_or(8081);

    println!("BFF listening at http://{host}:{port}");
    HttpServer::new(|| App::new().service(health).service(notify_email))
        .bind((host, port))?
        .run()
        .await
}
