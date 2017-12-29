FROM alpine

# Initialize
RUN mkdir -p /data/web
WORKDIR /data/web

# Setup
RUN apk update
RUN apk upgrade
RUN apk add --update python python-dev mysql-client mysql-dev build-base gettext git py-pip

# Pull the last base from github and replace requirements and setup 
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
RUN apk del -r mysql-client mysql-dev

# Remove css static file (Ultimately, the static files should be out of the 
# git repository and always run the command collectstatic)
RUN rm /data/web/static/emr/style.css
RUN python /data/web/manage.py collectstatic


