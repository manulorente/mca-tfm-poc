FROM python:3.11.5-alpine

RUN apk update --no-cache && apk upgrade --no-cache --available

WORKDIR /src

COPY ./pyproject.toml /src/

RUN pip install --upgrade pip && pip install poetry

COPY . /src/

RUN chmod +x /src/scripts/entrypoint.sh && poetry install

CMD ["/src/scripts/entrypoint.sh"]