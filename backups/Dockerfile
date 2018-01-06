FROM alpine:3.7

RUN apk --no-cache add --update bash mysql-client gzip openssl \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /backup

COPY ["run.sh", "backup.sh", "backup_l.sh", "restore.sh", "/"]
RUN chmod u+x /backup.sh /backup_l.sh /restore.sh /run.sh
