#BUILD SETUP

```sh 

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose up -d
Creating network "dockerttndashboard_default" with the default driver
Creating dockerttndashboard_influxdb_1 ...
Creating dockerttndashboard_influxdb_1 ... done
Creating dockerttndashboard_influxdb-backup_1 ...
Creating dockerttndashboard_node-red_1 ...
Creating dockerttndashboard_grafana_1 ...
Creating dockerttndashboard_influxdb-backup_1
Creating dockerttndashboard_grafana_1
Creating dockerttndashboard_node-red_1 ... done
Creating dockerttndashboard_apache_1 ...
Creating dockerttndashboard_apache_1 ... done`
```

##status of docker container and databases
```sh
cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose ps
Name                              Command               State                    Ports
------------------------------------------------------------------------------------------------------------------------
dockerttndashboard_apache_1            /bin/bash /root/setup.sh         Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
dockerttndashboard_grafana_1           /run.sh                          Up      3000/tcp
dockerttndashboard_influxdb-backup_1   /entrypoint.sh influxd           Up      8086/tcp
dockerttndashboard_influxdb_1          /entrypoint.sh influxd           Up      8086/tcp
dockerttndashboard_node-red_1          npm start -- --userDir /da ...   Up      1880/tcp

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.2.4
InfluxDB shell version: 1.2.4
> show databases
name: databases
name
----
_internal
demo
testdb

> use testdb
Using database testdb
> SELECT "host", "region", "value" FROM "cpu"
name: cpu
time                host    region  value
----                ----    ------  -----
1505798827323014326 serverA us_west 0.64

```

#BACKUP DATABASE THROUGH SHELL SCRIPT USING EXTRA INFLUXDB INSTANCE

`( Database name should be there in as environment variable separated by ":" ) `

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker exec -it dockerttndashboard_influxdb-backup_1 bash
root@5b41b750233b:/tmp# cd backup/

root@5b41b750233b:/tmp/backup# backup.sh
Backup Influx metadata
2017/09/19 07:29:47 backing up metastore to /tmp/backup/meta.00
2017/09/19 07:29:47 backup complete
Creating backup for demo
2017/09/19 07:29:47 backing up db=demo since 0001-01-01 00:00:00 +0000 UTC
2017/09/19 07:29:47 backing up metastore to /tmp/backup/meta.01
2017/09/19 07:29:47 backing up db=demo rp=autogen shard=12 to /tmp/backup/demo.autogen.00012.00 since 0001-01-01 00:00:00 +0000 UTC
2017/09/19 07:29:47 backup complete
Creating backup for _internal
2017/09/19 07:29:47 backing up db=_internal since 0001-01-01 00:00:00 +0000 UTC
2017/09/19 07:29:47 backing up metastore to /tmp/backup/meta.02
2017/09/19 07:29:47 backing up db=_internal rp=monitor shard=15 to /tmp/backup/_internal.monitor.00015.00 since 0001-01-01 00:00:00 +0000 UTC
2017/09/19 07:29:47 backup complete
Creating backup for testdb
2017/09/19 07:29:47 backing up db=testdb since 0001-01-01 00:00:00 +0000 UTC
2017/09/19 07:29:47 backing up metastore to /tmp/backup/meta.03
2017/09/19 07:29:47 backing up db=testdb rp=autogen shard=16 to /tmp/backup/testdb.autogen.00016.00 since 0001-01-01 00:00:00 +0000 UTC
2017/09/19 07:29:47 backup complete
```

##Backup has been taken in the below folder
```sh
root@5b41b750233b:/tmp/backup# ls
_internal.monitor.00015.00  demo.autogen.00012.00  meta.00  meta.01  meta.02  meta.03  testdb.autogen.00016.00
```
##Drop the "testdb" database for checking purpose

```sh
cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose exec influxdb influx
Connected to http://localhost:8086 version 1.2.4
InfluxDB shell version: 1.2.4
> show databases
name: databases
name
----
_internal
demo
testdb

> drop database testdb
> show databases
name: databases
name
----
_internal
demo
```

## RESTORE DROPPED DATABASE 

`(Stop the influxdb database in order to restore dropped "testdb" database)`

```sh

cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker-compose stop influxdb
Stopping dockerttndashboard_influxdb_1 ... done
cmurugan@iotserver:~/iot/docker-ttn-dashboard$ docker exec -it dockerttndashboard_influxdb-backup_1 bash
root@5b41b750233b:/tmp# influxd restore -metadir /var/lib/influxdb/meta /tmp/backup
Using metastore snapshot: /tmp/backup/meta.03
root@5b41b750233b:/tmp# influxd restore -database testdb -datadir /var/lib/influxdb/data /tmp/backup
Restoring from backup /tmp/backup/testdb.*
unpacking /var/lib/influxdb/data/testdb/autogen/16/000000001-000000001.tsm
```

##Start the influxdb database and check for whether database has been restored
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
demo
testdb

> use testdb
Using database testdb
> SELECT "host", "region", "value" FROM "cpu"
name: cpu
time                host    region  value
----                ----    ------  -----
1505798827323014326 serverA us_west 0.64

```
