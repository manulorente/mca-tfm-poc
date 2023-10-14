FROM python:3.11-slim

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt


RUN apt-get update \
    && apt-get install gcc -y \
    && apt-get clean

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY . /app