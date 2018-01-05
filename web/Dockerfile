FROM alpine:3.7
MAINTAINER Edouard Lavaud

# Dependencies
RUN apk add --no-cache python python-dev py-pip mysql-client mysql-dev build-base gettext git vim libxslt-dev jpeg-dev \
  && mkdir -p /data/web

# Pull the last base from github and replace requirements and settings.py 
# This has to be changed after with a better git repo
# Change requirements.txt and install it
WORKDIR /data/web
RUN git clone -b new_layout https://github.com/MSF-OCB/easynut \
  && rm /data/web/easynut/requirements.txt \
  && rm /data/web/easynut/django_easynut/settings.py

COPY requirements.txt /data/web/easynut
COPY settings.py /data/web/easynut/django_easynut/settings.py

RUN pip install -r easynut/requirements.txt \
  && apk del -r mysql \
  && rm /data/web/easynut/static/emr/style.css

WORKDIR /data/web/easynut

# Initialize environment variables for django CLI
ARG SECRET_KEY
ARG DEBUG
ARG ALLOWED_HOSTS
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG DB_SERVICE
ARG DB_PORT
ARG DATA_DB_NAME

RUN python /data/web/easynut/manage.py collectstatic --no-input
