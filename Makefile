.DEFAULT_GOAL := help

include ./app/.env

.PHONY: help
help:  ## Show this help.
	@grep -E '^\S+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

.PHONY: local-setup
local-setup:  ## Set up the local environment installing git hooks.
	@echo "Setting up local environment."
	scripts/local-setup.sh

.PHONY: build
build:  ## Build the app.
	@echo "Building $(APP_NAME) docker image as $(IMAGE_NAME):$(IMAGE_TAG)."
	docker build -t $(DOCKERHUB_USERNAME)/$(IMAGE_NAME):$(IMAGE_TAG) --build-arg APP_PORT=$(APP_PORT) --build-arg APP_HOST=$(APP_HOST) --build-arg APP_MODULE=$(APP_MODULE) $(CONTAINER_NAME)

.PHONY: clean
clean:  ## Clean the app.
	@echo "Cleaning $(CONTAINER_NAME) docker image."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml down --rmi all --volumes --remove-orphans

.PHONY: run
run:  ## Start the app in development mode.
	@echo "Starting $(APP_NAME) in development mode."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml up --build $(CONTAINER_NAME)

.PHONY: install
install:  ## Install a new package in the app. ex: make install pkg=package_name
	@echo "Installing a package $(pkg) in the $(CONTAINER_NAME) docker image."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry add $(pkg)@latest
	$(MAKE) build

.PHONY: uninstall
uninstall:  ## Uninstall a package from the app. ex: make uninstall pkg=package_name
	@echo "Uninstalling a package $(pkg) from the $(CONTAINER_NAME) docker image."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry remove $(pkg)
	$(MAKE) build

.PHONY: prepare-image
prepare-image:  ## Prepare the image for release.
	@echo "Preparing the image for release."
	REPOSITORY=$(DOCKERHUB_USERNAME)/$(IMAGE_NAME)
	echo "REPOSITORY --> $(REPOSITORY)"
	RESPONSE=$(curl -s "https://hub.docker.com/v2/repositories/$REPOSITORY/tags")
	echo "RESPONSE --> $(RESPONSE)"
	TAGS=$( [ -z "$RESPONSE" ] && echo "$IMAGE_TAG-rc0" || echo "$RESPONSE" | jq -r '.results[].name' )
	echo "TAGS --> $TAGS"
	SORTED_TAGS=$(echo "$TAGS" | sort -V)
	echo "SORTED_TAGS --> $SORTED_TAGS"
	LATEST_TAG=$(echo "$SORTED_TAGS" | tail -1)
	echo "LATEST_TAG --> $LATEST_TAG"
	LATEST_RC=$(echo "$LATEST_TAG" | awk -F-rc '{print $NF}')
	echo "LATEST_RC --> $LATEST_RC"
	NEXT_RC=$((LATEST_RC + 1))
	echo "NEXT_RC --> $NEXT_RC"
	docker tag $(REPOSITORY):$(IMAGE_TAG) $(REPOSITORY):$(IMAGE_TAG)-rc$(NEXT_RC)

.PHONY: push-image-rc
push-image-rc: ## Push the release candidate
	@echo "Pushing the release candidate."
    docker push $(DOCKERHUB_USERNAME)/$(IMAGE_NAME):$(IMAGE_TAG)-rc$(NEXT_RC)

.PHONY: publish-release
publish-release: ## Publish the releasea to PROD as latest
	@echo "Publishing the release to PROD as latest."
	REPOSITORY=$(DOCKERHUB_USERNAME)/$(IMAGE_NAME)
	RESPONSE=$(curl -s "https://hub.docker.com/v2/repositories/$REPOSITORY/tags")
	TAGS=$( echo "$RESPONSE" | jq -r '.results[].name' )
	SORTED_TAGS=$(echo "$TAGS" | sort -V)
	LATEST_TAG=$(echo "$SORTED_TAGS" | tail -1)
    docker pull $(REPOSITORY):$(LATEST_TAG)
	docker tag $(REPOSITORY):$(LATEST_TAG) $(REPOSITORY):latest
	docker push $(REPOSITORY):latest

.PHONY: test
test:  ## Run the unit, integration and acceptance tests.
	@echo "Running the unit, integration and acceptance tests."
	$(MAKE) test-unit
	$(MAKE) test-integration
	$(MAKE) test-acceptance

.PHONY: pre-commit
pre-commit:  ## Run the pre-commit checks.
	@echo "Running the pre-commit checks."
	$(MAKE) reformat
	$(MAKE) check-typing
	$(MAKE) check-style

.PHONY: check-typing
check-typing:  ## Check the typing.
	@echo "Checking the typing."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry run mypy .

.PHONY: check-style
check-style:  ## Check the styling.
	@echo "Checking the styling."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry run ruff check .
	
.PHONY: reformat
reformat:  ## Reformat the code.
	@echo "Reformatting the code."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry run ruff format .

.PHONY: test-unit
test-unit:  ## Run the unit tests.
	@echo "Running the unit tests."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry run pytest -n 4 tests/unit -ra 

.PHONY: test-integration
test-integration:  ## Run the integration tests.
	@echo "Running the integration tests."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry run pytest -n 4 tests/integration -ra

.PHONY: test-acceptance
test-acceptance:  ## Run the acceptance tests.
	@echo "Running the acceptance tests."
	docker-compose -f $(CONTAINER_NAME)/docker-compose.yml run --rm $(CONTAINER_NAME) poetry run pytest -n 4 tests/acceptance -ra