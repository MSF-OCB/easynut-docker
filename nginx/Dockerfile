FROM nginx:1.13-alpine

RUN rm /etc/nginx/conf.d/default.conf
ADD default.conf /etc/nginx/conf.d
ADD easynut_django.local /etc/nginx
