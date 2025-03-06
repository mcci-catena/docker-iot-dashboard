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

mkdir -p /var/lib/backup/grafana

grafana_src='/grafana'

if [ ! -d $grafana_src ]; then
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana backup"
        echo "" 
        echo "STATUS: Grafana backup failed"
        echo "" 
        echo "The source backup directory: grafana_src is not available" 
        }>> /tmp/grafana.txt
        < /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${BACKUP_MAIL}"
        exit
else
        tar cvzf /var/lib/backup/grafana/"${SOURCE_NAME}"_grafana_data_backup_"${DATE1}".tgz ${grafana_src}/
fi

# Moving the backup to S3 bucket (Daily backup)
if s3cmd put -r --no-mime-magic /var/lib/backup/grafana/ s3://"${S3_BUCKET_GRAFANA}"/grafana/;
then
      {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana Daily backup"
        echo ""
        echo "STATUS: Grafana Daily backup succeeded."
        echo ""
        echo "******* Grafana Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_GRAFANA}"/grafana/  --human-readable | grep -i "${SOURCE_NAME}"_grafana_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_GRAFANA}""\/,,g" &>> /tmp/grafana.txt
        echo ""
        echo "************** END **************************"
      } >> /tmp/grafana.txt
else
{       echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana Daily backup"
        echo ""
        echo "STATUS: Grafana Daily backup failed"
        echo ""
        echo "Something went wrong, please check it" 
 } >> /tmp/grafana.txt
        < /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${BACKUP_MAIL}"
fi


# Moving the backup to S3 bucket (Monthly backup)
if [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/grafana/ s3://"${S3_BUCKET_GRAFANA}"/monthly_backup/grafana/;
then
       {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana Monthly backup"
        echo ""
        echo "STATUS: Grafana Monthly backup succeeded."
        echo "" >> /tmp/grafana.txt
        echo "******* Grafana Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_GRAFANA}"/monthly_backup/grafana/  --human-readable | grep -i "${SOURCE_NAME}"_grafana_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_GRAFANA}""/monthly_backup/grafana/\/,,g" &>> /tmp/grafana.txt
        echo ""
        echo "************** END **************************"
         } >> /tmp/grafana.txt    
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana Monthly backup"
        echo ""
        echo "STATUS: Grafana Monthly backup failed"
        echo ""
        echo "Something went wrong, please check it" 
        }>> /tmp/grafana.txt
        < /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${BACKUP_MAIL}"
fi
fi


# Moving the backup to S3 bucket (Yearly backup)
if [ "$a" == "$b" ] || [ "$a" == "$c" ] || [ "$a" == "$d" ] || [ "$a" == "$e" ] && [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/grafana/ s3://"${S3_BUCKET_GRAFANA}"/yearly_backup/grafana/;
then
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana Yearly backup"
        echo ""
        echo "STATUS: Grafana Yearly backup succeeded."
        echo ""
        echo "******* Grafana Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_GRAFANA}"/yearly_backup/grafana/  --human-readable | grep -i "${SOURCE_NAME}"_grafana_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_GRAFANA}""/yearly_backup/grafana/\/,,g" &>> /tmp/grafana.txt
        echo ""
        echo "************** END **************************"
        } >> /tmp/grafana.txt
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Grafana Yearly backup"
        echo "" 
        echo "STATUS: Grafana Yearly backup failed" 
        echo ""
        echo "Something went wrong, please check it"  
        }>> /tmp/grafana.txt
        < /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${BACKUP_MAIL}"
fi
fi


< /tmp/grafana.txt mail -s "${SOURCE_NAME}: Grafana Data Backup" "${BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/grafana/ -type f -exec rm {} \;
rm /tmp/grafana.txt
###PRUNE###

# prune the old backup data in S3 bucket to avoid excessive storage use(Daily backup)
s3cmd ls -r s3://"${S3_BUCKET_GRAFANA}"/grafana/ | awk -v DEL="$(date +%F -d "31 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done


if [ "$(date -d +1day +%d)" -eq 01 ]; then
# prune the old backup data in S3 bucket to avoid excessive storage use(Monthly backup)
s3cmd ls -r s3://"${S3_BUCKET_GRAFANA}"/monthly_backup/grafana/ | awk -v DEL="$(date +%F -d "366 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done
fi
