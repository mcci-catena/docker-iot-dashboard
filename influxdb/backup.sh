#!/bin/bash
#The Shell script will be used for taking backup and send it to Amazon s3 bucket.

# TO list all Databases in influxdb databases
DATE=`date +%d-%m-%y_%H-%M`
showdb(){
influx  -host $INFLUX_HOST -port 8086 -execute 'SHOW DATABASES'
}

showdb > /data.txt

sed -i '1,3d' /data.txt

#Backing up the metadata

echo 'Backup Influx metadata'
influxd backup -portable -host $INFLUX_HOST:8088 /var/lib/influxdb-backup


#Backing up the databases listed.
while read db
do
  echo "Creating backup for $db"
  influxd backup -portable -database "$db" -host $INFLUX_HOST:8088 /var/lib/influxdb-backup
done < "/data.txt"

# Moving the backup to Amazon Cloud
if [ $? -eq 0 ]; then

        tar czf /var/lib/influxdb-S3-bucket/${SOURCE_NAME}_metdata_db_backup_`date +%F`.tar.gz /var/lib/influxdb-backup/
        tar czf /var/lib/influxdb-S3-bucket/${SOURCE_NAME}_data_directory_backup_`date +%F`.tar.gz /var/lib/influxdb/
        aws s3  sync /var/lib/influxdb-S3-bucket/ s3://${S3_BUCKET_INFLUXDB}/
	echo "DATE:" $DATE > /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb backup" >> /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "STATUS: influxdb backup is Successful." >> /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "******* Influxdb Database & metadata Backup ********" >> /influxbackup.txt
	echo " " >> /influxbackup.txt
	aws s3 ls s3://${S3_BUCKET_INFLUXDB}/  --human-readable | grep -i ${SOURCE_NAME}_metdata | cut -d' ' -f3- | tac | head -10 &>> /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "************** Influxdb data Backup ****************" >> /influxbackup.txt
	echo " " >> /influxbackup.txt
	aws s3 ls s3://${S3_BUCKET_INFLUXDB}/  --human-readable | grep -i ${SOURCE_NAME}_data | cut -d' ' -f3- | tac | head -10 &>> /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "********************** END *********************  " >> /influxbackup.txt

else
	echo "DATE:" $DATE > /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb backup" >> /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "STATUS: influxdb backup is Failed." >> /influxbackup.txt
	echo " " >> /influxbackup.txt
	echo "Something went wrong, Please check it"  >> /influxbackup.txt
        cat /influxbackup.txt | mail -s "${SOURCE_NAME}: influxdb backup" ${INFLUXDB_BACKUP_MAIL} 
fi

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/influxdb-S3-bucket/ -type f -exec rm {} \;
find /var/lib/influxdb-backup/ -type f -exec rm {} \;

cat /influxbackup.txt | mail -s "${SOURCE_NAME}: influxdb backup" ${INFLUXDB_BACKUP_MAIL} 
