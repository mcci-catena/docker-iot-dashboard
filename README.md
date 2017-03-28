# Dashboard example for The Things Network

This repository contains a complete example that grabs device data from The Things Network, stores it in a database, and then displays the data using a web-based dashboard.

You can set this up on a "Ubuntu + Docker" VM from the Microsoft Azure store with minimal effort. You should set up this service to run all the time so as to capture the data from your devices; you then access the data at your convenience using a web browser.

This example uses [docker-compose](https://docs.docker.com/compose/overview/) to set up a pipeline of three [docker containers](https://www.docker.com):

1. An instance of [Node-RED](http://nodered.org/), which processes the data from the individual nodes, and puts it into the database.
2. An instance of [InfluxDB](https://www.influxdata.com/), which stores the data as time-series measurements with tags.
3. An instance of [Grafana](http://grafana.org/), which gives a web-based dashboard interface to the data.

To make things more specific, most of the description here assumes use of Microsoft Azure. However, I have tested this on Ubuntu 16 LTS without difficulty (apart from the additional complexity of setting up `apt-get` to fetch docker, and the need for a manual install of `docker-compose`). I belive that this will work on any Linux or Linux-like platform that supports docker, docker-compose, and node-red. It's likely to run on a Raspberry Pi 2, and it might even run on a C.H.I.P. computer... but as of this writing, this has not been tested.

## Security
This version uses fixed login keys, which you should edit prior to deploying. The keys are in the files `ingressdb/.env` and `grafana/.env`.

This version does **not** natively provide HTTPS for securing access to the various services.

Microsoft Azure, by default, will not open any of the ports to the outside world, so the above two items are not a concern until you open the ports.

Rather than opening ports on Azure, we suggest you use SSH and proxy the ports:
```sh
ssh -L10080:localhost:80 -L11880:localhost:1880 -L180:localhost:8083 -L18086:localhost:8086 user@myhost.example.net
```
Then use port addresses when opening the remote service in your browser, specificaly:

To access | Open this link
----------|---------------
Node-RED | [http://localhost:11800](http://localhost:11800)
IngressDB administrative page | [http://localhost:18083](http://localhost:18083)
Grafana | [http://localhost:10080](http://localhost:10080)

This can be visualized as below:
![Connection Architecture using SSH](assets/Connection-architecture.png)

## Assumptions

* You must have docker-compose 1.9 or later (for which see https://github.com/docker-compose -- be aware that apt-get normally doesn't grab this; if configured at all, it frequently gets an out-of-date version).
* `/var/lib/node-red` will have your local Node-RED data.
* `/var/lib/influxdb` will have your local influxdb data (this is what you should back up)
* `/var/lib/grafana` will have your dashboards

## Composition and External Ports

Within their containers, the individual programs use their usual ports, but these are isolated from the outside world, except as specified by `docker-compose.yml`.

In `docker-compose.yml`, the following ports on the docker host are connected to the individual programs.

* Node-RED runs on port 1880.
* Grafana runs on port 80.
* The API port for InfluxDB runs on port 8086 and is linked as host name **influxdb** (without a domain name; this is used when connecting from the other two docker images, so as to keep the traffic internal to the node).
* The administrative services for InfluxDB are available to a web browser on port 8083.

Remember, if your server is running on a cloud platform like Microsoft Azure or AWS, you'll either need to open up the firewall (and deal with security), or use SSH tunneling as described above.

## Installation

1. Make sure your server has `git`, `docker` and `docker-compose` installed, with the versions mentioned above under **Assumptions**.
2. Use `git clone` to copy this repository to your host.
3. Define root URL and passwords in `grafana/.env` and `influxdb/.env`
4. `% docker-compose build`
5. `% docker-compose up`
6. Open Node-RED on **http://machine.example.net:1880** (or, if using the above SSH mappings, **[http://localhost:11880](http://localhost:11880)**) and build a flow that stores data in InfluxDB
7. Open Grafana on **http://machine.example.net** (or, if using the above SSH mappings, **[http://localhost:10080](http://localhost:10080)**), and build a dashboard that retrieves data from InfluxDB

## Data Files

When designing this collection of services, we had to decide where to store the data files. We had two choices: keep them inside the docker containers, or keep them in locations on the host system. The advantage of the the former is that everything is reset when you rebuild the docker images. The disavantage of the former is that you lose all your data when you rebuild. On the other hand, there's another level of indirection when keeping things on the host, as the files reside in different locations on the host and in the docker containers.

Data files are kept in the following locations by default.

Component | Data file location on host | Location in container
----------|----------------------------|----------------------
Node-RED | `/var/lib/node-red` | `/data`
InfluxDB | `/var/lib/influxdb`| `/data`
Grafana | `/var/lib/grafana`| `/var/lib/grafana`

You can quickly override the default locations on the **host** (e.g. for testing). You do this by setting the environment variable `TTN_DASHBOARD_DATA` to the **absolute path** to the containing directory prior to calling `docker-compose up`. The above paths are appended to the value of `TTN_DASHBOARD_DATA`. Directories are created as needed. Consider the following example:
```bash
% export TTN_DASHBOARD_DATA=/dashboard-data
% docker-compose up -d
```
In this case, the data files are created in the following locations:

Component | Data file location
----------|-------------------
Node-RED | `/dashboard-data/var/lib/node-red`
InfluxDB | `/dashboard-data/var/lib/influxdb`
Grafana | `/dashboard-data/var/lib/grafana`

### Reuse and removal of data files
Since data files on the host are not removed between runs, as long as you
don't remove the files between runs, your data will preserved.

Sometimes this is inconvienient, and you'll want to remove some or all of the
data. For a variety of reasons, the data files and directories are created owned by root, so you must use the `sudo` command to remove the data files. Here's an example of how to do it:
```bash
% sudo rm -rf /var/lib/node-red
% sudo rm -rf /var/lib/influxdb
% sudo rm -rf /var/lib/grafana
```

## Node-RED and Grafana Examples

This version requires that you set up Node-RED, the database and the grafana dashboards manually, but we hope to add a reasonable set of initial files in the next release.

## Connecting to InfluxDB from Node-RED and Grafana

There is one point that is somewhat confusing about the connections from Node-RED and Grafana to InfluxDB. Even though InfluxDB is running on the same host, it is logically running on its own virtual machine (created by docker). Because of this, Node-RED and Grafana cannot use **localhost** when connecting to Grafana. A special name is provided by docker: **influxdb**.  Note that there's no DNS suffix.  If you don't use **influxdb**, Node-RED and Grafana will not be able to connect.

## Logging in to Grafana
* On the login screen, the user name is "admin". The password is given by the value of the variable `GF_SECURITY_ADMIN_PASSWORD` in `grafana/.env`.

### Data source settings in Grafana
* Set the URL (under Http Settings) to `http://influxdb:8086`.
* Select the database. There's a default database called "demo", which is always created. (This is determined by the file `influxdb/.env`.)
* Set the user to "admin"
* Set the password to the value given for `INFLUXDB_INIT_PWD` in `influxdb/.env`.
* Click "Save & Test".


## Acknowledgements
This builds on work done by Johan Stokking of [The Things Network](www.thethingsnetwork.org) for the staging environment. Additional adaptation done by Terry Moore of [MCCI](www.mcci.com).

