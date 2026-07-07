use std::collections::HashMap;

use anyhow::Result;

use crate::{sql, types::Settings};

pub const USE_STREAM_CACHING: &str = "useStreamingCaching";
pub const DEFAULT_VIEW: &str = "defaultView";
pub const REFRESH_ON_START: &str = "refreshOnStart";
pub const DEFAULT_SORT: &str = "defaultSort";
pub const FORCE_TV_MODE: &str = "forceTvMode";
pub const SHOW_LIVESTREAMS: &str = "showLivestreams";
pub const SHOW_MOVIES: &str = "showMovies";
pub const SHOW_SERIES: &str = "showSeries";

pub fn get_settings() -> Result<Settings> {
    let map = sql::get_settings()?;
    let settings = Settings {
        use_stream_caching: map.get(USE_STREAM_CACHING).and_then(|s| s.parse().ok()),
        default_view: map.get(DEFAULT_VIEW).and_then(|s| s.parse().ok()),
        refresh_on_start: map.get(REFRESH_ON_START).and_then(|s| s.parse().ok()),
        default_sort: map.get(DEFAULT_SORT).and_then(|s| s.parse().ok()),
        force_tv_mode: map.get(FORCE_TV_MODE).and_then(|s| s.parse().ok()),
        show_livestreams: map.get(SHOW_LIVESTREAMS).and_then(|s| s.parse().ok()),
        show_movies: map.get(SHOW_MOVIES).and_then(|s| s.parse().ok()),
        show_series: map.get(SHOW_SERIES).and_then(|s| s.parse().ok()),
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
    if let Some(refresh_on_start) = settings.refresh_on_start {
        map.insert(
            REFRESH_ON_START.to_string(),
            Some(refresh_on_start.to_string()),
        );
    }
    if let Some(sort) = settings.default_sort {
        map.insert(DEFAULT_SORT.to_string(), Some(sort.to_string()));
    }
    if let Some(force_tv_mode) = settings.force_tv_mode {
        map.insert(FORCE_TV_MODE.to_string(), Some(force_tv_mode.to_string()));
    }
    if let Some(show_livestreams) = settings.show_livestreams {
        map.insert(
            SHOW_LIVESTREAMS.to_string(),
            Some(show_livestreams.to_string()),
        );
    }
    if let Some(show_movies) = settings.show_movies {
        map.insert(SHOW_MOVIES.to_string(), Some(show_movies.to_string()));
    }
    if let Some(show_series) = settings.show_series {
        map.insert(SHOW_SERIES.to_string(), Some(show_series.to_string()));
    }
    sql::update_settings(map)?;
    Ok(())
}
