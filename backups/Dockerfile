FROM alpine:3.7

ARG DATA_DB_NAME
ARG CRON_TIME

RUN apk add --update bash mysql-client gzip openssl && rm -rf /var/cache/apk/* && mkdir -p /backup

ENV CRON_TIME="0 3 * * sun" \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306"

COPY ["run.sh", "backup.sh", "restore.sh", "/"]
RUN chmod u+x /backup.sh /restore.sh

CMD ["/run.sh"]
