use crate::{m3u, source_type, sql, types::Source, xtream};
use anyhow::{Result, anyhow};
use std::sync::OnceLock;

const DEFAULT_USER_AGENT: &str = "Fred TV";
pub static TEMP_PATH: OnceLock<String> = OnceLock::new();

pub async fn refresh_source(source: Source) -> Result<()> {
    let id = source.id;
    match source.source_type {
        source_type::M3U => m3u::read_m3u8(source, true)?,
        source_type::M3U_LINK => m3u::get_m3u8_from_link(source, true).await?,
        source_type::XTREAM => xtream::get_xtream(source, true).await?,
        _ => return Err(anyhow!("invalid source_type")),
    }
    if let Some(id) = id {
        sql::update_source_last_updated(id)?;
    }
    Ok(())
}

pub async fn refresh_all() -> Result<()> {
    let sources = sql::get_sources()?;
    for source in sources {
        refresh_source(source).await?;
    }
    Ok(())
}

pub async fn process_source(source: Source) -> Result<()> {
    match source.source_type {
        source_type::M3U => m3u::read_m3u8(source, false),
        source_type::M3U_LINK => m3u::get_m3u8_from_link(source, false).await,
        source_type::XTREAM => xtream::get_xtream(source, false).await,
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
