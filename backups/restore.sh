#!/bin/bash
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASSWORD}" ] && { echo "=> MYSQL_PASSWORD cannot be empty" && exit 1; }

if [ "$#" -ne 1 ]
then
    echo "You must pass the path of the backup file to restore"
fi

echo "=> Restore database from $1"
set -o pipefail

if openssl aes-192-cbc -d -pass pass:$MYSQL_ROOT_PASSWORD -in $1 -out "/backup/restore.sql.gz"
then
  gzip -d -9 /backup/restore.sql.gz
  mysql -h "easynut_mysql" -P "$DB_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < /backup/restore.sql
  rm -rf /backup/restore.sql.gz
  rm -rf /backup/restore.sql
  echo "=> Restore succeeded"
else
  echo "=> Restore failed"
fi
