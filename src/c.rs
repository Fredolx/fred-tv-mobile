use std::sync::LazyLock;

use prost::Message;
use tokio::runtime::Runtime;

use crate::generated_proto::{self, FfiResult};

use anyhow::Result;

pub trait ResultFfiExt {
    fn into_ffi(self) -> FfiResult;
}

impl ResultFfiExt for FfiResult {
    fn into_ffi(self) -> FfiResult {
        self
    }
}

impl<E> ResultFfiExt for Result<(), E>
where
    E: std::fmt::Debug,
{
    fn into_ffi(self) -> FfiResult {
        FfiResult {
            success: self.is_ok(),
            error_message: self.err().map(|e| format!("{:#?}", e)),
            data: None,
        }
    }
}

impl crate::generated_proto::FfiResult {
    pub fn from_error<E: std::fmt::Debug>(e: E) -> Self {
        Self {
            success: false,
            error_message: Some(format!("{:#?}", e)),
            data: None,
        }
    }
}

impl<E> ResultFfiExt for Result<generated_proto::ffi_result::Data, E>
where
    E: std::fmt::Debug,
{
    fn into_ffi(self) -> FfiResult {
        FfiResult {
            success: self.is_ok(),
            error_message: self.as_ref().err().map(|f| format!("{:#?}", f)),
            data: self.ok(),
        }
    }
}

impl<E> ResultFfiExt for Result<Option<generated_proto::ffi_result::Data>, E>
where
    E: std::fmt::Debug,
{
    fn into_ffi(self) -> FfiResult {
        FfiResult {
            success: self.is_ok(),
            error_message: self.as_ref().err().map(|f| format!("{:#?}", f)),
            data: match self {
                Ok(opt) => opt,
                Err(_) => None,
            },
        }
    }
}

pub type FfiCallback = extern "C" fn(task_id: u64, ptr: *mut u8, len: usize);

pub fn queue_blocking<R>(
    task_id: u64,
    callback: FfiCallback,
    f: impl FnOnce() -> R + Send + 'static,
) where
    R: ResultFfiExt,
{
    RUNTIME.spawn_blocking(move || {
        send_to_callback(task_id, callback, f().into_ffi());
    });
}

pub fn queue_async<Fut, R>(task_id: u64, callback: FfiCallback, fut: Fut)
where
    Fut: Future<Output = R> + Send + 'static,
    R: ResultFfiExt,
{
    RUNTIME.spawn(async move {
        send_to_callback(task_id, callback, fut.await.into_ffi());
    });
}

pub fn queue_async_with_message<M, Fut, R>(
    task_id: u64,
    callback: FfiCallback,
    ptr: *const u8,
    len: usize,
    f: impl FnOnce(M) -> Fut + Send + 'static,
) where
    M: prost::Message + Default + 'static,
    Fut: Future<Output = R> + Send + 'static,
    R: ResultFfiExt,
{
    let decoded = decode(ptr, len).and_then(|bytes| {
        M::decode(bytes.as_slice()).map_err(|e| anyhow::anyhow!("Failed to parse protobuf: {e}"))
    });

    queue_async(task_id, callback, async move {
        match decoded {
            Ok(proto_msg) => f(proto_msg).await.into_ffi(),
            Err(e) => crate::generated_proto::FfiResult::from_error(e),
        }
    });
}

pub fn queue_blocking_with_message<M, R>(
    task_id: u64,
    callback: FfiCallback,
    ptr: *const u8,
    len: usize,
    f: impl FnOnce(M) -> R + Send + 'static,
) where
    M: prost::Message + Default + 'static,
    R: ResultFfiExt,
{
    let decoded = decode(ptr, len).and_then(|bytes| {
        M::decode(bytes.as_slice()).map_err(|e| anyhow::anyhow!("Failed to parse protobuf: {e}"))
    });

    queue_blocking(task_id, callback, move || match decoded {
        Ok(proto_msg) => f(proto_msg).into_ffi(),
        Err(e) => crate::generated_proto::FfiResult::from_error(e),
    });
}

fn send_to_callback(task_id: u64, callback: FfiCallback, msg: FfiResult) {
    let encoded = msg.encode_to_vec();
    let boxed = encoded.into_boxed_slice();
    let len = boxed.len();
    let ptr = Box::into_raw(boxed) as *mut u8;
    callback(task_id, ptr, len);
}

pub fn decode(ptr: *const u8, len: usize) -> Result<Vec<u8>> {
    if ptr.is_null() {
        return Err(anyhow::anyhow!("Failed to decode, ptr is null"));
    }
    if len == 0 {
        return Err(anyhow::anyhow!("Failed to decode, no data was sent"));
    }
    let raw_slice = unsafe { std::slice::from_raw_parts(ptr, len) };
    Ok(raw_slice.to_vec())
}

static RUNTIME: LazyLock<Runtime> =
    LazyLock::new(|| Runtime::new().expect("failed to build tokio runtime"));
