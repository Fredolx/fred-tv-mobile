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

use anyhow::{Context, Result};
use prost::Message;

#[unsafe(no_mangle)]
pub extern "C" fn initialize(task_id: u64, callback: FfiCallback) {
    c::queue_blocking(task_id, callback, || sql::apply_migrations().into_ffi())
}

#[unsafe(no_mangle)]
pub extern "C" fn process_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    let decoded = c::decode(message);
    c::queue_async(task_id, callback, async move {
        if decoded.is_err() {
            return decoded.into_ffi();
        }
        process_source_impl(decoded.expect("not supposed to crash"))
            .await
            .into_ffi()
    });
}

async fn process_source_impl(decoded: Vec<u8>) -> Result<()> {
    let source = crate::generated_proto::Source::decode(decoded.as_slice())?;
    let source = crate::types::Source {
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
    };
    utils::process_source(source).await
}
pub extern "C" fn refresh_source(task_id: u64, callback: FfiCallback, message: Bytes) {
    let decoded = c::decode(message);
}

#[unsafe(no_mangle)]
pub extern "C" fn free_message(bytes: Bytes) {
    unsafe {
        bytes.free();
    }
}
