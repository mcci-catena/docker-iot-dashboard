#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup

grafana_src='/grafana'

if [ ! -d $grafana_src ]; then

        echo "DATE:" $DATE > /grafana.txt
        echo " " >> /grafana.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup" >> /grafana.txt
        echo " " >> /grafana.txt
        echo "STATUS: Grafana backup is Failed." >> /grafana.txt
        echo " " >> /grafana.txt
	echo "The source backup directory: grafana_src is not available" >> /grafana.txt
        < /grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${CRON_BACKUP_MAIL}"
	exit
else
	tar cvzf /var/lib/backup/"${SOURCE_NAME}"_grafana_data_backup_"${DATE1}".tgz ${grafana_src}/
fi

s3cmd sync --no-mime-magic /var/lib/backup/*grafana*.tgz s3://"${S3_BUCKET_GRAFANA}"/

# Moving the backup to S3 bucket
if [ $? -eq 0 ]; then

        echo "DATE:" $DATE > /grafana.txt
        echo " " >> /grafana.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup" >> /grafana.txt
        echo " " >> /grafana.txt
        echo "STATUS: Grafana backup is Successful." >> /grafana.txt
        echo " " >> /grafana.txt
        echo "******* Grafana Data Backup ****************" >> /grafana.txt
        echo " " >> /grafana.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_GRAFANA}"/  --human-readable | grep -i "${SOURCE_NAME}"_grafana_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_GRAFANA}\/,,g" &>> /grafana.txt
        echo " " >> /grafana.txt
        echo "************** END **************************" >> /grafana.txt

else
        echo "DATE:" $DATE > /grafana.txt
        echo " " >> /grafana.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup" >> /grafana.txt
        echo " " >> /grafana.txt
        echo "STATUS: Grafana backup is Failed." >> /grafana.txt
        echo " " >> /grafana.txt
        echo "Something went wrong, Please check it"  >> /grafana.txt
        < /grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${CRON_BACKUP_MAIL}"
fi
< /grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${CRON_BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/*grafana*.tgz -type f -exec rm {} \;

exit
