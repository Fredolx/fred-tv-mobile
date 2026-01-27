use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum SourceType {
    M3u = 0,
    M3uLink = 1,
    Xtream = 2,
    Custom = 3,
}

impl From<u8> for SourceType {
    fn from(value: u8) -> Self {
        match value {
            0 => SourceType::M3u,
            1 => SourceType::M3uLink,
            2 => SourceType::Xtream,
            3 => SourceType::Custom,
            _ => SourceType::M3u, // Default fallback
        }
    }
}
