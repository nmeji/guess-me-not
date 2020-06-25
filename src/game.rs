use super::Result;

use chrono::{Duration, Utc};
use rand::distributions::Alphanumeric;
use rand::{thread_rng, Rng};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Room {
    #[serde(rename = "room_code")]
    code: String,
    entity: String,
    event: String,
    created: i64,
    expiry: i64,
}

fn generate_code() -> String {
    thread_rng().sample_iter(&Alphanumeric).take(4).collect()
}

pub fn create_room() -> Result<Room> {
    let now = Utc::now();
    let expiry = now + Duration::hours(12);
    let room_code = generate_code().to_uppercase();
    let game_room = Room {
        code: room_code,
        entity: "Room".into(),
        event: "Created".into(),
        created: now.timestamp(),
        expiry: expiry.timestamp(),
    };

    Ok(game_room)
}

#[cfg(test)]
mod tests {
    use super::*;

    use chrono::Duration;
    use regex::Regex;

    #[test]
    fn create_room_has_entity_and_event() {
        let room = create_room().unwrap();
        assert_eq!("Room".to_string(), room.entity);
        assert_eq!("Created".to_string(), room.event);
    }

    #[test]
    fn create_room_generates_new_code() {
        let room = create_room().unwrap();
        let re = Regex::new(r"^[A-Z0-9]{4}$").unwrap();
        assert!(re.is_match(room.code.as_str()));
    }

    #[test]
    fn create_room_timestamps() {
        let room = create_room().unwrap();
        let sec_diff = room.expiry - room.created;
        assert_eq!(Duration::hours(12).num_seconds(), sec_diff);
    }
}
