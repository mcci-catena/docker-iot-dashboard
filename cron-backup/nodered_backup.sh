#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup/nodered

nodered_src='/nodered'

if [ ! -d $nodered_src ]; then

        echo "DATE:" $DATE > /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup" >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "STATUS: Nodered backup failed." >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
	echo "The source backup directory: nodered_src is not available" >> /tmp/nodered.txt
        < /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${CRON_BACKUP_MAIL}"
	exit
else
	tar cvzf /var/lib/backup/nodered/"${SOURCE_NAME}"_nodered_data_backup_"${DATE1}".tgz ${nodered_src}/
fi

s3cmd put -r --no-mime-magic /var/lib/backup/nodered/ s3://"${S3_BUCKET_NODERED}"/

# Moving the backup to S3 bucket
if [ $? -eq 0 ]; then

        echo "DATE:" $DATE > /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup" >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "STATUS: Node-red backup succeeded." >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "******* Node-red Data Backup ****************" >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NODERED}"/  --human-readable | grep -i "${SOURCE_NAME}"_nodered_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_NODERED}\/,,g" &>> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "************** END **************************" >> /tmp/nodered.txt

else
        echo "DATE:" "$DATE" > /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup" >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "STATUS: Nodered backup failed." >> /tmp/nodered.txt
        echo "" >> /tmp/nodered.txt
        echo "Something went wrong, please check it"  >> /tmp/nodered.txt
        < /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${CRON_BACKUP_MAIL}"
fi
< /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${CRON_BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/nodered/ -type f -exec rm {} \;

exit
