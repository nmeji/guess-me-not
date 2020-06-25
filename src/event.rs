use super::{game, Result};

use std::env;

use rusoto_core::Region;
use rusoto_dynamodb::{DynamoDb, DynamoDbClient, PutItemInput};

fn is_offline() -> bool {
    match env::var("IS_OFFLINE") {
        Ok(val) => val == "true",
        _ => false,
    }
}

fn get_region() -> Region {
    if is_offline() {
        Region::Custom { name: "us-east-1".into(), endpoint: "http://localstack:4566".into() }
    } else {
        Region::default()
    }
}

pub async fn room_created(room: &game::Room) -> Result<()> {
    let client = DynamoDbClient::new(get_region());
    let table = env::var("QUIZ_EVENTS_TABLE")?;

    client
        .put_item(PutItemInput {
            table_name: table,
            item: serde_dynamodb::to_hashmap(room).unwrap(),
            ..PutItemInput::default()
        })
        .await?;

    Ok(())
}
