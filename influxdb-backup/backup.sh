#!/bin/bash
#The Shell script will be used for taking backup 

DATABASES=$(/bin/showdb.sh)

echo 'Backup Influx metadata'
influxd backup -host $INFLUX_HOST:8088 /var/lib/influxdb-backup

# Replace colons with spaces to create list.
for db in ${DATABASES//:/ }; do
  echo "Creating backup for $db"
  influxd backup -database $db -host $INFLUX_HOST:8088 /var/lib/influxdb-backup
done

