# easynut-docker
Docker compose for EasyNut

<b>Installation steps:</b>

Required: docker, docker-compose (v3), git

First clone this repository:
```
git clone https://github.com/MSF-OCB/easynut-docker.git
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

<b>Structure:</b>

This project is composed of five services:
<ul>
<li>web: Django front that contains the application code</li>
<li>nginx: Nginx reverse proxy that will handle the static assets and forward the dynamic ones to the Django WSGI process.</li>
<li>mysql: MySQL database</li>
<li>redis: Redis database</li>
<li>backups: Restore from encrypted backups and cron encrypt backups</li>
</ul>

Environment files:
<i>In the environment file, if using "=", the values should not be surrounded by quotes</i>
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
<li>CRON_TIME: CRON for automated enccrypted backups. For example '0 * * * *' for a hourly backup</li>
<li>MAX_BACKUPS: Number of backup to keep. The old ones are automatically deleted</li>
</ul>

<b>Backups:</b>

<b>Known caveats:</b>
