# Use an official Python image as the base image
FROM python:3.11.5-alpine AS base

# Define arguments
ARG APP_PORT
ARG APP_HOST
ARG APP_MODULE

# Set the working directory within the container
WORKDIR /src

# Install Poetry and update pip in one step
RUN apk add --no-cache bash && \
    pip install --no-cache-dir --upgrade pip poetry && \
    apk del bash

# Copy the dependency files and install dependencies in one step
COPY pyproject.toml poetry.lock /src/
RUN poetry install --no-interaction --no-ansi

# Copy your FastAPI project source code into the container
COPY . /src

# Define environment variables
ENV APP_PORT=${APP_PORT}
ENV APP_HOST=${APP_HOST}
ENV APP_MODULE=${APP_MODULE}

# Expose the port your FastAPI app will run on
EXPOSE ${APP_PORT}

# Use a single CMD instruction
CMD ["sh", "-c", "poetry run uvicorn $APP_MODULE --reload --host $APP_HOST --port $APP_PORT"]
