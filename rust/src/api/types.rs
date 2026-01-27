use crate::api::{
    media_type::MediaType, sort_type::SortType, source_type::SourceType, view_type::ViewType,
};
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct Channel {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<i64>,
    pub name: String,
    pub url: Option<String>,
    pub group: Option<String>,
    pub image: Option<String>,
    pub media_type: MediaType,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source_id: Option<i64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub series_id: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub group_id: Option<i64>,
    pub favorite: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub stream_id: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tv_archive: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub season_id: Option<i64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub episode_num: Option<i64>,
    pub hidden: Option<bool>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize, Default)]
#[frb(non_opaque)]
pub struct Season {
    pub id: Option<i64>,
    pub name: String,
    pub season_number: i64,
    pub image: Option<String>,
    pub series_id: u64,
    pub source_id: i64,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct Source {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<i64>,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub url: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub url_origin: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub username: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub password: Option<String>,
    pub source_type: SourceType,
    pub use_tvg_id: Option<bool>,
    pub enabled: bool,
    pub user_agent: Option<String>,
    pub max_streams: Option<u8>,
    pub stream_user_agent: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_updated: Option<i64>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct Settings {
    pub recording_path: Option<String>,
    pub mpv_params: Option<String>,
    pub use_stream_caching: Option<bool>,
    pub default_view: Option<ViewType>,
    pub volume: Option<u8>,
    pub refresh_on_start: Option<bool>,
    pub restream_port: Option<u16>,
    pub enable_tray_icon: Option<bool>,
    pub zoom: Option<u16>,
    pub default_sort: Option<SortType>,
    pub enable_hwdec: Option<bool>,
    pub always_ask_save: Option<bool>,
    pub enable_gpu: Option<bool>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct Filters {
    pub query: Option<String>,
    pub source_ids: Vec<i64>,
    pub media_types: Option<Vec<MediaType>>,
    pub view_type: ViewType,
    pub page: u8,
    pub series_id: Option<i64>,
    pub group_id: Option<i64>,
    pub use_keywords: bool,
    pub sort: SortType,
    pub season: Option<i64>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize, Default)]
#[frb(non_opaque)]
pub struct ChannelHttpHeaders {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<i64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub channel_id: Option<i64>,
    pub referrer: Option<String>,
    pub user_agent: Option<String>,
    pub http_origin: Option<String>,
    pub ignore_ssl: Option<bool>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct CustomChannel {
    pub data: Channel,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub headers: Option<ChannelHttpHeaders>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct Group {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<i64>,
    pub name: String,
    pub image: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source_id: Option<i64>,
    pub hidden: Option<bool>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct IdName {
    pub id: i64,
    pub name: String,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct CustomChannelExtraData {
    pub headers: Option<ChannelHttpHeaders>,
    pub group: Option<Group>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct ExportedGroup {
    pub group: Group,
    pub channels: Vec<CustomChannel>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct ExportedSource {
    pub source: Source,
    pub groups: Vec<ExportedGroup>,
    pub channels: Vec<CustomChannel>,
}

#[derive(Clone, PartialEq, Debug, Deserialize, Serialize)]
#[frb(non_opaque)]
pub struct ChannelPreserve {
    pub name: String,
    pub favorite: bool,
    pub last_watched: Option<usize>,
    pub hidden: bool,
    #[serde(default)]
    pub is_group: bool,
}
