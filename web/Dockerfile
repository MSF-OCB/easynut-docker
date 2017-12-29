FROM alpine

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
RUN git clone -b new_layout https://github.com/MSF-OCB/easynut .
# Change requirements.txt and install it
RUN rm /data/web/requirements.txt
COPY requirements.txt /data/web/
RUN pip install -r requirements.txt
# Change settings file
RUN rm /data/web/django_easynut/settings.py
COPY settings.py /data/web/django_easynut/settings.py

# Clean
RUN apk del -r mysql

# Remove css static file (Ultimately, the static files should be out of the 
# git repository and always run the command collectstatic)
RUN rm /data/web/static/emr/style.css
RUN python /data/web/manage.py collectstatic


