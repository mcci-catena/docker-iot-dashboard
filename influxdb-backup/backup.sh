#!/bin/bash
#The Shell script will be used for taking backup and send it to Amazon s3 bucket. 

DATABASES=$(/bin/showdb.sh)

echo 'Backup Influx metadata'
influxd backup -portable -host $INFLUX_HOST:8088 /var/lib/influxdb-backup

# Replace colons with spaces to create list.
for db in ${DATABASES//:/ }; do
  echo "Creating backup for $db"
  influxd backup -portable -database $db -host $INFLUX_HOST:8088 /var/lib/influxdb-backup
done

if [ $? -eq 0 ]; then

        tar czf /var/lib/influxdb-S3-bucket/metdata_db_backup_`date +%F`.tar.gz /var/lib/influxdb-backup/
        tar czf /var/lib/influxdb-S3-bucket/data_directory_backup_`date +%F`.tar.gz /var/lib/influxdb/
        aws s3  sync /var/lib/influxdb-S3-bucket/ s3://${S3_BUCKET_INFLUXDB}/

fi

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/influxdb-S3-bucket/ -type f -mtime +90 -exec rm {} \;

