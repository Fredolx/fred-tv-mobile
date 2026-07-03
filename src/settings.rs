use std::collections::HashMap;

use anyhow::{Context, Result};
use directories::UserDirs;

use crate::{sql, types::Settings};

pub const USE_STREAM_CACHING: &str = "useStreamingCaching";
pub const DEFAULT_VIEW: &str = "defaultView";
pub const VOLUME: &str = "volume";
pub const REFRESH_ON_START: &str = "refreshOnStart";
pub const DEFAULT_SORT: &str = "defaultSort";

pub fn get_settings() -> Result<Settings> {
    let map = sql::get_settings()?;
    let settings = Settings {
        use_stream_caching: map.get(USE_STREAM_CACHING).and_then(|s| s.parse().ok()),
        default_view: map.get(DEFAULT_VIEW).and_then(|s| s.parse().ok()),
        volume: map.get(VOLUME).and_then(|s| s.parse().ok()),
        refresh_on_start: map.get(REFRESH_ON_START).and_then(|s| s.parse().ok()),
        default_sort: map.get(DEFAULT_SORT).and_then(|s| s.parse().ok()),
    };
    Ok(settings)
}

pub fn update_settings(settings: Settings) -> Result<()> {
    let mut map: HashMap<String, Option<String>> = HashMap::with_capacity(5);

    if let Some(use_stream_caching) = settings.use_stream_caching {
        map.insert(
            USE_STREAM_CACHING.to_string(),
            Some(use_stream_caching.to_string()),
        );
    }
    if let Some(default_view) = settings.default_view {
        map.insert(DEFAULT_VIEW.to_string(), Some(default_view.to_string()));
    }
    if let Some(volume) = settings.volume {
        map.insert(VOLUME.to_string(), Some(volume.to_string()));
    }
    if let Some(refresh_on_start) = settings.refresh_on_start {
        map.insert(
            REFRESH_ON_START.to_string(),
            Some(refresh_on_start.to_string()),
        );
    }
    if let Some(sort) = settings.default_sort {
        map.insert(DEFAULT_SORT.to_string(), Some(sort.to_string()));
    }   
    sql::update_settings(map)?;
    Ok(())
}

pub fn get_default_record_path() -> Result<String> {
    let user_dirs = UserDirs::new().context("Failed to get user dirs")?;
    let mut path = user_dirs
        .video_dir()
        .context("No videos dir in ~, please set a recording path in Settings")?
        .to_owned();
    path.push("open-tv");
    std::fs::create_dir_all(&path)?;
    Ok(path.to_string_lossy().to_string())
}
