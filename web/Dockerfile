FROM alpine:3.7
MAINTAINER Edouard Lavaud

# Dependencies
RUN rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && apk update \
  && apk --no-cache add python python-dev py-pip mysql-client mysql-dev build-base gettext git vim libxslt-dev jpeg-dev \
  && mkdir -p /data/web

WORKDIR /data/web

# Django easynut requirements
# Remove uncessary libraries
COPY settings /data/web/
RUN pip install --no-cache-dir -r requirements.txt

# Last easynut code
# Correct paths to settings.py (temporary) and requirements.txt
# Remove static CSS file (bug: not replaced by collectstatic so delete it before)
RUN git clone -b new_layout https://github.com/MSF-OCB/easynut \
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
