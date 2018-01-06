#!/bin/bash
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASSWORD}" ] && { echo "=> MYSQL_PASSWORD cannot be empty" && exit 1; }

DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $DATE"

FILENAME=/backup/backup
if mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --all-databases --add-drop-database --single-transaction --quick --add-locks --disable-keys --extended-insert > "$FILENAME.sql"
then
  gzip -9 "$FILENAME.sql"
  openssl enc -aes-192-cbc -pass pass:$MYSQL_ROOT_PASSWORD -out "$FILENAME.gz.enc" -in "$FILENAME.sql.gz"
  rm -rf "$FILENAME.sql"
  rm -rf "$FILENAME.sql.gz"
else
  rm -rf "$FILENAME.sql"
  rm -rf "$FILENAME.sql.gz"
fi

echo "=> Backup done"
