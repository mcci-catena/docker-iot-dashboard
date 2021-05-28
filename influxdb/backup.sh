#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

# TO list all Databases in influxdb databases
DATE=$(date +%d-%m-%y_%H-%M)
DATE1=$(date +%Y%m%d%H%M)

mkdir -p /var/lib/backup/influxdb
mkdir -p /var/lib/influxdb-backup

showdb(){
influx  -host "$INFLUX_HOST" -port 8086 -execute 'SHOW DATABASES'
}

showdb > /tmp/data.txt

sed -i '1,3d' /tmp/data.txt

#Backing up the metadata

echo 'Backup influx metadata'
influxd backup -portable -host "$INFLUX_HOST":8088 /var/lib/influxdb-backup


#Backing up the databases listed.
while read -r db
do
  echo "Creating backup for $db"
  influxd backup -portable -database "$db" -host "$INFLUX_HOST":8088 /var/lib/influxdb-backup
done < "/tmp/data.txt"


tar czf /var/lib/backup/influxdb/"${SOURCE_NAME}"_influxdb_metdata_db_backup_"${DATE1}".tgz /var/lib/influxdb-backup/ && tar czf /var/lib/backup/influxdb/${SOURCE_NAME}_influxdb_data_backup_${DATE1}.tgz /var/lib/influxdb/

s3cmd put -r --no-mime-magic /var/lib/backup/influxdb/ s3://"${S3_BUCKET_INFLUXDB}"/

# Moving the backup to S3 bucket
if [ $? -eq 0 ]; then

        echo "DATE:" "$DATE" > /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb backup" >> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "STATUS: Influxdb backup succeeded." >> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "******* Influxdb Database & metadata Backup ********" >> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_metdata_db | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "************** Influxdb data Backup ****************" >> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "********************** END *********************  " >> /tmp/influxbackup.txt

else
        echo "DATE:" $DATE > /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb backup" >> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "STATUS: Influxdb backup failed." >> /tmp/influxbackup.txt
        echo "" >> /tmp/influxbackup.txt
        echo "Something went wrong, please check it"  >> /tmp/influxbackup.txt
        < /tmp/influxbackup.txt mail -s "${SOURCE_NAME}: Influxdb backup" "${INFLUXDB_BACKUP_MAIL}"
fi

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/influxdb/ -type f -exec rm {} \;
find /var/lib/influxdb-backup/ -type f -exec rm {} \;

< /tmp/influxbackup.txt mail -s "${SOURCE_NAME}: Influxdb backup" "${INFLUXDB_BACKUP_MAIL}"
