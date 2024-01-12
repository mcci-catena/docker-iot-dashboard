#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.
#Version:v0.1
#Created Date:2022-08-26
#Modified Date:12-10-2022
#Reviewer: Terry Moore.
#Author: Shashi, VishnuNambi.

a=$(date +%b)
b=Mar
c=Jun
d=Sep
e=Dec
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

tar czf /var/lib/backup/influxdb/"${SOURCE_NAME}"_influxdb_metdata_db_backup_"${DATE1}".tgz /var/lib/influxdb-backup/ && tar czf /var/lib/backup/influxdb/"${SOURCE_NAME}"_influxdb_data_backup_"${DATE1}".tgz /var/lib/influxdb/

# Moving the backup to S3 bucket (Daily Backup)
if s3cmd put -r --no-mime-magic /var/lib/backup/influxdb/ s3://"${S3_BUCKET_INFLUXDB}"/influxdb/;
then
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb Daily backup"
        echo ""
        echo "STATUS: Influxdb Daily backup succeeded."
        echo ""
        echo "******* Influxdb Database & metadata Backup ********"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/influxdb/ --human-readable | grep -i "${SOURCE_NAME}"_influxdb_metdata_db | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo ""
        echo "************** Influxdb data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/influxdb/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo ""
        echo "********************** END *********************  " 
        }>> /tmp/influxbackup.txt
else
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb Daily backup"
        echo "" 
        echo "STATUS: Influxdb Daily backup failed."
        echo "" 
        echo "Something went wrong, please check it"  
        }>> /tmp/influxbackup.txt
        < /tmp/influxbackup.txt mail -s "${SOURCE_NAME}: Influxdb backup" "${INFLUXDB_BACKUP_MAIL}"
fi
# Moving the backup to S3 bucket (Monthly backup)
if [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/influxdb/ s3://"${S3_BUCKET_INFLUXDB}"/monthly_backup/influxdb/;
then
 {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb Monthly backup"
        echo ""
        echo "STATUS: Influxdb Monthly backup succeeded."
        echo ""
        echo "******* Influxdb Database & metadata Backup ********"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/monthly_backup/influxdb/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_metdata_db | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo ""
        echo "************** Influxdb data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/monthly_backup/influxdb/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo ""
        echo "********************** END *********************  " 
        }>> /tmp/influxbackup.txt
else
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb Monthly backup"
        echo "" 
        echo "STATUS: Influxdb Monthly backup failed."
        echo "" 
        echo "Something went wrong, please check it"  
        }>> /tmp/influxbackup.txt
        < /tmp/influxbackup.txt mail -s "${SOURCE_NAME}: Influxdb backup" "${INFLUXDB_BACKUP_MAIL}"
fi
fi


# Moving the backup to S3 bucket (Yearly backup)
if [ "$a" == "$b" ] || [ "$a" == "$c" ] || [ "$a" == "$d" ] || [ "$a" == "$e" ] && [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/influxdb/ s3://"${S3_BUCKET_INFLUXDB}"/yearly_backup/influxdb/;
then
 {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb Yearly backup"
        echo ""
        echo "STATUS: Influxdb Yearly backup succeeded."
        echo ""
        echo "******* Influxdb Database & metadata Backup ********"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/yearly_backup/influxdb/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_metdata_db | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo ""
        echo "************** Influxdb data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_INFLUXDB}"/yearly_backup/influxdb/  --human-readable | grep -i "${SOURCE_NAME}"_influxdb_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_INFLUXDB}\/,,g" &>> /tmp/influxbackup.txt
        echo ""
        echo "********************** END *********************  " 
        }>> /tmp/influxbackup.txt
else
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Influxdb Yearly backup"
        echo "" 
        echo "STATUS: Influxdb Yearly backup failed."
        echo "" 
        echo "Something went wrong, please check it"  
        }>> /tmp/influxbackup.txt
        < /tmp/influxbackup.txt mail -s "${SOURCE_NAME}: Influxdb backup" "${INFLUXDB_BACKUP_MAIL}"
fi
fi
# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/influxdb/ -type f -exec rm {} \;
find /var/lib/influxdb-backup/ -type f -exec rm {} \;

< /tmp/influxbackup.txt mail -s "${SOURCE_NAME}: Influxdb backup" "${INFLUXDB_BACKUP_MAIL}"
###PRUNE###
rm /tmp/influxbackup.txt
# prune the old backup data in S3 bucket to avoid excessive storage use(Daily backup)
s3cmd ls -r s3://"${S3_BUCKET_INFLUXDB}"/influxdb/ | awk -v DEL="$(date +%F -d "31 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done


if [ "$(date -d +1day +%d)" -eq 01 ]; then
# prune the old backup data in S3 bucket to avoid excessive storage use(Monthly backup)
s3cmd ls -r s3://"${S3_BUCKET_INFLUXDB}"/monthly_backup/influxdb/ | awk -v DEL="$(date +%F -d "366 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done
fi
