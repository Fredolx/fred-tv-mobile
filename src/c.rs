use std::sync::LazyLock;

use prost::Message;
use tokio::runtime::Runtime;

use crate::generated_proto::FfiResult;

use anyhow::Result;

#[repr(C)]
pub struct Bytes {
    pub ptr: *mut u8,
    pub len: usize,
}

impl From<Vec<u8>> for Bytes {
    fn from(vec: Vec<u8>) -> Self {
        let boxed = vec.into_boxed_slice();
        let len = boxed.len();
        let ptr = Box::into_raw(boxed) as *mut u8;
        Bytes { ptr, len }
    }
}

impl Bytes {
    pub unsafe fn free(self) {
        if !self.ptr.is_null() && self.len > 0 {
            let fat_ptr = std::ptr::slice_from_raw_parts_mut(self.ptr, self.len);
            let _ = unsafe { Box::from_raw(fat_ptr) };
        }
    }
}

pub fn wrap_result_into_ffi_result<E, T>(result: Result<T, E>) -> FfiResult
where
    E: std::fmt::Debug,
{
    FfiResult {
        success: result.is_ok(),
        error_message: result.err().map(|e| format!("{:#?}", e)),
        data: None,
    }
}

pub type FfiCallback = extern "C" fn(task_id: u64, response: Bytes);

pub fn queue_blocking(
    task_id: u64,
    callback: FfiCallback,
    f: impl FnOnce() -> FfiResult + Send + 'static,
) {
    RUNTIME.spawn_blocking(move || {
        send_to_callback(task_id, callback, f());
    });
}

pub fn queue_async(
    task_id: u64,
    callback: FfiCallback,
    fut: impl Future<Output = FfiResult> + Send + 'static,
) {
    RUNTIME.spawn(async move {
        send_to_callback(task_id, callback, fut.await);
    });
}

fn send_to_callback(task_id: u64, callback: FfiCallback, msg: FfiResult) {
    callback(task_id, Bytes::from(msg.encode_to_vec()));
}

pub fn decode(bytes: Bytes) -> Result<Vec<u8>> {
    if bytes.ptr.is_null() {
        return Err(anyhow::anyhow!("Failed to decode, ptr is null"));
    }
    if bytes.len == 0 {
        return Err(anyhow::anyhow!("Failed to decode, no data was sent"))
    }
    let raw_slice = unsafe { std::slice::from_raw_parts(bytes.ptr, bytes.len) };
    Ok(raw_slice.to_vec())
}

static RUNTIME: LazyLock<Runtime> =
    LazyLock::new(|| Runtime::new().expect("failed to build tokio runtime"));