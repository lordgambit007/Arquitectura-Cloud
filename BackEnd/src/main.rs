use flutteractixapp::{configuration::get_configuration, startup::Application};
use tracing::{error, info};
use tracing_subscriber::FmtSubscriber;

#[tokio::main]
async fn main() {
    env_logger::init();

    let subscriber = FmtSubscriber::builder()
        .with_max_level(tracing::Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)
        .expect("setting default subscriber failed");

    let mut configuration = get_configuration().expect("Failed to read configuration.");

    // 🔥 Prioriza PORT del entorno (Lambda usa PORT=8080)
    if let Ok(port) = std::env::var("PORT") {
        configuration.application.port = port.parse().unwrap_or(configuration.application.port);
    }

    let application = Application::build(configuration.clone())
        .await
        .expect("Failed to build the app");

    info!(
        "🚀  Server started successfully at : http://{}:{}",
        configuration.application.host, configuration.application.port
    );

    if let Err(e) = application.run_until_stopped().await {
        error!("Server failed: {}", e);
    }
}
