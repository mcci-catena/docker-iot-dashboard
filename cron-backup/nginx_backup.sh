#!/bin/bash
#The Shell script will be used for taking backup and send it to S3 bucket.

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup/nginx

nginx_src='/nginx'

if [ ! -d $nginx_src ]; then

        echo "DATE:" "$DATE" > /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup" >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "STATUS: Nginx backup failed." >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
	echo "The source backup directory: nginx_src is not available" >> /tmp/nginx.txt
        < /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${CRON_BACKUP_MAIL}"
	exit
else
	tar cvzf /var/lib/backup/nginx/"${SOURCE_NAME}"_nginx_data_backup_"${DATE1}".tgz ${nginx_src}/
fi

# Moving the backup to S3 bucket
if s3cmd put -r --no-mime-magic /var/lib/backup/nginx/ s3://"${S3_BUCKET_NGINX}"/;
then
        echo "DATE:" "$DATE" > /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup" >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "STATUS: Nginx backup succeeded." >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "******* Nginx Data Backup ****************" >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NGINX}"/  --human-readable | grep -i "${SOURCE_NAME}"_nginx_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/${S3_BUCKET_NGINX}\/,,g" &>> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "************** END **************************" >> /tmp/nginx.txt

else
        echo "DATE:" "$DATE" > /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup" >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "STATUS: Nginx backup failed." >> /tmp/nginx.txt
        echo "" >> /tmp/nginx.txt
        echo "Something went wrong, please check it"  >> /tmp/nginx.txt
        < /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${CRON_BACKUP_MAIL}"
fi
< /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${CRON_BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/nginx/ -type f -exec rm {} \;

exit
