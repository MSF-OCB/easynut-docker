# easynut-docker
Docker compose for EasyNut

<b>Installation steps:</b>

Required: docker, docker-compose (v3), git

First clone this repository and move into it:
```
git clone https://github.com/MSF-OCB/easynut-docker.git
cd easynut-docker
```

Create your environment variables (Refer to the variables section below)
```
cp .env.template .env
vim .env
```

Build the Docker files
```
docker-compose build
```

Launch docker compose in background
```
docker-compose up -d
```

Easynut should be available at: 
<ul>
<li>Main EasyNut system at http://{IP/domain/localhost}/nut</li>
<li>Django admin interface at http://{IP/domain/localhost}/admin</li>
<li>PHPMyAdmin at http://{IP/domain/localhost:8080}</li>
</ul>
If first time or data volume deleted, EasyNut is created with a dummy database comprising a demo version of EasyNut in a nutrition center (forms configured but no patients), and a single user admin (pwd:adminadmin, <b>to be changed on prod. env.</b>). See "Databases" below for custom MySQL import.

<b>Structure:</b>

This project is composed of six services:
<ul>
<li>web: Django front that contains the application code</li>
<li><a href="https://hub.docker.com/r/tutum/nginx/">nginx</a>: Nginx reverse proxy that will handle the static assets and forward the dynamic ones to the Django WSGI process.</li>
<li><a href="https://hub.docker.com/r/_/mysql/">mysql</a>: MySQL database</li>
<li><a href="https://hub.docker.com/_/redis/">redis</a>: Redis database</li>
<li>backups: Restore from encrypted backups and cron encrypt backups</li>
<li><a href="https://hub.docker.com/r/phpmyadmin/phpmyadmin/">phpmyadmin</a>: PHPMyAdmin service</li>
</ul>

Environment files:
<br/><i>(In the environment file, if using "=", the values should not be surrounded by quotes)</i>
<ul>
<li>MYSQL_DATABASE: Django databse. Keep at 'easynut' or change compose and dockerfiles</li>
<li>DATA_DB_NAME: Easynut database. Keep at 'easynutdata' or change compose and dockerfiles</li>
<li>MYSQL_USER: Mysql EasyNut user</li>
<li>MYSQL_PASSWORD: Password of MySQL EasyNut user</li>
<li>MYSQL_ROOT_PASSWORD: MySQL root password</li>
<li>DB_SERVICE: Keep at 'mysql' or change compose and dockerfiles</li>
<li>DB_PORT: Keep at '3306' or change compose and dockerfiles</li>
<li>DEBUG: True or False for django debug</li>
<li>SECRET_KEY: Django secret key</li>
<li>ALLOWED_HOSTS: Set to '*' in dev environment</li>
<li>CRON_TIME: CRON timing for automated enccrypted backups. For example '0 * * * *' for a hourly backup <i>(see <a href="https://en.wikipedia.org/wiki/Cron#CRON_expression">CRON expression</a>)</i></li>
<li>MAX_BACKUPS: Number of backup to keep. The old ones are automatically deleted</li>
</ul>

<b>Databases:</b>

When created for the first time, the MySQL container will execute all the scripts located in 
<br/>./mysql/docker-entrypoint-initdb.d/ (host)
<br/>/docker-entrypoint-initdb.d/ (container)

If you wish to create easynut with an existing database, delete the file ./mysql/docker-entrypoint-initdb.d/1_restore.sql (host) and copy the file of your choice in the folder. 
<br/><i>(see <a href="https://hub.docker.com/_/mysql/">MySQL Docker</a>)</i>
<ul>
<li>Note 1: Keep in mind that files are executed by alphabetical order. The file "2_easynut_web.sh" should always be executed at last as it deals with the mysql user permissions.</li>
<li>Note 2: The MySQL data are also persitant through a shared volume "easynutdocker_mysql_data". If you want to rebuild the mysql container with new data, think to delete the volume before hand.</li>
</ul>
<b>Backups:</b>

The shell scripts used for backups, restore and build are stored in ./backups/. If you modify them be sure to re-build the service.

The backups themself are bind through the service into a persistent data directory located in ./backups/backups/ in the host. Making them available through the host, but also to the web service for the download of the backups through the user interface.

Backups are first gunzipped and then encrypted using openssl and the mysql root password. 
<br/>The frequency and the number of backups are defined by the two environment variables: CRON_TIME and MAX_BACKUPS.

2 types of backups are made, both containing all databases. One beginning by the date/time (YYYYMMDDHHMM), the one being kept in limited number, and one simply called "backup.gz.enc", being the one downloaded through the user interface.

The restore script can be used through the host as follow:
```
docker container exec easynut_backups /restore.sh /backup/backup.gz.enc 
```
And replace "backup.gz/enc" but the gunzipped and encrypted (<b>same enc. pass</b>) with the file that you want. 
<br/><i>(Note: in the container the folder '/backup' refers in the host to the folder "./backups/backups". You can therefore use the CRON backups already there or copy one from the host)</i>

<b>Known caveats:</b>
<ul>
<li>Easynut github branch: The "new_layout" branch currently used is not adequate for this compose setup.The files "settings.py" and "requirements.txt" are duplicated (the ones in these repository being used here) as the static files are not needed. -> Needs for merging and better git structure</li>
<li>Security: This compose is not made for easy developpement environment and proper considerations should be made if use in prod.</li>
</ul>

