#!/bin/bash
#Purpose: The Shell script will be used for taking backup and send it to S3 bucket and Prune Old Data in S3 Bucket.
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
DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)

mkdir -p /var/lib/backup/nginx

nginx_src='/nginx'

if [ ! -d $nginx_src ]; then
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx backup"
        echo "" 
        echo "STATUS: Nginx backup failed"
        echo "" 
        echo "The source backup directory: nginx_src is not available" 
        }>> /tmp/nginx.txt
        < /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${BACKUP_MAIL}"
        exit
else
        tar cvzf /var/lib/backup/nginx/"${SOURCE_NAME}"_nginx_data_backup_"${DATE1}".tgz ${nginx_src}/
fi

# Moving the backup to S3 bucket (Daily backup)
if s3cmd put -r --no-mime-magic /var/lib/backup/nginx/ s3://"${S3_BUCKET_NGINX}"/nginx/;
then
      {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx Daily backup"
        echo ""
        echo "STATUS: Nginx Daily backup succeeded."
        echo ""
        echo "******* Nginx Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NGINX}"/nginx/  --human-readable | grep -i "${SOURCE_NAME}"_nginx_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_NGINX}""\/,,g" &>> /tmp/nginx.txt
        echo ""
        echo "************** END **************************"
      } >> /tmp/nginx.txt
else
{       echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx Daily backup"
        echo ""
        echo "STATUS: Nginx Daily backup failed"
        echo ""
        echo "Something went wrong, please check it" 
 } >> /tmp/nginx.txt
        < /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${BACKUP_MAIL}"
fi


# Moving the backup to S3 bucket (Monthly backup)
if [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/nginx/ s3://"${S3_BUCKET_NGINX}"/monthly_backup/nginx/;
then
       {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx Monthly backup"
        echo ""
        echo "STATUS: Nginx Monthly backup succeeded."
        echo "" >> /tmp/nginx.txt
        echo "******* Nginx Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NGINX}"/monthly_backup/nginx/  --human-readable | grep -i "${SOURCE_NAME}"_nginx_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_NGINX}""/monthly_backup/nginx/\/,,g" &>> /tmp/nginx.txt
        echo ""
        echo "************** END **************************"
         } >> /tmp/nginx.txt    
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx Monthly backup"
        echo ""
        echo "STATUS: Nginx Monthly backup failed"
        echo ""
        echo "Something went wrong, please check it" 
        }>> /tmp/nginx.txt
        < /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${BACKUP_MAIL}"
fi
fi


# Moving the backup to S3 bucket (Yearly backup)
if [ "$a" == "$b" ] || [ "$a" == "$c" ] || [ "$a" == "$d" ] || [ "$a" == "$e" ] && [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/nginx/ s3://"${S3_BUCKET_NGINX}"/yearly_backup/nginx/;
then
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx Yearly backup"
        echo ""
        echo "STATUS: Nginx Yearly backup succeeded."
        echo ""
        echo "******* Nginx Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NGINX}"/yearly_backup/nginx/  --human-readable | grep -i "${SOURCE_NAME}"_nginx_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_NGINX}""/yearly_backup/nginx/\/,,g" &>> /tmp/nginx.txt
        echo ""
        echo "************** END **************************"
        } >> /tmp/nginx.txt
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nginx Yearly backup"
        echo "" 
        echo "STATUS: Nginx Yearly backup failed" 
        echo ""
        echo "Something went wrong, please check it"  
        }>> /tmp/nginx.txt
        < /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${BACKUP_MAIL}"
fi
fi


< /tmp/nginx.txt mail -s "${SOURCE_NAME}: Nginx Data Backup" "${BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/nginx/ -type f -exec rm {} \;
rm /tmp/nginx.txt
###PRUNE###

# prune the old backup data in S3 bucket to avoid excessive storage use(Daily backup)
s3cmd ls -r s3://"${S3_BUCKET_NGINX}"/nginx/ | awk -v DEL="$(date +%F -d "31 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done


if [ "$(date -d +1day +%d)" -eq 01 ]; then
# prune the old backup data in S3 bucket to avoid excessive storage use(Monthly backup)
s3cmd ls -r s3://"${S3_BUCKET_NGINX}"/monthly_backup/nginx/ | awk -v DEL="$(date +%F -d "366 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done
fi