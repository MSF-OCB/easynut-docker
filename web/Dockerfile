FROM alpine:3.7

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

# Initialize
RUN mkdir -p /data/web
WORKDIR /data/web

# Setup
RUN apk update
RUN apk upgrade
# - Python
RUN apk add --update python python-dev py-pip
# - Mysql (will be removed after)
RUN apk add --update mysql-client mysql-dev
# - Diverse utilities
RUN apk add --update build-base gettext git vim
# - For django easynut requirements
RUN apk add --update --no-cache libxslt-dev jpeg-dev

# Pull the last base from github and replace requirements and settings.py 
# This has to be changed after with a better git repo
RUN git clone -b new_layout https://github.com/MSF-OCB/easynut
# Change requirements.txt and install it
RUN rm /data/web/easynut/requirements.txt
COPY requirements.txt /data/web/easynut
RUN pip install -r easynut/requirements.txt
# Change settings file
RUN rm /data/web/easynut/django_easynut/settings.py
COPY settings.py /data/web/easynut/django_easynut/settings.py

# Clean
RUN apk del -r mysql

# Remove css static file (Ultimately, the static files should be out of the 
# git repository and always run the command collectstatic)
RUN rm /data/web/easynut/static/emr/style.css
WORKDIR /data/web/easynut
RUN python /data/web/easynut/manage.py collectstatic --no-input


