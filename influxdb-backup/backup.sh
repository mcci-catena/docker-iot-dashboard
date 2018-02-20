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

if [ $? -eq 0 ]; then

        tar czf /var/lib/amazon-bucket/metdata_db_backup_`date +%F`.tar.gz /var/lib/influxdb-backup/
        tar czf /var/lib/amazon-bucket/data_directory_backup_`date +%F`.tar.gz /var/lib/influxdb/
        aws s3  sync /var/lib/amazon-bucket/ s3://${S3_BUCKET_INFLUXDB}/

fi

find /var/lib/amazon-bucket/ -type f -mtime +90 -exec rm {} \;

