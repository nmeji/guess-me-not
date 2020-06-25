mod event;
mod game;

use std::collections::HashMap;

use aws_lambda_events::event::apigw::{ApiGatewayProxyRequest, ApiGatewayProxyResponse};
use lambda::handler_fn;
use log::debug;
use serde_json::json;

type Error = Box<dyn std::error::Error + Sync + Send + 'static>;
type Result<T> = std::result::Result<T, Error>;

#[tokio::main]
async fn main() -> Result<()> {
    simple_logger::init_with_level(log::Level::Debug)?;
    lambda::run(handler_fn(handler)).await?;

    Ok(())
}

async fn handler(e: ApiGatewayProxyRequest) -> Result<ApiGatewayProxyResponse> {
    debug!("{}", json!(e).to_string());

    let mut response_headers = HashMap::new();
    response_headers.insert("Content-Type".to_string(), "application/json".to_string());

    let mut response_headers_multi = HashMap::new();
    response_headers_multi.insert("Content-Type".to_string(), vec!["application/json".to_string()]);

    let room = game::create_room()?;

    event::room_created(&room).await?;

    let response_body = json!(room);

    Ok(ApiGatewayProxyResponse {
        status_code: 201i64,
        headers: response_headers,
        multi_value_headers: response_headers_multi,
        body: Some(response_body.to_string()),
        is_base64_encoded: None,
    })
}
