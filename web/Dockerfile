FROM alpine:3.7
MAINTAINER Edouard Lavaud

# Dependencies
RUN rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && apk update \
  && apk --no-cache add python py-pip build-base gettext libxslt-dev jpeg-dev \
  && mkdir -p /data/web

WORKDIR /data/web

# Django easynut requirements
COPY settings /data/web/
RUN apk --no-cache add python-dev mysql-client mysql-dev \
  && pip install --no-cache-dir -r requirements.txt \
  && apk del -r python-dev mysql

# Last easynut code
# Correct paths to settings.py (temporary) and requirements.txt
# Remove static CSS file (bug: not replaced by collectstatic so delete it before)
RUN apk --no-cache add git \
  && git clone -b new_layout https://github.com/MSF-OCB/easynut \
  && apk del -r git \
  && rm /data/web/easynut/requirements.txt \
  && rm /data/web/easynut/django_easynut/settings.py \
  && mv requirements.txt easynut/requirements.txt \
  && mv settings.py easynut/django_easynut/settings.tmp.py \
  && mv settings.build.py easynut/django_easynut/settings.py \ 
  && rm /data/web/easynut/static/emr/style.css
 
# Collect static django files and replace right settings.py file
WORKDIR /data/web/easynut
RUN python /data/web/easynut/manage.py collectstatic --no-input \
  && rm django_easynut/settings.py \
  && mv django_easynut/settings.tmp.py django_easynut/settings.py
