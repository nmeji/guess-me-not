# Quizlet

[![deploy status](https://github.com/nmeji/quizlet/workflows/Deploy/badge.svg)](https://github.com/nmeji/quizlet/actions)
[![License](https://img.shields.io/dub/l/vibe-d.svg)](LICENSE)

A mini quiz game. :teacher: :student:

## API (in-progress)

- [x] POST /rooms - create a room
- [ ] POST /rooms/{code}/players - (re)join a room
- [ ] PUT /rooms/{code} - start game
- [ ] DELETE /rooms/{code} - mark session as ended

## Development

### Requirements
- Docker
- Docker Compose
- Make

### Usage

```bash
# create a .env file based on .env.template
$ cp .env.template .env
$ vim .env # or use your favorite text editor to edit .env

# run all: download dependencies, build, and a run a local test
$ make

# download cargo dependencies (cargo fetch)
$ make deps

# format code (rustfmt)
$ make fmt

# run linter (clippy)
$ make lint

# run unit tests
$ make testUnit
running 3 tests
test game::tests::create_room_timestamps ... ok
test game::tests::create_room_has_entity_and_event ... ok
test game::tests::create_room_generates_new_code ... ok

test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

# build bootstrap and zip it
$ make build
cargo build --release
    Updating git repository `https://github.com/awslabs/aws-lambda-rust-runtime/`
    Finished release [optimized] target(s) in 9.75s
mkdir -p dist && cp ./target/x86_64-unknown-linux-musl/release/bootstrap dist/

# test execute lambda locally
$ make testLocal
....
....
....
2020-06-25 08:34:32,258 DEBUG [hyper::client::connect::http] connecting to 127.0.0.1:9001
2020-06-25 08:34:32,259 DEBUG [hyper::client::connect::http] connected to 127.0.0.1:9001
2020-06-25 08:34:32,260 DEBUG [hyper::proto::h1::io] flushed 74 bytes
END RequestId: 7d7c0d53-c358-11c2-3b5c-0b4cca9a2a29
REPORT RequestId: 7d7c0d53-c358-11c2-3b5c-0b4cca9a2a29  Init Duration: 89.28 ms Duration: 267.67 ms     Billed Duration: 300 ms Memory Size: 1536 MB   Max Memory Used: 15 MB

{"statusCode":201,"headers":{"Content-Type":"application/json"},"multiValueHeaders":{"Content-Type":["application/json"]},"body":"{\"created\":1593074071,\"entity\":\"Room\",\"event\":\"Created\",\"expiry\":1593117271,\"room_code\":\"LMWW\"}","isBase64Encoded":null}

# deploy to aws
$ make deploy
```

## Web App (Todo)
