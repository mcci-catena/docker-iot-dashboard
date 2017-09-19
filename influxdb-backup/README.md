# BUILD SETUP

```sh 

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose up -d
Creating network "dockerttndashboard_default" with the default driver
Creating dockerttndashboard_influxdb_1 ...
Creating dockerttndashboard_influxdb_1 ... done
Creating dockerttndashboard_influxdb-backup_1 ...
Creating dockerttndashboard_node-red_1 ...
Creating dockerttndashboard_grafana_1 ...
Creating dockerttndashboard_grafana_1
Creating dockerttndashboard_node-red_1
Creating dockerttndashboard_grafana_1 ... done
Creating dockerttndashboard_apache_1 ...
Creating dockerttndashboard_apache_1 ... done

```

## status of docker container and databases

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose ps
                Name                              Command               State                    Ports
------------------------------------------------------------------------------------------------------------------------
dockerttndashboard_apache_1            /bin/bash /root/setup.sh         Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
dockerttndashboard_apache_run_1        /bin/bash                        Up
dockerttndashboard_grafana_1           /run.sh                          Up      3000/tcp
dockerttndashboard_influxdb-backup_1   /entrypoint.sh influxd           Up      8086/tcp
dockerttndashboard_influxdb_1          /entrypoint.sh influxd           Up      8086/tcp
dockerttndashboard_node-red_1          npm start -- --userDir /da ...   Up      1880/tcp
cmurugan@iotserver:~/iot/docker-ttn-dashboard$


cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.2.4
InfluxDB shell version: 1.2.4
> show databases
name: databases
name
----
_internal

> create database testdb
> show databases
name: databases
name
----
_internal
testdb

> use testdb
Using database testdb
> INSERT cpu,host=serverA,region=us_west value=0.64
> SELECT * FROM cpu
name: cpu
time                host    region  value
----                ----    ------  -----
1508942563099443156 serverA us_west 0.64

```

# BACKUP DATABASE THROUGH SHELL SCRIPT USING EXTRA INFLUXDB INSTANCE

`( Database name should be there in as environment variable separated by ":" ) `

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker exec -it dockerttndashboard_influxdb-backup_1 bash

root@4e5dbfd20c5c:/opt/influxdb-backup# backup.sh
Backup Influx metadata
2017/10/25 14:48:59 backing up metastore to /var/lib/influxdb-backup/meta.00
2017/10/25 14:48:59 backup complete
Creating backup for _internal
2017/10/25 14:48:59 backing up db=_internal since 0001-01-01 00:00:00 +0000 UTC
2017/10/25 14:48:59 backing up metastore to /var/lib/influxdb-backup/meta.01
2017/10/25 14:48:59 backing up db=_internal rp=monitor shard=1 to /var/lib/influxdb-backup/_internal.monitor.00001.00 since 0001-01-01 00:00:00 +0000 UTC
2017/10/25 14:49:00 backup complete
Creating backup for testdb
2017/10/25 14:49:00 backing up db=testdb since 0001-01-01 00:00:00 +0000 UTC
2017/10/25 14:49:00 backing up metastore to /var/lib/influxdb-backup/meta.02
2017/10/25 14:49:00 backing up db=testdb rp=autogen shard=2 to /var/lib/influxdb-backup/testdb.autogen.00002.00 since 0001-01-01 00:00:00 +0000 UTC
2017/10/25 14:49:00 backup complete

```

## Backup has been taken in the below folder

```sh

root@4e5dbfd20c5c:/opt/influxdb-backup# cd /var/lib/influxdb-backup/
root@4e5dbfd20c5c:/var/lib/influxdb-backup# ls -al
total 136
drwxrwxr-x  2 1000 1000   4096 Oct 25 14:49 .
drwxr-xr-x 14 root root   4096 Oct 25 14:08 ..
-rw-r--r--  1 root root 110592 Oct 25 14:49 _internal.monitor.00001.00
-rw-r--r--  1 root root    204 Oct 25 14:48 meta.00
-rw-r--r--  1 root root    204 Oct 25 14:48 meta.01
-rw-r--r--  1 root root    204 Oct 25 14:49 meta.02
-rw-r--r--  1 root root   2048 Oct 25 14:49 testdb.autogen.00002.00

```
## Drop the "testdb" database for checking purpose

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.2.4
InfluxDB shell version: 1.2.4
> show databases
name: databases
name
----
_internal
testdb

> drop database testdb
> show databases
name: databases
name
----
_internal

```

## RESTORE DROPPED DATABASE 

`(Stop the influxdb database in order to restore dropped "testdb" database)`

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose stop influxdb
Stopping dockerttndashboard_influxdb_1 ... done

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker exec -it dockerttndashboard_influxdb-backup_1 bash

root@4e5dbfd20c5c:/opt/influxdb-backup# influxd restore -metadir /var/lib/influxdb/meta /var/lib/influxdb-backup
Using metastore snapshot: /var/lib/influxdb-backup/meta.02
root@4e5dbfd20c5c:/opt/influxdb-backup# influxd restore -database testdb -datadir /var/lib/influxdb/data /var/lib/influxdb-backup
Restoring from backup /var/lib/influxdb-backup/testdb.*
unpacking /var/lib/influxdb/data/testdb/autogen/2/000000001-000000001.tsm


```

## Start the influxdb database and check for whether database has been restored

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose start influxdb
Starting influxdb ... done

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.2.4
InfluxDB shell version: 1.2.4
> show databases
name: databases
name
----
_internal
testdb

> use testdb
Using database testdb
> SELECT * FROM cpu
name: cpu
time                host    region  value
----                ----    ------  -----
1508942563099443156 serverA us_west 0.64

```
