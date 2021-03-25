#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

# TO list all Databases in mongodb databases
DATE1=$(date +%Y%m%d%H%M)
DATE=`date +%d-%m-%y_%H-%M`

mkdir -p /var/lib/backup

nginx_src='/nginx'

if [ ! -d $nginx_src ]; then

        echo "DATE:" $DATE > /nginx.txt
        echo " " >> /nginx.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup" >> /nginx.txt
        echo " " >> /nginx.txt
        echo "STATUS: Nginx backup is Failed." >> /nginx.txt
        echo " " >> /nginx.txt
	echo "The source backup directory: nginx_src is not available" >> /nginx.txt
        cat /nginx.txt | mail -s "${SOURCE_NAME}: Nginx Data Backup" ${CRON_BACKUP_MAIL}
	exit
else
	tar cvzf /var/lib/backup/${SOURCE_NAME}_nginx_data_backup_${DATE1}.tgz ${nginx_src}/
fi

s3cmd sync --no-mime-magic /var/lib/backup/*nginx*.tgz s3://${S3_BUCKET_NGINX}/

# Moving the backup to S3 bucket
if [ $? -eq 0 ]; then

        echo "DATE:" $DATE > /nginx.txt
        echo " " >> /nginx.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup" >> /nginx.txt
        echo " " >> /nginx.txt
        echo "STATUS: Nginx backup is Successful." >> /nginx.txt
        echo " " >> /nginx.txt
        echo "******* Nginx Data Backup ****************" >> /nginx.txt
        echo " " >> /nginx.txt
        s3cmd ls --no-mime-magic s3://${S3_BUCKET_NGINX}/  --human-readable | grep -i ${SOURCE_NAME}_nginx_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_NGINX}\/,,g" &>> /nginx.txt
        echo " " >> /nginx.txt
        echo "************** END **************************" >> /nginx.txt

else
        echo "DATE:" $DATE > /nginx.txt
        echo " " >> /nginx.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup" >> /nginx.txt
        echo " " >> /nginx.txt
        echo "STATUS: Nginx backup is Failed." >> /nginx.txt
        echo " " >> /nginx.txt
        echo "Something went wrong, Please check it"  >> /nginx.txt
        cat /nginx.txt | mail -s "${SOURCE_NAME}: Nginx Data Backup" ${CRON_BACKUP_MAIL}
fi
cat /nginx.txt | mail -s "${SOURCE_NAME}: Nginx Data Backup" ${CRON_BACKUP_MAIL}

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/*nginx*.tgz -type f -exec rm {} \;

exit
