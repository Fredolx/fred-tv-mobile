use crate::c::{Bytes, FfiCallback, ResultFfiExt};

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

use anyhow::Result;

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

#[unsafe(no_mangle)]
pub extern "C" fn initialize(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || sql::apply_migrations().into_ffi())
}

#[unsafe(no_mangle)]
pub extern "C" fn process_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_async_with_message(
        task_id,
        callback,
        message,
        |source: crate::generated_proto::Source| async move { process_source_impl(source).await },
    );
}

async fn process_source_impl(source: crate::generated_proto::Source) -> Result<()> {
    utils::process_source(crate::types::Source::from(source)).await
}

#[unsafe(no_mangle)]
pub extern "C" fn refresh_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    c::queue_async_with_message(
        task_id,
        callback,
        message,
        |source: crate::generated_proto::Source| async move { refresh_source_impl(source).await },
    );
}

async fn refresh_source_impl(source: crate::generated_proto::Source) -> Result<()> {
    utils::refresh_source(crate::types::Source::from(source)).await
}

#[unsafe(no_mangle)]
pub extern "C" fn free_message(bytes: Bytes) {
    unsafe {
        bytes.free();
    }
}
