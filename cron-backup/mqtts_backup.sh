#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup/mqtts

mqtts_src='/mqtts'

if [ ! -d $mqtts_src ]; then

        echo "DATE:" "$DATE" > /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_MQTTs backup" >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "STATUS: MQTTs backup failed." >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "The source backup directory: mqtts_src is not available" >> /tmp/mqtts.txt
        < /tmp/mqtts.txt mail -s "${SOURCE_NAME}: MQTTs Data Backup" "${CRON_BACKUP_MAIL}"
        exit
else
        tar cvzf /var/lib/backup/mqtts/"${SOURCE_NAME}"_mqtts_data_backup_"${DATE1}".tgz ${mqtts_src}/
fi

# Moving the backup to S3 bucket
if s3cmd put -r --no-mime-magic /var/lib/backup/mqtts/ s3://"${S3_BUCKET_MQTTS}"/;
then
        echo "DATE:" "$DATE" > /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_MQTTs backup" >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "STATUS: MQTTs backup succeeded." >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "******* MQTTs Data Backup ****************" >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_MQTTS}"/  --human-readable | grep -i "${SOURCE_NAME}"_mqtts_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_MQTTS}\/,,g" &>> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "************** END **************************" >> /tmp/mqtts.txt
else
        echo "DATE:" "$DATE" > /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_MQTTs backup" >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "STATUS: MQTTs backup failed." >> /tmp/mqtts.txt
        echo "" >> /tmp/mqtts.txt
        echo "Something went wrong, please check it"  >> /tmp/mqtts.txt
        < /tmp/mqtts.txt mail -s "${SOURCE_NAME}: MQTTs Data Backup" "${CRON_BACKUP_MAIL}"
fi
< /tmp/mqtts.txt mail -s "${SOURCE_NAME}: MQTTs Data Backup" "${CRON_BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/mqtts/ -type f -exec rm {} \;

exit
