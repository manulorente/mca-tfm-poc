FROM python:3.11.5-slim AS base

WORKDIR /src

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir poetry

COPY poetry.lock pyproject.toml /src/

RUN poetry install

COPY . /src

EXPOSE 8080

CMD ["poetry", "run", "uvicorn", "api.main:app", "--reload", "--host", "0.0.0.0", "--port", "8080"]
