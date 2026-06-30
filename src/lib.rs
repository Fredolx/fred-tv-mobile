use prost::Message;

use crate::generated_proto::FfiResult;

mod generated_proto;
mod log;
mod media_type;
mod sort_type;
mod source_type;
mod sql;
mod types;
mod view_type;

#[repr(C)]
pub struct Bytes {
    ptr: *mut u8,
    len: usize,
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

pub fn wrap_ffi_result<E>(f: impl FnOnce() -> Result<(), E>) -> Bytes
where
    E: std::fmt::Debug,
{
    let result = f();
    Bytes::from(
        FfiResult {
            success: result.is_ok(),
            error_message: result.err().map(|e| format!("{:#?}", e)),
        }
        .encode_to_vec(),
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn Initialize() -> Bytes {
    wrap_ffi_result(sql::apply_migrations)
}
