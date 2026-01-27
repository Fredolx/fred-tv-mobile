use crate::api::{
    m3u, settings, sql,
    types::{Channel, Filters, Settings, Source},
    utils, xtream,
};
use anyhow::Result;

pub fn get_m3u8(source: Source) -> Result<()> {
    m3u::read_m3u8(source, false)
}

pub async fn get_m3u8_from_link(source: Source) -> Result<()> {
    m3u::get_m3u8_from_link(source, false).await
}

pub fn get_settings() -> Result<Settings> {
    settings::get_settings()
}

pub fn update_settings(settings: Settings) -> Result<()> {
    settings::update_settings(settings)
}

pub fn search(filters: Filters) -> Result<Vec<Channel>> {
    sql::search(filters)
}

pub async fn get_xtream(source: Source) -> Result<()> {
    xtream::get_xtream(source, false).await
}

pub async fn get_episodes(channel: Channel) -> Result<()> {
    xtream::get_episodes(channel).await
}

pub fn create_or_initialize_db() -> Result<()> {
    sql::create_or_initialize_db()
}

pub fn drop_db() -> Result<()> {
    sql::drop_db()
}

pub async fn refresh_source(source: Source) -> Result<()> {
    utils::refresh_source(source).await
}

pub async fn refresh_all() -> Result<()> {
    utils::refresh_all().await
}

pub fn get_user_agent_from_source(source: Source) -> Result<String> {
    utils::get_user_agent_from_source(&source)
}

pub fn add_last_watched(id: i64) -> Result<()> {
    sql::add_last_watched(id)
}

pub fn clear_history() -> Result<()> {
    sql::clear_history()
}

pub fn has_sources() -> Result<bool> {
    sql::has_sources()
}
