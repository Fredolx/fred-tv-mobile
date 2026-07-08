use anyhow::{Context, Result};
use chrono::Local;
use std::{path::PathBuf, str::FromStr};
use tracing_subscriber::prelude::*;

pub fn init_logger() {
    unsafe {
        std::env::set_var("RUST_BACKTRACE", "1");
    }
    let _ = tracing_log::LogTracer::init();

    let file_layer = get_and_create_log_path()
        .and_then(|path| std::fs::File::create(path).map_err(Into::into))
        .map(|file| {
            tracing_subscriber::fmt::layer()
                .with_writer(file)
                .with_ansi(false)
        })
        .map_err(|e| {
            eprintln!("Failed to initialize file logger: {:?}", e);
        })
        .ok();

    let registry = tracing_subscriber::registry().with(file_layer);

    #[cfg(target_os = "android")]
    {
        if let Ok(android_layer) = tracing_android::layer("fred-tv-lib") {
            let subscriber = registry.with(android_layer);
            let _ = tracing::subscriber::set_global_default(subscriber);
        } else {
            let _ = tracing::subscriber::set_global_default(registry);
        }
    }

    #[cfg(target_os = "ios")]
    {
        let ios_layer = tracing_oslog::OsLogger::new("dev.fredol.open-tv", "default");
        let subscriber = registry.with(ios_layer);
        let _ = tracing::subscriber::set_global_default(subscriber);
    }

    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        let stderr_layer = tracing_subscriber::fmt::layer();
        let subscriber = registry.with(stderr_layer);
        let _ = tracing::subscriber::set_global_default(subscriber);
    }
}

fn get_and_create_log_path() -> Result<String> {
    let mut path = PathBuf::from_str(
        crate::utils::TEMP_PATH
            .get()
            .context("temp path is not defined")?,
    )?;
    if !path.exists() {
        std::fs::create_dir_all(&path)?;
    }
    path.push(get_log_name());
    Ok(path.to_string_lossy().to_string())
}

fn get_log_name() -> String {
    let current_time = Local::now();
    let formatted_time = current_time.format("%Y-%m-%d-%H-%M-%S").to_string();
    format!("{formatted_time}.log")
}
