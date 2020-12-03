# Influxdb Backup

<!-- markdownlint-disable MD033 -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
<!-- TOC depthFrom:2 updateOnSave:true -->

- [Status of docker container and databases](#status-of-docker-container-and-databases)
- [Checking the databases available](#checking-the-databases-available)
- [Backing up Databases](#backing-up-databases)
- [Restoring Databases](#restoring-databases)

<!-- /TOC -->
<!-- markdownlint-restore -->
<!-- Due to a bug in Markdown TOC, the table is formatted incorrectly if tab indentation is set other than 4. Due to another bug, this comment must be *after* the TOC entry. -->

## Status of docker container and databases

```console
root@ithaca-power:/iot/testing/docker-iot-dashboard# docker-compose ps
             Name                            Command                  State                                       Ports
--------------------------------------------------------------------------------------------------------------------------------------------------------
docker-iot-dashboard_grafana_1    /run.sh                          Up             3000/tcp
docker-iot-dashboard_influxdb_1   /sbin/my_init                    Up             8086/tcp
docker-iot-dashboard_mqtts_1      /sbin/my_init                    Up             0.0.0.0:1883->1883/tcp, 0.0.0.0:8083->8083/tcp, 0.0.0.0:8883->8883/tcp
docker-iot-dashboard_nginx_1      /sbin/my_init                    Up             0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
docker-iot-dashboard_node-red_1   npm start -- --userDir /da ...   Up (healthy)   1880/tcp
docker-iot-dashboard_postfix_1    /sbin/my_init                    Up             25/tcp
```

## Checking the databases available

Moving to `influxdb` container.

```console
username@ithaca-power:/iot/testing/docker-iot-dashboard$ docker-compose exec influxdb bash
root@influxdb# cd /opt/influxdb-backup
root@influxdb:/opt/influxdb-backup# influx
Connected to http://localhost:8086 version 1.8.0
InfluxDB shell version: 1.8.0
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
1590247547512536078 serverA us_west 0.64
> exit
```

## Backing up Databases

Backup can be taken through shell script and synced with Amazon S3 cloud. When complete, mail notification will be sent for the backup.

The backup shell script `backup.sh` wiil be configured in Crontab while building. (For testing, run `backup.sh` manually )

The backup shell script `backup.sh` will back up everything.

```console
root@influxdb:/opt/influxdb-backup# backup.sh

Backup Influx metadata
2020/05/23 15:29:40 backing up metastore to /var/lib/influxdb-backup/meta.00
2020/05/23 15:29:40 No database, retention policy or shard ID given. Full meta store backed up.
2020/05/23 15:29:40 Backing up all databases in portable format
2020/05/23 15:29:40 backing up db=
2020/05/23 15:29:40 backing up db=_internal rp=monitor shard=1 to /var/lib/influxdb-backup/_internal.monitor.00001.00 since 0001-01-01T00:00:00Z
2020/05/23 15:29:40 backing up db=testdb rp=autogen shard=2 to /var/lib/influxdb-backup/testdb.autogen.00002.00 since 0001-01-01T00:00:00Z
2020/05/23 15:29:40 backup complete:
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.meta
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.s1.tar.gz
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.s2.tar.gz
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.manifest
Creating backup for _internal
2020/05/23 15:29:40 backing up metastore to /var/lib/influxdb-backup/meta.00
2020/05/23 15:29:40 backing up db=_internal
2020/05/23 15:29:40 backing up db=_internal rp=monitor shard=1 to /var/lib/influxdb-backup/_internal.monitor.00001.00 since 0001-01-01T00:00:00Z
2020/05/23 15:29:40 backup complete:
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.meta
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.s1.tar.gz
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.manifest
Creating backup for testdb
2020/05/23 15:29:40 backing up metastore to /var/lib/influxdb-backup/meta.00
2020/05/23 15:29:40 backing up db=testdb
2020/05/23 15:29:40 backing up db=testdb rp=autogen shard=2 to /var/lib/influxdb-backup/testdb.autogen.00002.00 since 0001-01-01T00:00:00Z
2020/05/23 15:29:40 backup complete:
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.meta
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.s2.tar.gz
2020/05/23 15:29:40     /var/lib/influxdb-backup/20200523T152940Z.manifest
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from hard link targets
upload: ../../var/lib/influxdb-S3-bucket/ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz to s3://mcci-influxdb-test/ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz
upload: ../../var/lib/influxdb-S3-bucket/ithaca-power.mcci.com_data_directory_backup_2020-05-23.tar.gz to s3://mcci-influxdb-test/ithaca-power.mcci.com_data_directory_backup_2020-05-23.tar.gz
```

* Backup files will be uploaded in Amazon S3 bucket. They can be viewed using below command.

```console
root@influxdb:/opt/influxdb-backup# aws s3 ls s3://${S3_BUCKET_INFLUXDB}/
root@influxdb:/opt/influxdb-backup# aws s3 ls s3://${S3_BUCKET_INFLUXDB}/ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz
2020-05-23 15:29:43      15447 ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz
```

# Influxdb Restore

## Restoring Databases

In this example, we drop the "`testdb`" database for checking purpose

```console
root@influxdb:/opt/influxdb-backup# influx
Connected to http://localhost:8086 version 1.8.0
InfluxDB shell version: 1.8.0
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

Next, we download the backed up databases from the Amazon S3 Bucket.

```console
root@influxdb:/opt/influxdb-backup# aws s3 cp s3://${S3_BUCKET_INFLUXDB}/ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz .
download: s3://mcci-influxdb-test/ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz to ./ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz
root@influxdb:/opt/influxdb-backup# ls -al
total 28
drwxr-xr-x 1 root root  4096 May 23 15:37 .
drwxr-xr-x 1 root root  4096 May 18 05:46 ..
-rw-r--r-- 1 root root 15447 May 23 15:29 ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz
```

We extract the backed up files.

```console
root@influxdb:/opt/influxdb-backup# tar xvf staging1-ithaca-power.mcci.com_metdata_db_backup_2020-05-23.tar.gz
var/lib/influxdb-backup/
var/lib/influxdb-backup/20200523T152940Z.meta
var/lib/influxdb-backup/20200523T152940Z.s1.tar.gz
var/lib/influxdb-backup/20200523T152940Z.s2.tar.gz
var/lib/influxdb-backup/20200523T152940Z.manifest
```

We restore all databases found within the backup directory.

```console
root@influxdb:/opt/influxdb-backup# influxd restore -portable -host $INFLUX_HOST:8088 var/lib/influxdb-backup/
2020/05/23 15:45:23 Restoring shard 2 live from backup 20200523T152940Z.s2.tar.gz
```

Finally, we check that the database has been restored

```console
root@influxdb:/opt/influxdb-backup# influx
Connected to http://localhost:8086 version 1.8.0
InfluxDB shell version: 1.8.0
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
1590247547512536078 serverA us_west 0.64
> exit
```