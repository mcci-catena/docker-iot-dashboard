# Setup Dashstack Next

## Setup GitHub Write Access if needed

For write access to the repo, add your SSH Key to Github.

Put your new devhost Pub key on GitHub:\
i.e.

* From: `cat ~/.ssh/id_ed25519.pub`
* To: [https://github.com/settings/keys](https://github.com/settings/keys)

## Clone the DashStack Repo

This repo was formed form the MCCI IoT-Dashboard.

* [https://github.com/sheeriot/dashstack](https://github.com/sheeriot/dashstack)

Clone the DashStack Repo to the `/opt/docker` folder:

>`git clone git@github.com:sheeriot/dashstack.git /opt/docker/dashstack`

Change to the new directory for `docker-compose` operations:

>`cd /opt/docker/dashstack`

## Create a Compose .env File for Variables

You need a file named `.env` in the docker-compose folder.

Sample `.env` contents:

```bash
IOT_DASHBOARD_NGINX_FQDN=surveyor1.somedomain.yours
IOT_DASHBOARD_CERTBOT_FQDN=surveyor1.somedomain.yours

IOT_DASHBOARD_CERTBOT_EMAIL=certs@somedomain.yours

IOT_DASHBOARD_DATA=/var/opt/dashstack

IOT_DASHBOARD_GRAFANA_SMTP_FROM_ADDRESS=monitor@somedomain.yours
IOT_DASHBOARD_GRAFANA_ADMIN_PASSWORD=${GETYOUROWN}

IOT_DASHBOARD_INFLUXDB_INITIAL_DATABASE_NAME=iotdashdb

IOT_DASHBOARD_NODERED_INSTALL_PLUGINS=node-red-contrib-influxdb node-red-node-base64

IOT_DASHBOARD_TIMEZONE=America/Chicago
```

## Setup the .htpasswd files

The .htpasswd files MUST be setup next. Do this by running the NGINX container and the htpasswd script.

### Create htpasswd files

Startup the Docker-compose with the NGINX server in "run" mode (not executing the entrypoint). This allows you to setup NGINX before the first run.

```bash
kris@iotdash-dev-surveyor:/opt/docker/dashstack$ docker-compose run nginx bash
```

First run, all containers are build and started (NGINX started with `bash` shell only).

Now you are connected to `root` on the NGINX container, run these steps to setup your two .htpasswd files.

```bash
touch /etc/nginx/authdata/influxdb/.htpasswd
touch /etc/nginx/authdata/nodered/.htpasswd
chown www-data /etc/nginx/authdata/influxdb/.htpasswd
chown www-data /etc/nginx/authdata/nodered/.htpasswd
```

### Create HTTP Users

Two .htpasswd files for http access to two apps: Node-RED, InfluxDB.

Use the htpasswd command to set users with passwords.

#### Node-RED Users

This is an example only, define your own users.

```bash
export USERS="kris opsadmin"
for USER in $USERS; do \
 echo "Set password for "$USER; \
 htpasswd /etc/nginx/authdata/nodered/.htpasswd $USER; \
done
```

#### InfluxDB Users

This is an example only, define your own users.

```bash
export USERS="kris nodered surveyor"
for USER in $USERS; do \
 echo "Set password for "$USER; \
 htpasswd /etc/nginx/authdata/influxdb/.htpasswd $USER; \
done
```

NGINX users are ready. Exit the container (`exit`).

Bring the docker-compose stack for the next step (MQTTS users).

> `docker-compose down`


## Setup MQTT users

Run the mqtts container to setup the Mosquitto credentials. Example below.

This is an example only, define your own users.

```bash
$ cd /opt/docker/dashstack
$ docker-compose run mqtts /bin/bash
Creating dashstack_mqtts_run ... done
root@mqtts:/#
```

Now connected to the `mqtts` container in a bash shell, setup the MQTTS users as shown in the example below

```bash
mosquitto_passwd -c /etc/mosquitto/credentials/passwd kris
Password: 
Reenter password:
```

Be sure to `exit` the container and bring `docker-compose down`.

## Docker-Compose Up

With the passwords setup, you are now ready for `docker-compose up`.

Start the Docker-Compose stack:

> `docker-compose up`

This starts all containers and keeps them connected to the terminal. Use this to watch the container logs until all looks good.

Start the Docker-Compose stack and Detach with:

> `docker-compose up -d`

### RTFM

* docker-compose ps
* docker-compose logs
