CURRENT_UID = $(shell id -u):$(shell id -g)
CARGO = CURRENT_UID=$(CURRENT_UID) docker-compose run --rm cargo
SAM = CURRENT_UID=$(CURRENT_UID) docker-compose run --rm sam
CARGO_SHELL = CURRENT_UID=$(CURRENT_UID) docker-compose run --rm --entrypoint bash cargo
SAM_SHELL = CURRENT_UID=$(CURRENT_UID) docker-compose run --rm --entrypoint ash sam

DEPS_DIR = registry
ARTIFACTS_DIR = dist
ARTIFACT = bootstrap.zip

default:
	@$(MAKE) testLocal

$(DEPS_DIR):
	@$(MAKE) deps

$(ARTIFACT):
	@$(MAKE) pack

$(ARTIFACTS_DIR):
	@$(MAKE) build

.env:
	@cp .env.template .env

shell:
	@$(CARGO_SHELL)

samShell:
	@$(SAM_SHELL)

clean:
	@$(CARGO) clean
	@rm -rf .aws-sam target $(ARTIFACTS_DIR) $(ARTIFACT)

cleanAll: clean
	@rm -rf $(DEPS_DIR) Cargo.lock

deps:
	@$(CARGO) fetch

deps-upgrade:
	@$(CARGO) upgrade

fmt:
	@$(CARGO) fmt --all

lint:
	@$(CARGO) clippy

testUnit:
	@$(CARGO) test

build: $(DEPS_DIR)
	@$(CARGO_SHELL) -c "make _build"

_build:
	cargo build --release
	mkdir -p $(ARTIFACTS_DIR) && cp ./target/x86_64-unknown-linux-musl/release/bootstrap $(ARTIFACTS_DIR)/

pack: $(ARTIFACTS_DIR)
	@$(CARGO_SHELL) -c "make _pack"

_pack:
	zip -j $(ARTIFACT) ./dist/bootstrap

testLocal: $(ARTIFACTS_DIR) localstack
	@cat apigw-event.json | docker-compose run --rm lambda

localstack:
	@docker-compose exec localstack echo "localstack is still up" || \
	$(MAKE) dbLocal

dbLocal: stopLocalstack startLocalstack
	@$(SAM_SHELL) -c "./scripts/set-creds.sh && aws dynamodb create-table \
	--table-name \$$QUIZ_EVENTS_TABLE --attribute-definitions \
	AttributeName=room_code,AttributeType=S AttributeName=created,AttributeType=N \
	--key-schema AttributeName=room_code,KeyType=HASH AttributeName=created,KeyType=RANGE \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
	--endpoint-url http://localstack:4566"

startLocalstack:
	@docker-compose up -d localstack && \
	docker-compose run --rm dockerize -wait tcp://localstack:4566 -timeout 60s

stopLocalstack:
	@docker-compose rm -sf localstack

deploy: $(ARTIFACT)
	@$(SAM_SHELL) -c "./scripts/assume-role.sh && ./scripts/deploy.sh"
