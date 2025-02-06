use anyhow::{anyhow, bail, Context, Result};
use chrono::{DateTime, Local, Utc};
use regex::Regex;
use reqwest::Client;
use std::{io::Write, path::Path, sync::LazyLock};

use super::{
    m3u,
    settings::{get_default_record_path, get_settings},
    source_type, sql,
    types::{Channel, Source},
    xtream,
};

static ILLEGAL_CHARS_REGEX: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r#"[<>:"/\\|?*\x00-\x1F]"#).unwrap());

pub async fn refresh_source(source: Source) -> Result<()> {
    match source.source_type {
        source_type::M3U => m3u::read_m3u8(source, true)?,
        source_type::M3U_LINK => m3u::get_m3u8_from_link(source, true).await?,
        source_type::XTREAM => xtream::get_xtream(source, true).await?,
        source_type::CUSTOM => {}
        _ => return Err(anyhow!("invalid source_type")),
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

pub(crate) fn get_local_time(timestamp: i64) -> Result<DateTime<Local>> {
    let datetime = DateTime::<Utc>::from_timestamp(timestamp, 0).context("no time")?;
    Ok(DateTime::<Local>::from(datetime))
}

pub async fn download(channel: Channel) -> Result<()> {
    let client = Client::new();
    let mut response = client
        .get(channel.url.as_ref().context("no url")?)
        .send()
        .await?;
    let total_size = response.content_length().unwrap_or(0);
    let mut downloaded = 0;
    let mut file = std::fs::File::create(get_download_path(get_filename(
        channel.name,
        channel.url.context("no url")?,
    )?)?)?;
    let mut send_threshold: u8 = 5;
    if !response.status().is_success() {
        let error = response.status();
        bail!("Failed to download movie: HTTP {error}")
    }
    while let Some(chunk) = response.chunk().await? {
        file.write(&chunk)?;
        downloaded += chunk.len() as u64;
        if total_size > 0 {
            let progress: u8 = ((downloaded as f64 / total_size as f64) * 100.0) as u8;
            if progress > send_threshold {
                send_threshold = progress + 5;
            }
        }
    }
    Ok(())
}

fn get_filename(channel_name: String, url: String) -> Result<String> {
    let extension = url
        .split(".")
        .last()
        .context("url has no extension")?
        .to_string();
    let channel_name = sanitize(channel_name);
    let filename = format!("{channel_name}.{extension}").to_string();
    Ok(filename)
}

pub(crate) fn sanitize(str: String) -> String {
    ILLEGAL_CHARS_REGEX.replace_all(&str, "").to_string()
}

fn get_download_path(file_name: String) -> Result<String> {
    let settings = get_settings()?;
    let path = match settings.recording_path {
        Some(path) => path,
        None => get_default_record_path()?,
    };
    let mut path = Path::new(&path).to_path_buf();
    path.push(file_name);
    Ok(path.to_string_lossy().to_string())
}
