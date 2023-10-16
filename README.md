# mca-tfm-pco

## Description

Proof of concept for the Master's Thesis. Main objectives are:

- Create a simple web application with FastAPI
- Follow best practices to structure the application
- Demo to authenticate users, store data in a database and retrieve it
- Apply TDD to the development of the application. Unit tests and integration tests
- Use Redis to store the session data and cache
- Use Docker to deploy the application
- SQLModel to interact with the database
- Use GitHub Actions to automate the CI/CD pipeline

## Requirements

- Python 3.11
- Docker
- Docker Compose

## Virtual environment

### Create virtual environment

```bash
python -m venv .venv
```

### Activate virtual environment

```bash
source .venv/bin/activate
```

### Install dependencies

```bash
pip install -r requirements.txt
```

## Run tests

```bash
pytest
```  

## Build Docker image

```bash
docker build -t mca-tfm-pco .
```

## Run Docker compose

```bash
docker-compose up -d
```
