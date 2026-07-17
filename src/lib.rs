use std::collections::HashMap;

use crate::c::FfiCallback;
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
            refresh_on_start: settings.refresh_on_start,
            default_sort: settings.default_sort.map(|s| s as u32),
            force_tv_mode: settings.force_tv_mode,
            show_livestreams: settings.show_livestreams,
            show_series: settings.show_series,
            show_movies: settings.show_movies,
        }
    }
}

impl From<crate::generated_proto::Settings> for crate::types::Settings {
    fn from(settings: crate::generated_proto::Settings) -> Self {
        crate::types::Settings {
            use_stream_caching: settings.use_stream_caching,
            default_view: settings.default_view.map(|v| v as u8),
            refresh_on_start: settings.refresh_on_start,
            default_sort: settings.default_sort.map(|s| s as u8),
            force_tv_mode: settings.force_tv_mode,
            show_livestreams: settings.show_livestreams,
            show_movies: settings.show_movies,
            show_series: settings.show_series,
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

impl From<crate::types::Source> for crate::generated_proto::Source {
    fn from(source: crate::types::Source) -> Self {
        crate::generated_proto::Source {
            id: source.id,
            name: source.name,
            url: source.url,
            url_origin: source.url_origin,
            username: source.username,
            password: source.password,
            source_type: source.source_type as u32,
            enabled: source.enabled,
            user_agent: source.user_agent,
            stream_user_agent: source.stream_user_agent,
            last_updated: source.last_updated,
        }
    }
}

impl From<Vec<crate::types::Source>> for crate::generated_proto::SourceList {
    fn from(sources: Vec<crate::types::Source>) -> Self {
        crate::generated_proto::SourceList {
            sources: sources.into_iter().map(Into::into).collect(),
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

impl From<crate::types::ChannelHttpHeaders> for crate::generated_proto::ChannelHttpHeaders {
    fn from(headers: crate::types::ChannelHttpHeaders) -> Self {
        crate::generated_proto::ChannelHttpHeaders {
            id: headers.id,
            channel_id: headers.channel_id,
            referrer: headers.referrer,
            user_agent: headers.user_agent,
            http_origin: headers.http_origin,
            ignore_ssl: headers.ignore_ssl,
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn initialize(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |init_msg: generated_proto::InitMessage| {
            sql::DB_PATH_OVERRIDE
                .set(init_msg.db_path)
                .map_err(|e| anyhow::anyhow!(e))?;
            utils::TEMP_PATH
                .set(init_msg.temp_path)
                .map_err(|e| anyhow::anyhow!(e))?;
            log::init_logger();
            sql::apply_migrations()
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn process_source(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_async_with_message(
        task_id,
        callback,
        ptr,
        len,
        |source: crate::generated_proto::Source| async move {
            utils::process_source(crate::types::Source::from(source)).await
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn refresh_source(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_async_with_message(
        task_id,
        callback,
        ptr,
        len,
        |source: crate::generated_proto::Source| async move {
            utils::refresh_source(crate::types::Source::from(source)).await
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn delete_source(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(task_id, callback, ptr, len, |source_id| {
        sql::delete_source(source_id)
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn get_channels(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
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
pub extern "C" fn favorite(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
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
pub extern "C" fn update_settings(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |settings: generated_proto::Settings| {
            settings::update_settings(crate::types::Settings::from(settings))
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn add_last_watched(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |id: crate::generated_proto::IdMessage| sql::add_last_watched(id.value),
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn set_movie_position(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |position: generated_proto::MoviePosition| {
            sql::set_movie_position(position.channel_id, position.position)
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn get_movie_position(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |id_message: generated_proto::IdMessage| {
            Ok(generated_proto::ffi_result::Data::MoviePosition(
                generated_proto::GetMoviePosition {
                    position: sql::get_movie_position(id_message.value)?,
                },
            ))
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn clear_history(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || sql::clear_history());
}

#[unsafe(no_mangle)]
pub extern "C" fn source_name_exists(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |str_message: generated_proto::StrMessage| {
            Ok(crate::generated_proto::ffi_result::Data::BoolMessage(
                crate::generated_proto::BoolMessage {
                    value: sql::source_name_exists(&str_message.value)?,
                },
            ))
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn get_episodes(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_async_with_message(
        task_id,
        callback,
        ptr,
        len,
        async move |get_episodes_msg: crate::generated_proto::GetEpisodes| {
            xtream::get_episodes(
                get_episodes_msg.series_id,
                get_episodes_msg.source_id,
                get_episodes_msg.fallback_image,
            )
            .await
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn should_show_whats_new(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |opt_str_message: generated_proto::OptStrMessage| {
            Ok(generated_proto::ffi_result::Data::BoolMessage(
                crate::generated_proto::BoolMessage {
                    value: utils::should_show_whats_new(opt_str_message.value)?,
                },
            ))
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn update_last_seen_version(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |str_msg: crate::generated_proto::StrMessage| {
            let mut map: HashMap<String, Option<String>> = HashMap::new();
            map.insert(sql::LAST_SEEN_VERSION_KEY.to_string(), Some(str_msg.value));
            sql::update_settings(map)
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn refresh_all(task_id: u64, callback: FfiCallback) {
    c::queue_async(task_id, callback, async move { utils::refresh_all().await })
}

#[unsafe(no_mangle)]
pub extern "C" fn get_channel_headers(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |id: crate::generated_proto::IdMessage| {
            let headers = sql::get_channel_headers_by_id(id.value)?;
            Ok(headers.map(|f| {
                generated_proto::ffi_result::Data::Headers(
                    generated_proto::ChannelHttpHeaders::from(f),
                )
            }))
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn update_source(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |source_msg: crate::generated_proto::Source| {
            sql::update_source(crate::types::Source::from(source_msg))
        },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn get_enabled_sources_minimal(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || {
        Ok(
            crate::generated_proto::ffi_result::Data::EnabledSourcesMinimal(
                crate::generated_proto::GetEnabledSourcesMinimal {
                    list_id: sql::get_enabled_sources_minimal()?,
                },
            ),
        )
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn has_sources(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || {
        Ok(crate::generated_proto::ffi_result::Data::BoolMessage(
            crate::generated_proto::BoolMessage {
                value: sql::has_sources()?,
            },
        ))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn get_sources(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || {
        Ok(crate::generated_proto::ffi_result::Data::SourceList(
            crate::generated_proto::SourceList::from(sql::get_sources()?),
        ))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn set_source_enabled(task_id: u64, callback: FfiCallback, ptr: *const u8, len: usize) {
    c::queue_blocking_with_message(
        task_id,
        callback,
        ptr,
        len,
        |set_source_enabled_msg: crate::generated_proto::SetSourceEnabled| {
            sql::set_source_enabled(
                set_source_enabled_msg.enabled,
                set_source_enabled_msg.source_id,
            )
        },
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn free_message(ptr: *mut u8, len: usize) {
    unsafe {
        if !ptr.is_null() && len > 0 {
            let fat_ptr = std::ptr::slice_from_raw_parts_mut(ptr, len);
            let _ = Box::from_raw(fat_ptr);
        }
    }
}
