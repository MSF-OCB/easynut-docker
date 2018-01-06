#!/bin/bash
touch /mysql_backup.log
tail -F /mysql_backup.log &

echo "${CRON_TIME} /backup.sh >> /mysql_backup.log 2>&1
${CRON_TIME_L} /backup_l.sh >> /mysql_backup.log 2>&1" > /crontab.conf
crontab /crontab.conf
echo "=> Running cron task manager"
exec crond -f
