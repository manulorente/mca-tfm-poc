.DEFAULT_GOAL := help

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
	@echo "Building the app."
	docker build .

.PHONY: install
install:  ## Install the app.
	@echo "Installing the app."
	poetry install

.PHONY: update
update:  ## Update the app.
	@echo "Updating the app."
	poetry update

.PHONY: up
up:  ## Start the app.
	@echo "Starting the app."
	docker-compose up --build app

.PHONY: down
down:  ## Stop the app.
	@echo "Stopping the app."
	docker-compose down -v --remove-orphans

.PHONY: dev
dev:  ## Start the app in development mode.
	@echo "Starting the app in development mode."
	poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8080

.PHONY: check-typing
check-typing:  ## Check the typing.
	@echo "Checking the typing."
	poetry run mypy .

.PHONY: check-format
check-format:  ## Check the formatting.
	@echo "Checking the formatting."
	poetry run yapf --diff --recursive app/**/*.py

.PHONY: check-style
check-style:  ## Check the styling.
	@echo "Checking the styling."
	poetry run flake8 app/
	poetry run pylint app/**
	
.PHONY: reformat
reformat:  ## Reformat the code.
	@echo "Reformatting the code."
	poetry run yapf --parallel --recursive -ir app/

.PHONY: test-unit
test-unit:  ## Run the unit tests.
	@echo "Running the unit tests."
	docker-compose run --rm --no-deps app poetry run pytest -n tests/unit -ra 

.PHONY: test-integration
test-integration:  ## Run the integration tests.
	@echo "Running the integration tests."
	docker-compose run --rm app poetry run pytest -n tests/integration -ra

.PHONY: test-acceptance
test-acceptance:  ## Run the acceptance tests.
	@echo "Running the acceptance tests."
	docker-compose run --rm app poetry run pytest -n auto tests/acceptance -ra

.PHONY: test
test:  ## Run the unit, integration and acceptance tests.
	@echo "Running the unit, integration and acceptance tests."
	$(MAKE) test-unit
	$(MAKE) test-integration
	$(MAKE) test-acceptance

.PHONY: pre-commit
pre-commit:  ## Run the pre-commit checks.
	@echo "Running the pre-commit checks."
	$(MAKE) check-typing
	$(MAKE) check-format
	$(MAKE) check-style