FROM python:2.7.14-alpine3.7
MAINTAINER Edouard Lavaud

ENV PYTHONUNBUFFERED 1

# Dependencies
RUN rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && apk update \
  && apk --no-cache add mariadb-dev gcc libxslt-dev jpeg-dev musl-dev \
  && mkdir -p /data/web

COPY easynut /data/web/easynut

WORKDIR /data/web/easynut

RUN pip install --no-cache-dir -r requirements.txt 

# Last easynut code
# Correct paths to settings.py (temporary) and requirements.txt
# Remove static CSS file (bug: not replaced by collectstatic so delete it before)
RUN apk --no-cache add git \
  && git clone https://github.com/MSF-OCB/easynut \
  && mv easynut emr \
  && apk del -r git
