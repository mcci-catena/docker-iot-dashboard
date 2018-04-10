# BUILD SETUP

```console 

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose up -d
Creating network "dockerttndashboard_default" with the default driver
Creating dockerttndashboard_postfix_1 ...
Creating dockerttndashboard_influxdb_1 ...
Creating dockerttndashboard_influxdb_1
Creating dockerttndashboard_influxdb_1 ... done
Creating dockerttndashboard_postfix_1 ... done
Creating dockerttndashboard_influxdb-backup_1
Creating dockerttndashboard_node-red_1 ...
Creating dockerttndashboard_grafana_1 ...
Creating dockerttndashboard_grafana_1
Creating dockerttndashboard_node-red_1 ... done
Creating dockerttndashboard_apache_1 ...
Creating dockerttndashboard_apache_1 ... done

```

### status of docker container and databases

```console

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose ps
                Name                              Command               State                    Ports
------------------------------------------------------------------------------------------------------------------------
dockerttndashboard_apache_1            /sbin/my_init                    Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
dockerttndashboard_grafana_1           /run.sh                          Up      3000/tcp
dockerttndashboard_influxdb-backup_1   /sbin/my_init                    Up
dockerttndashboard_influxdb_1          /entrypoint.sh influxd           Up      8086/tcp
dockerttndashboard_node-red_1          npm start -- --userDir /da ...   Up      1880/tcp
dockerttndashboard_postfix_1           /sbin/my_init                    Up      0.0.0.0:25->25/tcp

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.4.0
InfluxDB shell version: 1.4.0
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
1523353042145216096 serverA us_west 0.64
> exit

```

## BACKUP DATABASE 

### Backup can be taken through shell script by using extra instance (influxdb-backup) and synced with Amazon S3 cloud


```console

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker exec -it dockerttndashboard_influxdb-backup_1 bash

root@56a388b52486:/opt/influxdb-backup# backup.sh
Backup Influx metadata
2018/04/10 09:50:52 backing up metastore to /var/lib/influxdb-backup/meta.03
2018/04/10 09:50:52 backup complete
Creating backup for _internal
2018/04/10 09:50:52 backing up db=_internal since 0001-01-01 00:00:00 +0000 UTC
2018/04/10 09:50:52 backing up metastore to /var/lib/influxdb-backup/meta.04
2018/04/10 09:50:52 backing up db=_internal rp=monitor shard=1 to /var/lib/influxdb-backup/_internal.monitor.00001.00 since 0001-01-01 00:00:00 +0000 UTC
2018/04/10 09:50:52 backing up db=_internal rp=monitor shard=2 to /var/lib/influxdb-backup/_internal.monitor.00002.00 since 0001-01-01 00:00:00 +0000 UTC
2018/04/10 09:50:52 backup complete
Creating backup for testdb
2018/04/10 09:50:52 backing up db=testdb since 0001-01-01 00:00:00 +0000 UTC
2018/04/10 09:50:52 backing up metastore to /var/lib/influxdb-backup/meta.05
2018/04/10 09:50:52 backing up db=testdb rp=autogen shard=3 to /var/lib/influxdb-backup/testdb.autogen.00003.00 since 0001-01-01 00:00:00 +0000 UTC
2018/04/10 09:50:52 backup complete
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
upload: ../../var/lib/amazon-bucket/data_directory_backup_2018-04-10.tar.gz to s3://mcci-influxdb-test/data_directory_backup_2018-04-10.tar.gz
upload: ../../var/lib/amazon-bucket/metdata_db_backup_2018-04-10.tar.gz to s3://mcci-influxdb-test/metdata_db_backup_2018-04-10.tar.gz

```

### Backup has been taken in the below folder

```console

root@56a388b52486:/opt/influxdb-backup# cd /var/lib/influxdb-backup/

root@56a388b52486:/var/lib/influxdb-backup# ls -al
total 456
drwxr-xr-x  2 root root   4096 Apr 10 09:50 .
drwxr-xr-x 35 root root   4096 Apr 10 09:50 ..
-rw-r--r--  1 root root 174592 Apr 10 09:50 _internal.monitor.00001.00
-rw-r--r--  1 root root 250368 Apr 10 09:50 _internal.monitor.00002.00
-rw-r--r--  1 root root    131 Apr  9 10:07 meta.00
-rw-r--r--  1 root root    234 Apr 10 09:38 meta.01
-rw-r--r--  1 root root    234 Apr 10 09:44 meta.02
-rw-r--r--  1 root root    234 Apr 10 09:50 meta.03
-rw-r--r--  1 root root    234 Apr 10 09:50 meta.04
-rw-r--r--  1 root root    234 Apr 10 09:50 meta.05
-rw-r--r--  1 root root   2048 Apr 10 09:50 testdb.autogen.00003.00

```

## RESTORE DATABASE 

### Drop the "testdb" database for checking purpose

```console

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.4.0
InfluxDB shell version: 1.4.0
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
> exit

```

`(Stop the influxdb database in order to restore dropped "testdb" database)`

```console

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose stop influxdb
Stopping dockerttndashboard_influxdb_1 ... done

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker exec -it dockerttndashboard_influxdb-backup_1 bash
root@56a388b52486:/opt/influxdb-backup# influxd restore -metadir /var/lib/influxdb/meta /var/lib/influxdb-backup
Using metastore snapshot: /var/lib/influxdb-backup/meta.05
root@56a388b52486:/opt/influxdb-backup# influxd restore -database testdb -datadir /var/lib/influxdb/data /var/lib/influxdb-backup
Restoring from backup /var/lib/influxdb-backup/testdb.*
unpacking /var/lib/influxdb/data/testdb/autogen/3/000000001-000000001.tsm


```

### Start the influxdb database and check for whether database has been restored

```console

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose start influxdb
Starting influxdb ... done

cmurugan@iotserver:/iot/main-server/docker-ttn-dashboard_version_updates/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.4.0
InfluxDB shell version: 1.4.0
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
1523353042145216096 serverA us_west 0.64
> exit

```
