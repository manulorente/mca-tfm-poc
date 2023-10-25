#!/bin/sh
set -e

poetry run uvicorn $APP_NAME.main:app --reload --host 0.0.0.0 --port 8080