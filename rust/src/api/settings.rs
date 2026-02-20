use std::{collections::HashMap, env::consts::OS};

use anyhow::{Context, Result};
use directories::UserDirs;

use crate::api::{sql, types::Settings};

pub const MPV_PARAMS: &str = "mpvParams";
pub const USE_STREAM_CACHING: &str = "useStreamingCaching";
pub const RECORDING_PATH: &str = "recordingPath";
pub const DEFAULT_VIEW: &str = "defaultView";
pub const VOLUME: &str = "volume";
pub const REFRESH_ON_START: &str = "refreshOnStart";
pub const RESTREAM_PORT: &str = "restreamPort";
pub const ENABLE_TRAY_ICON: &str = "enableTrayIcon";
pub const ZOOM: &str = "zoom";
pub const DEFAULT_SORT: &str = "defaultSort";
pub const ENABLE_HWDEC: &str = "enableHWDEC";
pub const ALWAYS_ASK_SAVE: &str = "alwaysAskSave";
pub const ENABLE_GPU: &str = "enableGPU";
pub const FORCE_TV_MODE: &str = "forceTVMode";

pub(crate) fn get_settings() -> Result<Settings> {
    let map = sql::get_settings()?;
    let settings = Settings {
        use_stream_caching: map.get(USE_STREAM_CACHING).and_then(|s| s.parse().ok()),
        default_view: map
            .get(DEFAULT_VIEW)
            .and_then(|s| s.parse::<u8>().ok())
            .map(|v| v.into()),
        refresh_on_start: map.get(REFRESH_ON_START).and_then(|s| s.parse().ok()),
        default_sort: map
            .get(DEFAULT_SORT)
            .and_then(|s| s.parse::<u8>().ok())
            .map(|v| v.into()),
        force_tv_mode: map.get(FORCE_TV_MODE).and_then(|s| s.parse().ok()),
    };
    Ok(settings)
}

pub(crate) fn update_settings(settings: Settings) -> Result<()> {
    let mut map: HashMap<String, String> = HashMap::with_capacity(3);
    if let Some(use_stream_caching) = settings.use_stream_caching {
        map.insert(
            USE_STREAM_CACHING.to_string(),
            use_stream_caching.to_string(),
        );
    }
    if let Some(default_view) = settings.default_view {
        map.insert(DEFAULT_VIEW.to_string(), (default_view as u8).to_string());
    }
    if let Some(refresh_on_start) = settings.refresh_on_start {
        map.insert(REFRESH_ON_START.to_string(), refresh_on_start.to_string());
    }
    if let Some(force_tv_mode) = settings.force_tv_mode {
        map.insert(FORCE_TV_MODE.to_string(), force_tv_mode.to_string());
    }
    sql::update_settings(map)?;
    Ok(())
}

pub(crate) fn get_default_record_path() -> Result<String> {
    let user_dirs = UserDirs::new().context("Failed to get user dirs")?;
    let mut path = user_dirs
        .video_dir()
        .context("No videos dir in ~, please set a recording path in Settings")?
        .to_owned();
    path.push("open-tv");
    std::fs::create_dir_all(&path)?;
    Ok(path.to_string_lossy().to_string())
}
