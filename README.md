# Dashboard example for Internet of Things (IoT)

This repository contains a complete example that grabs device data from IoT-Network server, stores it in a database, and then displays the data using a web-based dashboard.

You can set this up on a "Ubuntu + Docker" VM from the Microsoft Azure store (or on a Ubuntu VM from [DreamCompute](https://www.dreamhost.com/cloud/computing/), or on a Docker droplet from [Digital Ocean](https://www.digitalocean.com/)) with minimal effort. You should set up this service to run all the time so as to capture the data from your devices; you then access the data at your convenience using a web browser.

**Table of Contents**

<!-- markdownlint-disable MD033 -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
<!-- TOC depthFrom:2 updateOnSave:true -->

- [Introduction](#introduction)
- [Definitions](#definitions)
- [Security](#security)
- [Assumptions](#assumptions)
- [Composition and External Ports](#composition-and-external-ports)
- [Data Files](#data-files)
- [Reuse and removal of data files](#reuse-and-removal-of-data-files)
- [Node-RED and Grafana Examples](#node-red-and-grafana-examples)
	- [Connecting to InfluxDB from Node-RED and Grafana](#connecting-to-influxdb-from-node-red-and-grafana)
	- [Logging in to Grafana](#logging-in-to-grafana)
	- [Data source settings in Grafana](#data-source-settings-in-grafana)
- [MQTTS Examples](#mqtts-examples)
- [Setup Instructions](#setup-instructions)
- [Influxdb Backup and Restore](#influxdb-backup-and-restore)
- [Meta](#meta)

<!-- /TOC -->
<!-- markdownlint-restore -->
<!-- Due to a bug in Markdown TOC, the table is formatted incorrectly if tab indentation is set other than 4. Due to another bug, this comment must be *after* the TOC entry. -->

## Introduction

This [`SETUP.md`](./SETUP.md) explains the Application Server Installation and its setup. [Docker](https://docs.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) are used to make the installation and
setup easier.

This dashboard uses [docker-compose](https://docs.docker.com/compose/overview/) to set up a group of five primary [docker containers](https://www.docker.com), backed by one auxiliary container:

1. An instance of [Nginx](https://www.nginx.com/), which proxies the other services, handles access control, gets SSL certificates from [Let's Encrypt](https://letsencrypt.org/), and faces the outside world.

2. An instance of [Node-RED](http://nodered.org/), which processes the data from the individual nodes, and puts it into the database.

3. An instance of [InfluxDB](https://docs.influxdata.com/influxdb/), which stores the data as time-series measurements with tags.

4. An instance of [Grafana](http://grafana.org/), which gives a web-based dashboard interface to the data.

5. An instance of [Mqtt](https://mosquitto.org/), which provides a lightweight method of carrying out messaging using a publish/subscribe model

The auxiliary container is:

1. [Postfix](http://www.postfix.org/documentation.html), which (if configured) handles outbound mail services for the containers.

To make things more specific, most of the description here assumes use of Microsoft Azure. However, this was tested on Ubuntu 16 with no issues (apart from the additional complexity of setting up `apt-get` to fetch docker, and the need for a manual install of `docker-compose`), on Dream Compute, and on Digital Ocean This will work on any Linux or Linux-like platform that supports docker, docker-compose, and Node-. Its likelihood of working with Raspberry Pi has not been tested as yet.

## Definitions

- The **host system** is the system that runs Docker and Docker-compose.

- A **container** is one of the virtual systems running under Docker on the host system.

- A **file on the host** is a file present on the host system (typically not
    visible from within the container(s)).

- A **file in container X** (or a **file in the X container**) is a file
    present in a file-system associated with container *X* (and typically not
    visible from the host system).

## Security

All communication with the Nginx server is encrypted using SSL with auto-provisioned certificates from Let's Encrypt. Grafana is the primary point of access for most users, and Grafana's login is used for that purpose. Access to Node-RED and InfluxDB is via special URLs (**base**/node-red/ and **base**/influxdb:8086/, where **base** is the URL served by the Nginx container). These URLs are protected via Nginx `htpasswd` file entries. These entries are files in the Nginx container, and must be manually edited by an Administrator.

The initial administrator's login password for Grafana must be initialized prior to starting; it's stored in `.env`. (When the Grafana container is started for the first time, it creates `grafana.db` in the Grafana container, and stores
the password at that time. If `grafana.db` already exists, the password in grafana/.env is ignored.)

Microsoft Azure, by default, will not open any of the ports to the outside world, so the user will need to open port 443 for SSL access to Nginx.

For concreteness, the following table assumes that **base** is “server.example.com”.

**User Access**

|**To access**| **Open this link**| **Notes**|
|-------------|-------------------|----------|
| Node-RED    | <https://server.example.com/node-red/> | Port number is not needed and shouldn't be used. Note trailing '/' after node-red.                        |
| InfluxDB API queries | <https://server.example.com/influxdb:8086/> | Port number is needed. Also note trailing '/' after influxdb.                                             |
| Grafana    | [https://server.example.com](https://server.example.com/)| Port number is not needed and shouldn't be used.                                                          |
| Mqtt       | <wss://server.example.com/mqtts/>| Mqtt client is needed. To test it via [Mqtt web portal](https://www.eclipse.org/paho/clients/js/utility/) |

This can be visualized as shown in the figure below:

**Docker connection and User Access**

![Connection Architecture using SSH](assets/Connection-architecture.png)

## Assumptions

- The host system must have docker-compose verison 1.9 or later (for which <https://github.com/docker-compose> -- be aware that apt-get normally doesn't grab this; if configured at all, it frequently gets an out-of-date version).

- The environment variable `IOT_DASHBOARD_DATA`, if set, points to the common directory for the data. If not set, docker-compose will quit at start-up. (This is by design!)

  - `${IOT_DASHBOARD_DATA}node-red` will have the local Node-RED data.

  - `${IOT_DASHBOARD_DATA}influxdb`  will have the local InfluxDB data (this should be backed-up)

  - `${IOT_DASHBOARD_DATA}grafana` will have all the dashboards

  - `${IOT_DASHBOARD_DATA}docker-nginx` will have `.htpasswd` credentials folder `authdata` and Let's Encrypt certs folder `letsencrypt`

  - `${IOT_DASHBOARD_DATA}mqtt/credentials` will have the user credentials

## Composition and External Ports

Within the containers, the individual programs use their usual ports, but these are isolated from the outside world, except as specified by `docker-compose.yml` file.

In `docker-compose.yml`, the following ports on the docker host are connected to the individual programs.

- Nginx runs on 80 and 443. (All connections to port 80 are redirected to 443 using SSL).

Remember, if the server is running on a cloud platform like Microsoft Azure or AWS, one needs to check the firewall and confirm that the ports are open to the outside world.

## Data Files

When designing this collection of services, there were two choices to store the
data files:

- we could keep them inside the docker containers, or

- we could keep them in locations on the host system.

The advantage of the former is that everything is reset when the docker images are rebuilt. The disadvantage of the former is that there is a possibility to lose all the data when it’s rebuilt. On the other hand, there's another level of indirection when keeping things on the host, as the files reside in different locations on the host and in the docker containers.

Because IoT data is generally persistent, we decided that the the extra level of indirection was required. To help find things, consult the followign table. Data files are kept in the following locations by default.

| **Component** | **Data file location on host**| **Location in container**  |
|---------------|-----------|----------------------------|
| Node-RED      | `${IOT_DASHBOARD_DATA}node-red`| /data
| InfluxDB      |  `${IOT_DASHBOARD_DATA}influxdb` | /var/lib/influxdb
| Grafana       | `${IOT_DASHBOARD_DATA}grafana` | /var/lib/grafana|
| Mqtt | `${IOT_DASHBOARD_DATA}mqtt/credentials` | /etc/mosquitto/credentials
| Nginx | `${IOT_DASHBOARD_DATA}docker-nginx/authdata`| /etc/nginx/authdata
| Let's Encrypt certificates |`${IOT_DASHBOARD_DATA}docker-nginx/letsencrypt`|/etc/letsencrypt

As shown, one can easily change locations on the **host** (e.g. for testing). This can be done by setting the environment variable `IOT_DASHBOARD_DATA` to the **absolute path** (with trailing slash) to the containing directory prior to
calling `docker-compose up`. The above paths are appended to the value of `IOT_DASHBOARD_DATA`. Directories are created as needed.

Normally, this is done by an appropriate setting in the `.env` file.

Consider the following example:

```console
$ grep IOT_DASHBOARD_DATA .env
IOT_DASHBOARD_DATA=/dashboard-data/
$ docker-compose up –d
```

In this case, the data files are created in the following locations:

Table Data Location Examples

| **Component** | **Data file location**            |
|---------------|-----------------------------------|
| Node-RED      | /dashboard-data/node-red          |
| InfluxDB      | /dashboard-data/influxdb          |
| Grafana       | /dashboard-data/grafana           |
| Mqtt          | /dashboard-data/ mqtt/credentials |
| Nginx         | /dashboard-data/docker-nginx/authdata|
| Certificates  | /dashboard-data/docker-nginx/letsencrypt

## Reuse and removal of data files

Since data files on the host are not removed between runs, as long as the files are not removed between runs, the data will be preserved.

Sometimes this is inconvenient, and it is necessary to remove some or all of the data. For a variety of reasons, the data files and directories are created owned by root, so the `sudo` command must be used to remove the data files. Here's an example of how to do it:

```bash
source .env
sudo rm -rf ${IOT_DASHBOARD_DATA}node-red
sudo rm -rf ${IOT_DASHBOARD_DATA}influxdb
sudo rm -rf ${IOT_DASHBOARD_DATA}Grafana
sudo rm –rf ${IOT_DASHBOARD_DATA}mqtt/credentials
```

## Node-RED and Grafana Examples

This version requires that you set up Node-RED, the Influxdb database and the Grafana dashboards manually, but we hope to add a reasonable set of initial files in a future release.

### Connecting to InfluxDB from Node-RED and Grafana

There is one point that is somewhat confusing about the connections from Node-RED and Grafana to InfluxDB. Even though InfluxDB is running on the same host, it is logically running on its own virtual machine (created by docker). Because of this, Node-RED and Grafana cannot use **`local host`** when connecting to Grafana. A special name is provided by docker: `influxdb`. Note that there's no DNS suffix. If `InfluxDB` is not used, Node-RED and Grafana will not be able to connect.

### Logging in to Grafana

On the login screen, the initial user name is "`admin`". The initial password is given by the value of the variable `GF_SECURITY_ADMIN_PASSWORD` in `.env`. Note that if you change the password in `.env` after the first time you launch the grafana container, the admin password does not change. If you somehow lose the previous value of the admin password, and you don't have another admin login, it's very hard to recover; easiest is to remove `grafana.db` and start over.

### Data source settings in Grafana

- Set the URL (under HTTP Settings) to <http://influxdb:8086>.

- Select the database.

- Leave the username and password blank.

- Click "Save & Test".

## MQTTS Examples

Mqtts can be accessed in the following ways:

Method  |  Path  | Credentials
--------|--------|-------------
MQTT over Nginx proxy | https://dashboard.example.com/mqtts/:443 | Username/Password come from mosquitto’s configuration (password_file)
MQTT over TLS/SSL | https://dashboard.example.com:8883 | Username/Password come from mosquitto’s configuration (password_file)
WebSockets over TLS/SSL | https://dashboard.example.com:8083 | Username/Password come from mosquitto’s configuration (password_file)
MQTT over TCP protocol (not secure) | http://dashboard.example.com:1883 |Username/Password come from mosquitto’s configuration (password_file)

- To test the above channels (other than "MQTT over Nginx proxy"), the user also will need a [mosquitto
client](https://mosquitto.org/download/) tool.

- In order to test the "MQTT over Nginx proxy", the user should use the [mqtt web portal](https://www.eclipse.org/paho/clients/js/utility/) tool.

## Setup Instructions

Please refer to [`SETUP.md`](./SETUP.md) for detailed set-up instructions.

## Influxdb Backup and Restore

Please refer to [`influxdb/README.md`](./influxdb/README.md).

## Meta
