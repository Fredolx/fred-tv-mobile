use crate::c::{Bytes, FfiCallback};
use crate::generated_proto::ToggleFavorite;
use anyhow::Ok;

mod c;
mod generated_proto;
mod log;
mod m3u;
mod media_type;
mod settings;
mod sort_type;
mod source_type;
mod sql;
mod types;
mod utils;
mod view_type;
mod xtream;

impl From<crate::types::Settings> for crate::generated_proto::Settings {
    fn from(settings: crate::types::Settings) -> Self {
        crate::generated_proto::Settings {
            use_stream_caching: settings.use_stream_caching,
            default_view: settings.default_view.map(|v| v as u32),
            volume: settings.volume.map(|v| v as u32),
            refresh_on_start: settings.refresh_on_start,
            default_sort: settings.default_sort.map(|s| s as u32),
        }
    }
}

impl From<crate::generated_proto::Settings> for crate::types::Settings {
    fn from(settings: crate::generated_proto::Settings) -> Self {
        crate::types::Settings {
            use_stream_caching: settings.use_stream_caching,
            default_view: settings.default_view.map(|v| v as u8),
            volume: settings.volume.map(|v| v as u8),
            refresh_on_start: settings.refresh_on_start,
            default_sort: settings.default_sort.map(|s| s as u8),
        }
    }
}

impl From<crate::generated_proto::Source> for crate::types::Source {
    fn from(source: crate::generated_proto::Source) -> Self {
        crate::types::Source {
            id: source.id,
            name: source.name,
            source_type: source.source_type as u8,
            last_updated: source.last_updated,
            username: source.username,
            password: source.password,
            url: source.url,
            url_origin: source.url_origin,
            stream_user_agent: source.stream_user_agent,
            user_agent: source.user_agent,
            enabled: source.enabled,
        }
    }
}

impl From<crate::generated_proto::Filters> for crate::types::Filters {
    fn from(filters: crate::generated_proto::Filters) -> Self {
        crate::types::Filters {
            query: filters.query,
            source_ids: filters.source_ids,
            media_types: (!filters.media_types.is_empty())
                .then(|| filters.media_types.into_iter().map(|m| m as u8).collect()),
            view_type: filters.view_type as u8,
            page: filters.page as u8,
            series_id: filters.series_id,
            group_id: filters.group_id,
            use_keywords: filters.use_keywords,
            sort: filters.sort as u8,
            season: filters.season,
        }
    }
}

impl From<crate::types::Channel> for crate::generated_proto::Channel {
    fn from(channel: crate::types::Channel) -> Self {
        crate::generated_proto::Channel {
            id: channel.id,
            name: channel.name,
            url: channel.url,
            group: channel.group,
            image: channel.image,
            media_type: channel.media_type as u32,
            source_id: channel.source_id,
            series_id: channel.series_id.map(|s| s as u64),
            group_id: channel.group_id,
            favorite: channel.favorite,
            stream_id: channel.stream_id.map(|s| s as u64),
            tv_archive: channel.tv_archive,
            season_id: channel.season_id,
            episode_num: channel.episode_num,
        }
    }
}
impl From<Vec<crate::types::Channel>> for crate::generated_proto::ChannelList {
    fn from(channels: Vec<crate::types::Channel>) -> Self {
        crate::generated_proto::ChannelList {
            channels: channels.into_iter().map(Into::into).collect(),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn initialize(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || sql::apply_migrations())
}

#[unsafe(no_mangle)]
pub extern "C" fn process_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_async_with_message(
        task_id,
        callback,
        message,
        |source: crate::generated_proto::Source| async move {
            utils::process_source(crate::types::Source::from(source)).await
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn refresh_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_async_with_message(
        task_id,
        callback,
        message,
        |source: crate::generated_proto::Source| async move {
            utils::refresh_source(crate::types::Source::from(source)).await
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn delete_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_blocking_with_message(task_id, callback, message, |source_id| {
        sql::delete_source(source_id)
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn get_channels(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        message,
        |filters: crate::generated_proto::Filters| {
            Ok(generated_proto::ffi_result::Data::ChannelList(
                crate::generated_proto::ChannelList::from(sql::search(
                    crate::types::Filters::from(filters),
                )?),
            ))
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn favorite(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        message,
        |favorite_msg: ToggleFavorite| {
            sql::favorite_channel(favorite_msg.channel_id, favorite_msg.favorite)
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn get_settings(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || {
        settings::get_settings().map(|settings| {
            generated_proto::ffi_result::Data::Settings(generated_proto::Settings::from(settings))
        })
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn update_settings(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        message,
        |settings: generated_proto::Settings| {
            settings::update_settings(crate::types::Settings::from(settings))
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn add_last_watched(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        message,
        |id: crate::generated_proto::Id| sql::add_last_watched(id.id),
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn set_movie_position(task_id: u64, callback: FfiCallback, message: Bytes) {}

#[unsafe(no_mangle)]
pub extern "C" fn free_message(bytes: Bytes) {
    unsafe {
        bytes.free();
    }
}
