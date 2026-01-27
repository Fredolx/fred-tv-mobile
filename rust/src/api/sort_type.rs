use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum SortType {
    AlphabeticalAsc = 0,
    AlphabeticalDesc = 1,
    Provider = 2,
}

impl From<u8> for SortType {
    fn from(value: u8) -> Self {
        match value {
            0 => SortType::AlphabeticalAsc,
            1 => SortType::AlphabeticalDesc,
            2 => SortType::Provider,
            _ => SortType::AlphabeticalAsc, // Default fallback
        }
    }
}
