FROM python:3.11.5

WORKDIR /src

COPY ./pyproject.toml /src

RUN apt-get update \
    && apt-get clean

RUN pip install --upgrade pip \
    && pip install poetry

RUN poetry install

COPY . /src

CMD ["poetry", "run", "uvicorn", "demo.main:app", "--reload", "--host", "0.0.0.0", "--port", "8080"]
