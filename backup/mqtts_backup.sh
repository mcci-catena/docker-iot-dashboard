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


mkdir -p /var/lib/backup/mqtts

mqtts_src='/mqtts'

if [ ! -d $mqtts_src ]; then
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts backup"
        echo "" 
        echo "STATUS: Mqtts backup failed"
        echo "" 
        echo "The source backup directory: mqtts_src is not available" 
        }>> /tmp/mqtts.txt
        < /tmp/mqtts.txt mail -s "${SOURCE_NAME}: Mqtts Data Backup" "${BACKUP_MAIL}"
        exit
else
        tar cvzf /var/lib/backup/mqtts/"${SOURCE_NAME}"_mqtts_data_backup_"${DATE1}".tgz ${mqtts_src}/
fi

# Moving the backup to S3 bucket (Daily backup)
if s3cmd put -r --no-mime-magic /var/lib/backup/mqtts/ s3://"${S3_BUCKET_MQTTS}"/mqtts/;
then
      {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts Daily backup"
        echo ""
        echo "STATUS: Mqtts Daily backup succeeded."
        echo ""
        echo "******* Mqtts Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_MQTTS}"/mqtts/  --human-readable | grep -i "${SOURCE_NAME}"_mqtts_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_MQTTS}""\/,,g" &>> /tmp/mqtts.txt
        echo ""
        echo "************** END **************************"
      } >> /tmp/mqtts.txt
else
{       echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts Daily backup"
        echo ""
        echo "STATUS: Mqtts Daily backup failed"
        echo ""
        echo "Something went wrong, please check it" 
 } >> /tmp/mqtts.txt
        < /tmp/mqtts.txt mail -s "${SOURCE_NAME}: Mqtts Data Backup" "${BACKUP_MAIL}"
fi


# Moving the backup to S3 bucket (Monthly backup)
if [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/mqtts/ s3://"${S3_BUCKET_MQTTS}"/monthly_backup/mqtts/;
then
       {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts Monthly backup"
        echo ""
        echo "STATUS: Mqtts Monthly backup succeeded."
        echo "" >> /tmp/mqtts.txt
        echo "******* Mqtts Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_MQTTS}"/monthly_backup/mqtts/  --human-readable | grep -i "${SOURCE_NAME}"_mqtts_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_MQTTS}""/monthly_backup/mqtts/\/,,g" &>> /tmp/mqtts.txt
        echo ""
        echo "************** END **************************"
         } >> /tmp/mqtts.txt    
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts Monthly backup"
        echo ""
        echo "STATUS: Mqtts Monthly backup failed"
        echo ""
        echo "Something went wrong, please check it" 
        }>> /tmp/mqtts.txt
        < /tmp/mqtts.txt mail -s "${SOURCE_NAME}: Mqtts Data Backup" "${BACKUP_MAIL}"
fi
fi


# Moving the backup to S3 bucket (Yearly backup)
if [ "$a" == "$b" ] || [ "$a" == "$c" ] || [ "$a" == "$d" ] || [ "$a" == "$e" ] && [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/mqtts/ s3://"${S3_BUCKET_MQTTS}"/yearly_backup/mqtts/;
then
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts Yearly backup"
        echo ""
        echo "STATUS: Mqtts Yearly backup succeeded."
        echo ""
        echo "******* Mqtts Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_MQTTS}"/yearly_backup/mqtts/  --human-readable | grep -i "${SOURCE_NAME}"_mqtts_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_MQTTS}""/yearly_backup/mqtts/\/,,g" &>> /tmp/mqtts.txt
        echo ""
        echo "************** END **************************"
        } >> /tmp/mqtts.txt
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Mqtts Yearly backup"
        echo "" 
        echo "STATUS: Mqtts Yearly backup failed" 
        echo ""
        echo "Something went wrong, please check it"  
        }>> /tmp/mqtts.txt
        < /tmp/mqtts.txt mail -s "${SOURCE_NAME}: Mqtts Data Backup" "${BACKUP_MAIL}"
fi
fi


< /tmp/mqtts.txt mail -s "${SOURCE_NAME}: Mqtts Data Backup" "${BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/mqtts/ -type f -exec rm {} \;
rm /tmp/mqtts.txt
###PRUNE###

# prune the old backup data in S3 bucket to avoid excessive storage use(Daily backup)
s3cmd ls -r s3://"${S3_BUCKET_MQTTS}"/mqtts/ | awk -v DEL="$(date +%F -d "31 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done


if [ "$(date -d +1day +%d)" -eq 01 ]; then
# prune the old backup data in S3 bucket to avoid excessive storage use(Monthly backup)
s3cmd ls -r s3://"${S3_BUCKET_MQTTS}"/monthly_backup/mqtts/ | awk -v DEL="$(date +%F -d "366 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done
fi