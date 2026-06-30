use crate::{
    c::{Bytes, FfiCallback, wrap_result_into_ffi_result},
    generated_proto::{FfiResult, ffi_result::Data::Source},
};

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
    c::queue_blocking(task_id, callback, || {
        wrap_result_into_ffi_result(sql::apply_migrations())
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn get_xtream(task_id: u64, callback: FfiCallback, message: Bytes) {
    let decoded = c::decode(message);
    c::queue_async(task_id, callback, async move {
       //let result = decoded.map(async |d| get_xtream_impl(d).await).or
        wrap_result_into_ffi_result(result)
    });
}

async fn get_xtream_impl(decoded: Vec<u8>) -> Result<()> {
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
        enabled: source.enabled
    };
    xtream::get_xtream(source, false).await
}

#[unsafe(no_mangle)]
pub extern "C" fn free_message(bytes: Bytes) {
    unsafe {
        bytes.free();
    }
}
