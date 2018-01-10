FROM python:2.7.14-alpine3.7
MAINTAINER Edouard Lavaud

ENV PYTHONUNBUFFERED 1

# Dependencies
RUN rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && apk update \
  && apk --no-cache add mariadb-dev gcc libxslt-dev jpeg-dev musl-dev \
  && mkdir -p /data/web

WORKDIR /data/web

# Django easynut requirements
COPY settings /data/web/
RUN pip install --no-cache-dir -r requirements.txt 

# Last easynut code
# Correct paths to settings.py (temporary) and requirements.txt
# Remove static CSS file (bug: not replaced by collectstatic so delete it before)
RUN apk --no-cache add git \
  && git clone -b new_layout https://github.com/MSF-OCB/easynut \
  && apk del -r git \
  && rm /data/web/easynut/requirements.txt \
  && rm /data/web/easynut/django_easynut/settings.py \
  && mv requirements.txt easynut/requirements.txt \
  && mv settings.py easynut/django_easynut/settings.py \
  && rm /data/web/easynut/static/emr/style.css
 
WORKDIR /data/web/easynut
