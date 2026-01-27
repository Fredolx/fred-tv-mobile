use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum MediaType {
    Livestream = 0,
    Movie = 1,
    Serie = 2,
    Group = 3,
    Season = 4,
}

impl From<u8> for MediaType {
    fn from(value: u8) -> Self {
        match value {
            0 => MediaType::Livestream,
            1 => MediaType::Movie,
            2 => MediaType::Serie,
            3 => MediaType::Group,
            4 => MediaType::Season,
            _ => MediaType::Livestream, // Default fallback
        }
    }
}
