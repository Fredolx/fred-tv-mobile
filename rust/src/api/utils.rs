use anyhow::{Context, Result};
use chrono::{DateTime, Local, Utc};
use directories::ProjectDirs;
use regex::Regex;
use serde::Serialize;
use std::{fs::File, path::PathBuf, sync::LazyLock};

use crate::api::{
    m3u,
    source_type::SourceType,
    sql,
    types::{ChannelPreserve, Source},
    xtream,
};

const DEFAULT_USER_AGENT: &str = "Fred TV";

static ILLEGAL_CHARS_REGEX: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r#"[<>:"/\\|?*\x00-\x1F]"#).unwrap());

pub(crate) async fn refresh_source(source: Source) -> Result<()> {
    let id = source.id;
    match source.source_type {
        SourceType::M3u => m3u::read_m3u8(source, true)?,
        SourceType::M3uLink => m3u::get_m3u8_from_link(source, true).await?,
        SourceType::Xtream => xtream::get_xtream(source, true).await?,
        SourceType::Custom => {}
    }
    if let Some(id) = id {
        sql::update_source_last_updated(id)?;
    }
    Ok(())
}

pub(crate) async fn refresh_all() -> Result<()> {
    let sources = sql::get_sources()?;
    for source in sources {
        refresh_source(source).await?;
    }
    Ok(())
}

pub(crate) fn get_local_time(timestamp: i64) -> Result<DateTime<Local>> {
    let datetime = DateTime::<Utc>::from_timestamp(timestamp, 0).context("no time")?;
    Ok(DateTime::<Local>::from(datetime))
}

fn get_filename(channel_name: String, url: String) -> Result<String> {
    let extension = get_extension(url);
    let channel_name = sanitize(channel_name);
    let filename = format!("{channel_name}.{extension}").to_string();
    Ok(filename)
}

fn get_extension(url: String) -> String {
    url.rsplit(".")
        .next()
        .filter(|ext| !ext.starts_with("php?"))
        .unwrap_or("mp4")
        .to_string()
}

pub(crate) fn sanitize(str: String) -> String {
    ILLEGAL_CHARS_REGEX.replace_all(&str, "").to_string()
}

pub(crate) fn serialize_to_file<T: Serialize>(obj: T, path: String) -> Result<()> {
    let data = serde_json::to_string(&obj)?;
    std::fs::write(path, data)?;
    Ok(())
}

pub(crate) fn backup_favs(source_id: i64, path: String) -> Result<()> {
    sql::do_tx(|tx| {
        let preserve = sql::get_preserve(tx, source_id)?;
        serialize_to_file(preserve, path)?;
        Ok(())
    })?;
    Ok(())
}

pub(crate) fn restore_favs(source_id: i64, path: String) -> Result<()> {
    let data = std::fs::read_to_string(path)?;
    let preserve: Vec<ChannelPreserve> = serde_json::from_str(&data)?;
    sql::do_tx(|tx| {
        sql::restore_preserve(tx, source_id, preserve)?;
        Ok(())
    })?;
    Ok(())
}

pub(crate) fn is_container() -> bool {
    std::env::var("container").is_ok()
}

pub(crate) fn create_nuke_request() -> Result<()> {
    let path = get_nuke_path()?;
    File::create(path)?;
    std::process::exit(0);
}

fn get_nuke_path() -> Result<PathBuf> {
    let path = ProjectDirs::from("dev", "fredol", "open-tv").context("project dir not found")?;
    let path = path.cache_dir();
    let path = path.join("nuke.txt");
    Ok(path)
}

pub(crate) fn check_nuke() -> Result<()> {
    let path = get_nuke_path()?;
    if !path.exists() {
        return Ok(());
    }
    std::fs::remove_file(path)?;
    let path = ProjectDirs::from("dev", "fredol", "open-tv").context("project dir not found")?;
    let path = path.data_dir();
    let path = path.join(sql::DB_NAME);
    if path.exists() {
        std::fs::remove_file(path)?;
    }
    Ok(())
}

pub(crate) fn get_user_agent_from_source(source: &Source) -> Result<String> {
    let user_agent: &str = source
        .user_agent
        .as_deref()
        .filter(|s| !s.trim().is_empty())
        .unwrap_or(DEFAULT_USER_AGENT);
    Ok(user_agent.to_string())
}
