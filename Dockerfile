FROM python:3.11.5

WORKDIR /app

COPY ./pyproject.toml /app

RUN apt-get update \
    && apt-get clean

RUN pip install --upgrade pip \
    && pip install poetry

RUN poetry install

COPY . /app

CMD ["poetry", "run", "uvicorn", "app.main:app", "--reload", "--host", "0.0.0.0", "--port", "8080"]
