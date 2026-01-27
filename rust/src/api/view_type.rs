use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum ViewType {
    All = 0,
    Favorites = 1,
    Categories = 2,
    History = 3,
    Hidden = 4,
}

impl From<u8> for ViewType {
    fn from(value: u8) -> Self {
        match value {
            0 => ViewType::All,
            1 => ViewType::Favorites,
            2 => ViewType::Categories,
            3 => ViewType::History,
            4 => ViewType::Hidden,
            _ => ViewType::All, // Default fallback
        }
    }
}
