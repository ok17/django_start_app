FROM python:3.6.1
MAINTAINER Osamu Kashimura<kashimura@fotome.jp>

ENV PYTHONUNBUFFERED 1

RUN mkdir /app
WORKDIR /app

ADD requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt
RUN pip freeze > requirements.txt


