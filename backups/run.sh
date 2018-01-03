#!/bin/bash
touch /mysql_backup.log
tail -F /mysql_backup.log &

if [ -n "${INIT_BACKUP}" ]; then
  echo "=> Create a backup on the startup"
  /backup.sh
elif [ -n "${INIT_RESTORE_LATEST}" ]; then
  echo "=> Restore latest backup"
  until nc -z "easynut_mysql" "$DB_PORT"
  do
      echo "waiting database container..."
      sleep 1
  done
find /backup -maxdepth 1 -name '*.gz.enc' | tail -1 | xargs /restore.sh
fi

echo "${CRON_TIME} /backup.sh >> /mysql_backup.log 2>&1" > /crontab.conf
crontab /crontab.conf
echo "=> Running cron task manager"
exec crond -f

