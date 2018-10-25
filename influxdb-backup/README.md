# BUILD SETUP

```console 

cmurugan@iot:~/server/influx_api_version/docker-ttn-dashboard$ docker-compose up -d

dockerttndashboard_postfix_1 is up-to-date
Recreating dockerttndashboard_influxdb_1 ...
Recreating dockerttndashboard_influxdb_1 ... done
Recreating dockerttndashboard_grafana_1 ...
Recreating dockerttndashboard_grafana_1
Recreating dockerttndashboard_node-red_1 ...
Recreating dockerttndashboard_node-red_1 ... done
Recreating dockerttndashboard_apache_1 ...
Recreating dockerttndashboard_apache_1 ... done

```

### status of docker container and databases

```console

cmurugan@iot:~/server/influx_api_version/docker-ttn-dashboard$ docker-compose ps

            Name                           Command               State                    Ports
-----------------------------------------------------------------------------------------------------------------
dockerttndashboard_apache_1     /sbin/my_init                    Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
dockerttndashboard_grafana_1    /run.sh                          Up      3000/tcp
dockerttndashboard_influxdb_1   /entrypoint.sh influxd           Up      8086/tcp
dockerttndashboard_node-red_1   npm start -- --userDir /da ...   Up      1880/tcp
dockerttndashboard_postfix_1    /sbin/my_init                    Up      0.0.0.0:25->25/tcp

cmurugan@iot:~/server/influx_api_version/docker-ttn-dashboard$ docker-compose exec influxdb bash

root@a16175bb4ce0:/opt/influxdb-backup# influx
Connected to http://localhost:8086 version 1.6.4
InfluxDB shell version: 1.6.4
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

### Backup can be taken through shell script and synced with Amazon S3 cloud


```console

root@a16175bb4ce0:/opt/influxdb-backup# backup.sh

Backup Influx metadata
2018/10/25 11:00:44 backing up metastore to /var/lib/influxdb-backup/meta.00
2018/10/25 11:00:44 No database, retention policy or shard ID given. Full meta store backed up.
2018/10/25 11:00:44 Backing up all databases in portable format
2018/10/25 11:00:44 backing up db=
2018/10/25 11:00:44 backing up db=_internal rp=monitor shard=1 to /var/lib/influxdb-backup/_internal.monitor.00001.00 since 0001-01-01T00:00:00Z
2018/10/25 11:00:44 backing up db=_internal rp=monitor shard=6 to /var/lib/influxdb-backup/_internal.monitor.00006.00 since 0001-01-01T00:00:00Z
2018/10/25 11:00:44 backing up db=testdb rp=autogen shard=7 to /var/lib/influxdb-backup/testdb.autogen.00007.00 since 0001-01-01T00:00:00Z
2018/10/25 11:00:44 backup complete:
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.meta
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.s1.tar.gz
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.s6.tar.gz
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.s7.tar.gz
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.manifest
Creating backup for _internal
2018/10/25 11:00:44 backing up metastore to /var/lib/influxdb-backup/meta.00
2018/10/25 11:00:44 backing up db=_internal
2018/10/25 11:00:44 backing up db=_internal rp=monitor shard=1 to /var/lib/influxdb-backup/_internal.monitor.00001.00 since 0001-01-01T00:00:00Z
2018/10/25 11:00:44 backing up db=_internal rp=monitor shard=6 to /var/lib/influxdb-backup/_internal.monitor.00006.00 since 0001-01-01T00:00:00Z
2018/10/25 11:00:44 backup complete:
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.meta
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.s1.tar.gz
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.s6.tar.gz
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.manifest
Creating backup for testdb
2018/10/25 11:00:44 backing up metastore to /var/lib/influxdb-backup/meta.00
2018/10/25 11:00:44 backing up db=testdb
2018/10/25 11:00:44 backing up db=testdb rp=autogen shard=7 to /var/lib/influxdb-backup/testdb.autogen.00007.00 since 0001-01-01T00:00:00Z
2018/10/25 11:00:44 backup complete:
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.meta
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.s7.tar.gz
2018/10/25 11:00:44     /var/lib/influxdb-backup/20181025T110044Z.manifest
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
upload: ../../var/lib/influxdb-S3-bucket/data_directory_backup_2018-10-25.tar.gz to s3://mcci-influxdb-test/data_directory_backup_2018-10-25.tar.gz
upload: ../../var/lib/influxdb-S3-bucket/metdata_db_backup_2018-10-25.tar.gz to s3://mcci-influxdb-test/metdata_db_backup_2018-10-25.tar.gz

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

root@a16175bb4ce0:/opt/influxdb-backup# influx

Connected to http://localhost:8086 version 1.6.4
InfluxDB shell version: 1.6.4
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
### Restoring metadata and database 

```console

root@a16175bb4ce0:/opt/influxdb-backup# influxd restore -portable -host $INFLUX_HOST:8088 /var/lib/influxdb-backup

2018/10/25 11:02:48 Restoring shard 7 live from backup 20181025T110044Z.s7.tar.gz
2018/10/25 11:02:48 Meta info not found for shard 5 on database testdb. Skipping shard file 20181025T100801Z.s5.tar.gz
2018/10/25 11:02:48 Meta info not found for shard 1 on database _internal. Skipping shard file 20181025T095242Z.s1.tar.gz
2018/10/25 11:02:48 Meta info not found for shard 6 on database _internal. Skipping shard file 20181025T095242Z.s6.tar.gz
2018/10/25 11:02:48 Meta info not found for shard 3 on database testdb. Skipping shard file 20181024T143005Z.s3.tar.gz
2018/10/25 11:02:48 Meta info not found for shard 2 on database testdb. Skipping shard file 20181024T142358Z.s2.tar.gz

root@a16175bb4ce0:/opt/influxdb-backup# influxd restore -portable -host $INFLUX_HOST:8088 -database testdb /var/lib/influxdb-backup

2018/10/25 11:03:04 error updating meta: DB metadata not changed. database may already exist
restore: DB metadata not changed. database may already exist

### Checking the Database has been restored

```console 

root@a16175bb4ce0:/opt/influxdb-backup# influx
Connected to http://localhost:8086 version 1.6.4
InfluxDB shell version: 1.6.4
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
1540391379121807732 serverA us_west 0.64
> exit

```
