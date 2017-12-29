#!/bin/env bash

mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON * TO '$MYSQL_USER'@'localhost';"
