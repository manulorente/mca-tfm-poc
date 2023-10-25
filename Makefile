.DEFAULT_GOAL := help

include .env

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
	@echo "Building the app $(APP_NAME)."
	docker build --no-cache -t $(APP_NAME):$(VERSION) .

.PHONY: clean
clean:  ## Clean the app.
	@echo "Cleaning the app."
	docker-compose down --rmi all --volumes --remove-orphans

.PHONY: dev
dev:  ## Start the app in development mode.
	@echo "Starting the app in development mode."
	docker run -d --name $(ENV) -p 8080:80 $(APP_NAME):$(VERSION)
	# docker compose run --rm --no-deps $(APP_NAME) poetry run uvicorn $(APP_NAME).main:app --reload --host 0.0.0.0 --port 8080
	# poetry run uvicorn $(APP_NAME).main:app --reload --host 0.0.0.0 --port 8080

.PHONY: prod
prod: ## Up the app
	@echo "starting the app in production mode"
	docker-compose up

.PHONY: install
install:  ## Install a new package in the app. ex: make install PKG=package_name
	@echo "Installing a package $(PKG) in the app."
	docker compose run --rm --no-deps $(APP_NAME) poetry add $(PKG)@latest
	docker build . --no-cache -t $(APP_NAME)
	
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
	docker compose run --rm --no-deps $(APP_NAME) poetry run mypy .

.PHONY: check-style
check-style:  ## Check the styling.
	@echo "Checking the styling."
	docker compose run --rm --no-deps $(APP_NAME) poetry run ruff check .
	
.PHONY: reformat
reformat:  ## Reformat the code.
	@echo "Reformatting the code."
	docker compose run --rm --no-deps $(APP_NAME) poetry run ruff format .

.PHONY: test-unit
test-unit:  ## Run the unit tests.
	@echo "Running the unit tests."
	docker compose run --rm --no-deps $(APP_NAME) poetry run pytest -n 4 $(APP_NAME)/tests/unit -ra 

.PHONY: test-integration
test-integration:  ## Run the integration tests.
	@echo "Running the integration tests."
	docker compose run --rm --no-deps $(APP_NAME) poetry run pytest -n 4 $(APP_NAME)/tests/integration -ra

.PHONY: test-acceptance
test-acceptance:  ## Run the acceptance tests.
	@echo "Running the acceptance tests."
	docker compose run --rm --no-deps $(APP_NAME) poetry run pytest -n 4 $(APP_NAME)/tests/acceptance -ra