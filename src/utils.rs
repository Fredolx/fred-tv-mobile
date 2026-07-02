use crate::types::{Channel, ChannelPreserve};
use crate::{
    m3u,
    settings::{get_default_record_path, get_settings},
    source_type, sql,
    types::Source,
    xtream,
};
use anyhow::{Context, Result, anyhow};
use directories::{BaseDirs, ProjectDirs};
use regex::Regex;
use serde::Serialize;
use std::{fs::File, path::PathBuf, sync::LazyLock};

const MACOS_POTENTIAL_PATHS: [&str; 3] = [
    "/opt/local/bin",    // MacPorts
    "/opt/homebrew/bin", // Homebrew on AARCH64 Mac
    "/usr/local/bin",    // Homebrew on AMD64 Mac
];

const DEFAULT_USER_AGENT: &str = "Fred TV";

static ILLEGAL_CHARS_REGEX: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r#"[<>:"/\\|?*\x00-\x1F]"#).unwrap());

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

pub fn sanitize(str: String) -> String {
    ILLEGAL_CHARS_REGEX.replace_all(&str, "").to_string()
}

pub fn serialize_to_file<T: Serialize>(obj: T, path: String) -> Result<()> {
    let data = serde_json::to_string(&obj)?;
    std::fs::write(path, data)?;
    Ok(())
}

pub fn backup_favs(source_id: i64, path: String) -> Result<()> {
    sql::do_tx(|tx| {
        let preserve = sql::get_preserve(tx, source_id)?;
        serialize_to_file(preserve, path)?;
        Ok(())
    })?;
    Ok(())
}

pub fn restore_favs(source_id: i64, path: String) -> Result<()> {
    let data = std::fs::read_to_string(path)?;
    let preserve: Vec<ChannelPreserve> = serde_json::from_str(&data)?;
    sql::do_tx(|tx| {
        sql::restore_preserve(tx, source_id, preserve)?;
        Ok(())
    })?;
    Ok(())
}

pub fn create_nuke_request() -> Result<()> {
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

pub fn check_nuke() -> Result<()> {
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

pub fn get_user_agent_from_source(source: &Source) -> Result<String> {
    let user_agent: &str = source
        .user_agent
        .as_deref()
        .filter(|s| !s.trim().is_empty())
        .unwrap_or(DEFAULT_USER_AGENT);
    Ok(user_agent.to_string())
}

fn expand(path: &str, base: Option<&BaseDirs>) -> Option<PathBuf> {
    if let Some(rest) = path.strip_prefix("~/").or_else(|| path.strip_prefix("~\\")) {
        return Some(base?.home_dir().join(rest));
    }
    if let Some(rest) = path.strip_prefix("%USERPROFILE%\\") {
        return Some(base?.home_dir().join(rest));
    }
    if let Some(rest) = path.strip_prefix("%LOCALAPPDATA%\\") {
        return Some(base?.data_local_dir().join(rest));
    }
    Some(PathBuf::from(path))
}

#[cfg(test)]
mod test_utils {
    use super::sanitize;

    #[test]
    fn test_sanitize() {
        assert_eq!(
            "SuperShow Who will win the million".to_string(),
            sanitize("SuperShow: Who will win the million?".to_string())
        );
    }
}
