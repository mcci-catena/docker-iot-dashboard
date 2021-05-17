#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup

nodered_src='/nodered'

if [ ! -d $nodered_src ]; then

        echo "DATE:" $DATE > /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup" >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "STATUS: Nodered backup is Failed." >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
	echo "The source backup directory: nodered_src is not available" >> /tmp/node-red.txt
        < /tmp/node-red.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${CRON_BACKUP_MAIL}"
	exit
else
	tar cvzf /var/lib/backup/"${SOURCE_NAME}"_nodered_data_backup_"${DATE1}".tgz ${nodered_src}/
fi

s3cmd sync --no-mime-magic /var/lib/backup/*nodered*.tgz s3://"${S3_BUCKET_NODERED}"/

# Moving the backup to S3 bucket
if [ $? -eq 0 ]; then

        echo "DATE:" $DATE > /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup" >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "STATUS: Node-red backup is Successful." >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "******* Node-red Data Backup ****************" >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NODERED}"/  --human-readable | grep -i "${SOURCE_NAME}"_nodered_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_NODERED}\/,,g" &>> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "************** END **************************" >> /tmp/node-red.txt

else
        echo "DATE:" "$DATE" > /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup" >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "STATUS: Nodered backup is Failed." >> /tmp/node-red.txt
        echo " " >> /tmp/node-red.txt
        echo "Something went wrong, Please check it"  >> /tmp/node-red.txt
        < /tmp/node-red.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${CRON_BACKUP_MAIL}"
fi
< /tmp/node-red.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${CRON_BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/*nodered*.tgz -type f -exec rm {} \;

exit
