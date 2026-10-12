use crate::{m3u, source_type, sql, types::Source, xtream};
use anyhow::{Result, anyhow};
use std::sync::OnceLock;

const DEFAULT_USER_AGENT: &str = "Fred TV";
pub static TEMP_PATH: OnceLock<String> = OnceLock::new();

pub async fn refresh_source(source: Source) -> Result<()> {
    process_source(source).await
}

pub async fn refresh_all() -> Result<()> {
    let sources = sql::get_sources()?;
    for source in sources {
        refresh_source(source).await?;
    }
    Ok(())
}

pub async fn process_source(source: Source) -> Result<()> {
    sql::delete_orphan_user_data()?;
    match source.source_type {
        source_type::M3U => m3u::read_m3u8(source),
        source_type::M3U_LINK => m3u::get_m3u8_from_link(source).await,
        source_type::XTREAM => xtream::get_xtream(source).await,
        _ => Err(anyhow!("invalid source_type")),
    }
}

pub fn get_user_agent_from_source(source: &Source) -> Result<String> {
    let user_agent: &str = source
        .user_agent
        .as_deref()
        .filter(|s| !s.trim().is_empty())
        .unwrap_or(DEFAULT_USER_AGENT);
    Ok(user_agent.to_string())
}

pub fn should_show_whats_new(version: Option<String>) -> Result<bool> {
    Ok(sql::get_whats_new()? != version)
}
