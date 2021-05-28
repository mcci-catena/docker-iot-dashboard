#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup/grafana

grafana_src='/grafana'

if [ ! -d $grafana_src ]; then

        echo "DATE:" "$DATE" > /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup" >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "STATUS: Grafana backup failed" >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
	echo "The source backup directory: grafana_src is not available" >> /tmp/grafana.txt
        < /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${CRON_BACKUP_MAIL}"
	exit
else
	tar cvzf /var/lib/backup/grafana/"${SOURCE_NAME}"_grafana_data_backup_"${DATE1}".tgz ${grafana_src}/
fi

# Moving the backup to S3 bucket
if s3cmd put -r --no-mime-magic /var/lib/backup/grafana/ s3://"${S3_BUCKET_GRAFANA}"/;
then
        echo "DATE:" "$DATE" > /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup" >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "STATUS: Grafana backup succeeded." >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "******* Grafana Data Backup ****************" >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_GRAFANA}"/  --human-readable | grep -i "${SOURCE_NAME}"_grafana_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_GRAFANA}\/,,g" &>> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "************** END **************************" >> /tmp/grafana.txt

else
        echo "DATE:" "$DATE" > /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup" >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "STATUS: Grafana backup failed" >> /tmp/grafana.txt
        echo "" >> /tmp/grafana.txt
        echo "Something went wrong, please check it"  >> /tmp/grafana.txt
        < /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${CRON_BACKUP_MAIL}"
fi
< /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${CRON_BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/grafana/ -type f -exec rm {} \;

exit
