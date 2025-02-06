use serde::{Deserialize, Serialize};

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
pub struct Channel {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<i64>,
    pub name: String,
    pub url: Option<String>,
    pub group: Option<String>,
    pub image: Option<String>,
    pub media_type: u8,
    pub source_id: Option<i64>,
    pub series_id: Option<u64>,
    pub group_id: Option<i64>,
    pub favorite: bool,
    pub stream_id: Option<u64>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
pub struct Source {
    pub id: Option<i64>,
    pub name: String,
    pub url: Option<String>,
    pub url_origin: Option<String>,
    pub username: Option<String>,
    pub password: Option<String>,
    pub source_type: u8,
    pub enabled: bool,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
pub struct Settings {
    pub recording_path: Option<String>,
    pub mpv_params: Option<String>,
    pub use_stream_caching: Option<bool>,
    pub default_view: Option<u8>,
    pub volume: Option<u8>,
    pub refresh_on_start: Option<bool>,
    pub restream_port: Option<u16>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
pub struct Filters {
    pub query: Option<String>,
    pub source_ids: Vec<i64>,
    pub media_types: Option<Vec<u8>>,
    pub view_type: u8,
    pub page: u8,
    pub series_id: Option<i64>,
    pub group_id: Option<i64>,
    pub use_keywords: bool,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize, Default)]
pub struct ChannelHttpHeaders {
    pub id: Option<i64>,
    pub channel_id: Option<i64>,
    pub referrer: Option<String>,
    pub user_agent: Option<String>,
    pub http_origin: Option<String>,
    pub ignore_ssl: Option<bool>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
pub struct EPG {
    pub epg_id: String,
    pub title: String,
    pub description: String,
    pub start_time: String,
    pub start_timestamp: i64,
    pub end_time: String,
}
