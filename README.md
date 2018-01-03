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

<b>Environment files</b>

<b>Backups:</b>

<b>Known caveats:</b>
