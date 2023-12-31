.DEFAULT_GOAL := help

include ./app/.env

export REPOSITORY=$(DOCKERHUB_USERNAME)/$(IMAGE_NAME)
export LATEST_TAG=$(shell curl -s "https://hub.docker.com/v2/repositories/${REPOSITORY}/tags/" | jq -r '.results[].name' | sort -V | tail -n1)
export LATEST_RC=$(shell if [ -n "$(LATEST_TAG)" ]; then echo "$(LATEST_TAG)" | awk -F-rc '{print $$NF}'; else echo "$(IMAGE_TAG):rc0"; fi)
export NEXT_RC=$(shell expr $(LATEST_RC) + 1)

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
	docker build -t $(REPOSITORY):$(IMAGE_TAG) $(CONTAINER_NAME)

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

.PHONY: prepare-image-rc
prepare-image-rc:  ## Prepare the image for release.
	@echo "Preparing the image for release candidate - $(REPOSITORY):$(IMAGE_TAG)-rc$(NEXT_RC)"
	docker tag $(REPOSITORY):$(IMAGE_TAG) $(REPOSITORY):$(IMAGE_TAG)-rc$(NEXT_RC)

.PHONY: push-image-rc
push-image-rc: ## Push the release candidate
	@echo "Pushing the release candidate -  $(REPOSITORY):$(IMAGE_TAG)-rc$(NEXT_RC)"
	docker push $(REPOSITORY):$(IMAGE_TAG)-rc$(NEXT_RC)

.PHONY: publish-release
publish-release: ## Publish the releasea to PROD as latest
	@echo "Publishing the release to PROD - $(REPOSITORY):latest"
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