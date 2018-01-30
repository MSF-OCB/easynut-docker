# easynut-docker

Docker compose for EasyNut

Includes a dummy database comprising a demo version of EasyNut in a nutrition center (forms configured but no patients), and a single user admin (pwd:adminadmin, <b>to be changed</b>). See "Databases" below for custom MySQL import.


## In this README

- [I. Installation steps](#i-installation-steps)
- [II. Structure](#ii-structure)
- [III. Environment variables](#iii-environment-variables)
- [IV. Databases](#iv-databases)
- [V. Backups & Restore](#v-backups--restore)
- [VI. Known issues](#vi-known-issues)


## I. Installation steps

### I.a) Preparation of the host

Installation of: git, docker, docker-compose (v3)  
Debian - Tested on ubuntu systems with overlay2 file system

```
sudo apt-get update && sudo apt-get upgrade
# Git
sudo apt-get install git
# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
# Remove sudo from docker
sudo usermod -aG docker ${USER}
su - ${USER}
# Docker compose
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```


### I.b) Preparation of the EasyNut docker compose

First clone this repository and move into it:

```
git clone https://github.com/MSF-OCB/easynut-docker.git
cd easynut-docker
```

Create your environment variables (In doubt, refer to the variables section below)

```
cp .env.template .env
vim .env
```

Choose the type of install: prod-oriented or dev by copying the right compose file

```
# if production-oriented:
cp docker-compose.prod.yml docker-compose.yml
# if development environment (not fully tested yet)
cp docker-compose.dev.yml docker-compose.yml
```

Download the latest version of the code.

```
[ -d web/easynut ] && rm -rf web/easynut
git clone -b new_layout https://github.com/MSF-OCB/easynut.git web/easynut
```

If you chose the dev environment, you need to build some Dockerfiles

```
docker-compose build
docker push msfocb/easynut:1.2
```

If you chose the prod-oriented, you will use redis which needs few [adjustments](https://www.techandme.se/performance-tips-for-redis-cache-server/) on the host. Launch the following scripts with sudo privileges:

```
sudo redis/preparehost.sh
```


### I.c) Using compose

Launch docker compose (the first time, it will need to download all images so it can take a while)

```
docker-compose up -d
```

Apply DB migrations from the application

```
docker cp easynut_django:/data/web/easynut/sql/migrations/. /tmp/easynut-sql-migrations/
docker cp /tmp/easynut-sql-migrations/. easynut_mysql:/tmp/easynut-sql-migrations/
rm -rf /tmp/easynut-sql-migrations/
docker exec -it easynut_mysql /tmp/easynut-sql-migrations/migrate.sh
```

Easynut should be available at:

- Main EasyNut system at http://{IP/domain/localhost}/nut
- Django admin interface at http://{IP/domain/localhost}/admin
- PHPMyAdmin at http://{IP/domain/localhost:8080}

Stop compose with:

```
docker-compose down
```


### I.d) Optional: Systemd service

Systemd service for automatically launching docker-compose on startup of the host.

First create the service:

```
sudo vi /etc/systemd/system/easynut.service
```

Enter the following lines and change the path to the appropriate ones (mostly the "USER" value):

```
[Unit]
Description=EasyNut containers
Requires=docker.service
After=docker.service

[Service]
Restart=on-failure
TimeoutSec=infinity
WorkingDirectory=/home/USER/easynut-docker/
ExecStart=/usr/local/bin/docker-compose up
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=default.target
```

Then:

```
sudo systemctl daemon-reload
sudo systemctl start easynut.service
```

Check that the service is well working with:

```
sudo systemctl status easynut.service
```

If yes, enable the service:

```
sudo systemctl enable easynut.service
```


## II. Structure

This project is composed of six services:

- Common to prod and dev:
  - [web](https://hub.docker.com/r/msfocb/easynut/): Django front that contains the application code
  - [mysql](https://hub.docker.com/r/_/mysql/): MySQL database
  - [backups](https://hub.docker.com/r/msfocb/backups/): Restore from encrypted backups and cron encrypt backups
- Prod:
  - [nginx](https://hub.docker.com/r/tutum/nginx/): Nginx reverse proxy that will handle the static assets and forward the dynamic ones to the Django WSGI process.
  - [redis](https://hub.docker.com/_/redis/): Redis database
- Dev:
  - [phpmyadmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin/): PHPMyAdmin service


## III. Environment variables

- `MYSQL_DATABASE`: Django database. Keep at 'easynut' or change sql files
- `DATA_DB_NAME`: Easynut database. Keep at 'easynutdata' or change sql files
- `MYSQL_USER`: Mysql EasyNut user
- `MYSQL_PASSWORD`: Password of MySQL EasyNut user
- `MYSQL_ROOT_PASSWORD`: MySQL root password
- `DB_HOST`: MySQL hostname. Keep at 'easynut_mysql' or change compose file
- `DB_SERVICE`: Keep at 'mysql' or change compose file
- `DB_PORT`: Keep at '3306' or change compose file
- `DEBUG`: True or False for django debug
- `SECRET_KEY`: Django secret key
- `ALLOWED_HOSTS`: For django. If unknown, keep to 172.*
- `CRON_TIME`: CRON timing for the historic backups. For example `55 23 * * *` for a daily backup realized at 23:55 (see [CRON expression](https://en.wikipedia.org/wiki/Cron#CRON_expression) for an understanding of the timing, and below for an understanding of the backups)
- `CRON_TIME_L`: For the "current" backup. For example `*/30 * * * *` for every half an hour.
- `MAX_BACKUPS`: Number of historic backup to keep. The old ones are automatically deleted. For example 30, if historic backup everyday, you will always keep the last month.


## IV. Databases

When created for the first time, the MySQL container will execute all the scripts located in:

- `./mysql/docker-entrypoint-initdb.d/` (host)
- `/docker-entrypoint-initdb.d/` (container)

If you wish to create easynut with an existing database, delete the file `./mysql/docker-entrypoint-initdb.d/1_restore.sql` (host) and copy the file of your choice in the folder.
_(see [MySQL Docker](https://hub.docker.com/_/mysql/))_

- Note 1: Keep in mind that files are executed by alphabetical order. The file "2_easynut_web.sh" should always be executed at last as it deals with the mysql user permissions.
- Note 2: The MySQL data are also persitant through a shared volume "easynutdocker_mysql_data". If you want to rebuild the mysql container with new data, think to delete the volume before hand.


## V. Backups & Restore

This service allows you encrypt backups of the database at regular frequency and restore them when needed.

### V.a) Backups

The backups are bind into a data directory located in ./backups/backups/ in the host system. They are also available to web service for the download of the backups via the user interface.

Backups are first gunzipped and then encrypted using openssl and the mysql root password.

2 types of backups are made, both containing all databases:

- Historical backups: To keep track of the changes in the database. They begin with the date/time of the backup (format: YYYYMMDDHHMM). The frequency of this backup is set by the "CRON_TIME" variable. The number of backups is limited using "MAX_BACKUPS": oldest ones removed.
- Overriden backup: The most recent backup called "backup.gz.enc", being the one downloaded through the user interface. Its frequency is set by the "CRON_TIME_L" variable


### V.b) Restore

The restore script can be used through the host as follow:

```
docker container exec easynut_backups /restore.sh /backup/backup.gz.enc
```

And replace "backup.gz.enc" by the gunzipped and encrypted (**same enc. pass**) file that you want.  
_(Note: in the container the folder '/backup' refers in the host to the folder "./backups/backups". You can therefore use the CRON backups already there or copy one from the host)_


## VI. Known issues

- Easynut github branch: The "new_layout" branch currently used is not adequate for this compose setup.The files "settings.py" and "requirements.txt" are duplicated (the ones in these repository being used here) as the static files are not needed. -> Needs for merging and better git structure
- Prod-oriented: careful considerations should be taken when using this repository in production.
