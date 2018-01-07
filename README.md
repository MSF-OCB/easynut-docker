# easynut-docker
Docker compose for EasyNut

Includes a dummy database comprising a demo version of EasyNut in a nutrition center (forms configured but no patients), and a single user admin (pwd:adminadmin, <b>to be changed</b>). See "Databases" below for custom MySQL import.

<h3>In this README:</h3>
<ul>
<li><a href="#i-installation-steps">I. Installation steps</a></li>
<li><a href="#ii-structure">II. Structure</a></li>
<li><a href="#iii-environment-files">III. Environment files</a></li>
<li><a href="#iv-databases">IV. Databases</a></li>
<li><a href="#v-backups--restore">V. Backups & Restore</a></li>
<li><a href="#vi-known-issues">VI. Known issues</a></li>
</ul>

<h3>I. Installation steps:</h3>

<b>I.a) Preparation of the host</b>
<br/><i>Installation of: git, docker, docker-compose (v3)<br/>Debian - Tested on ubuntu systems with overlay2 file system</i>
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

<b>I.b) Preparation of the EasyNut docker compose</b>

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
Choose the type of install: prod-oriented or dev by copying the right compose file
```
# if production-oriented:
cp docker-compose.prod.yml docker-compose.yml
# if development environment (not fully tested yet)
cp docker-compose.dev.yml docker-compose.yml
```
If you chose the dev environment, you need to build some Dockerfiles
```
docker-compose build
```
If you chose the prod-oriented, you will use redis which needs few <a href="https://www.techandme.se/performance-tips-for-redis-cache-server/">adjustments</a> on the host. Launch the following scripts with sudo privileges:
```
sudo redis/preparehost.sh
```


<b>I.c) Using compose </b>

Launch docker compose (the first time, it will need to download all images so it can take a while)
```
docker-compose up -d
```

Easynut should be available at: 
<ul>
<li>Main EasyNut system at http://{IP/domain/localhost}/nut</li>
<li>Django admin interface at http://{IP/domain/localhost}/admin</li>
<li>PHPMyAdmin at http://{IP/domain/localhost:8080}</li>
</ul>

Stop compose with:
```
docker-compose down
```

<br/><b>I.d) Optional: Systemd service</b>

Systemd service for automatically launching docker-compose on startup of the host.
<br/> First create the service
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

<h3>II. Structure:</h3>

This project is composed of six services:
<br/>Common to prod and dev:
<ul>
<li><a href="https://hub.docker.com/r/elavaud/easynut/">web</a>: Django front that contains the application code</li>
<li><a href="https://hub.docker.com/r/_/mysql/">mysql</a>: MySQL database</li>
<li><a href="https://hub.docker.com/r/elavaud/backups/">backups</a>: Restore from encrypted backups and cron encrypt backups</li>
</ul>
Prod:
<ul>
<li><a href="https://hub.docker.com/r/tutum/nginx/">nginx</a>: Nginx reverse proxy that will handle the static assets and forward the dynamic ones to the Django WSGI process.</li>
<li><a href="https://hub.docker.com/_/redis/">redis</a>: Redis database</li>
</ul>
Dev:
<ul>
<li><a href="https://hub.docker.com/r/phpmyadmin/phpmyadmin/">phpmyadmin</a>: PHPMyAdmin service</li>
</ul>

<h3>III. Environment files:</h3>

<ul>
<li>MYSQL_DATABASE: Django database. Keep at 'easynut' or change sql files</li>
<li>DATA_DB_NAME: Easynut database. Keep at 'easynutdata' or change sql files</li>
<li>MYSQL_USER: Mysql EasyNut user</li>
<li>MYSQL_PASSWORD: Password of MySQL EasyNut user</li>
<li>MYSQL_ROOT_PASSWORD: MySQL root password</li>
<li>DB_HOST</li>: MySQL hostname. Keep at 'easynut_mysql' or change compose file</i>
<li>DB_SERVICE: Keep at 'mysql' or change compose file</li>
<li>DB_PORT: Keep at '3306' or change compose file</li>
<li>DEBUG: True or False for django debug</li>
<li>SECRET_KEY: Django secret key</li>
<li>ALLOWED_HOSTS: For django. If unknown, keep to 172.*</li>
<li>CRON_TIME: CRON timing for the historic backups. For example '55 23 * * *' for a daily backup realized at 23:55<i>(see <a href="https://en.wikipedia.org/wiki/Cron#CRON_expression">CRON expression</a> for an understanding of the timing, and below for an understanding of the backups)</i></li>
<li>CRON_TIME_L: For the "current" backup. For example '*/30 * * * *' for every half an hour.<li>
<li>MAX_BACKUPS: Number of historic backup to keep. The old ones are automatically deleted. For example 30, if historic backup everyday, you will always keep the last month.</li>
</ul>

<h3>IV. Databases:</h3>

When created for the first time, the MySQL container will execute all the scripts located in 
<br/>./mysql/docker-entrypoint-initdb.d/ (host)
<br/>/docker-entrypoint-initdb.d/ (container)

If you wish to create easynut with an existing database, delete the file ./mysql/docker-entrypoint-initdb.d/1_restore.sql (host) and copy the file of your choice in the folder. 
<br/><i>(see <a href="https://hub.docker.com/_/mysql/">MySQL Docker</a>)</i>
<ul>
<li>Note 1: Keep in mind that files are executed by alphabetical order. The file "2_easynut_web.sh" should always be executed at last as it deals with the mysql user permissions.</li>
<li>Note 2: The MySQL data are also persitant through a shared volume "easynutdocker_mysql_data". If you want to rebuild the mysql container with new data, think to delete the volume before hand.</li>
</ul>

<h3>V. Backups & Restore:</h3>

This service allows you encrypt backups of the database at regular frequency and restore them when needed.

<b>V.a) Backups</b>

The backups are bind into a data directory located in ./backups/backups/ in the host system. They are also available to web service for the download of the backups via the user interface.

Backups are first gunzipped and then encrypted using openssl and the mysql root password.

2 types of backups are made, both containing all databases:
<ul>
<li>Historical backups</li>: To keep track of the changes in the database. They begin with the date/time of the backup (format: YYYYMMDDHHMM). The frequency of this backup is set by the "CRON_TIME" variable. The number of backups is limited using "MAX_BACKUPS": oldest ones removed.
<li>Overriden backup: The most recent backup called "backup.gz.enc", being the one downloaded through the user interface. Its frequency is set by the "CRON_TIME_L" variable</li>
</ul>

<b>V.b) Restore</b>

The restore script can be used through the host as follow:
```
docker container exec easynut_backups /restore.sh /backup/backup.gz.enc 
```
And replace "backup.gz.enc" by the gunzipped and encrypted (<b>same enc. pass</b>) file that you want. 
<br/><i>(Note: in the container the folder '/backup' refers in the host to the folder "./backups/backups". You can therefore use the CRON backups already there or copy one from the host)</i>

<h3>VI. Known issues:</h3>
<ul>
<li>Easynut github branch: The "new_layout" branch currently used is not adequate for this compose setup.The files "settings.py" and "requirements.txt" are duplicated (the ones in these repository being used here) as the static files are not needed. -> Needs for merging and better git structure</li>
<li>Prod-oriented: careful considerations should be taken when using this repository in production.</li>
</ul>
