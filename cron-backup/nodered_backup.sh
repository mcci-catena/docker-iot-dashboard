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

mkdir -p /var/lib/backup/nodered

nodered_src='/nodered'

if [ ! -d $nodered_src ]; then
        {
        echo "DATE:" "$DATE"
        echo "" 
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered backup"
        echo "" 
        echo "STATUS: Nodered backup failed"
        echo "" 
        echo "The source backup directory: nodered_src is not available" 
        }>> /tmp/nodered.txt
        < /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${BACKUP_MAIL}"
        exit
else
        tar cvzf /var/lib/backup/nodered/"${SOURCE_NAME}"_nodered_data_backup_"${DATE1}".tgz ${nodered_src}/
fi

# Moving the backup to S3 bucket (Daily backup)
if s3cmd put -r --no-mime-magic /var/lib/backup/nodered/ s3://"${S3_BUCKET_NODERED}"/nodered/;
then
      {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered Daily backup"
        echo ""
        echo "STATUS: Nodered Daily backup succeeded."
        echo ""
        echo "******* Nodered Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NODERED}"/nodered/  --human-readable | grep -i "${SOURCE_NAME}"_nodered_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_NODERED}""\/,,g" &>> /tmp/nodered.txt
        echo ""
        echo "************** END **************************"
      } >> /tmp/nodered.txt
else
{       echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered Daily backup"
        echo ""
        echo "STATUS: Nodered Daily backup failed"
        echo ""
        echo "Something went wrong, please check it" 
 } >> /tmp/nodered.txt
        < /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${BACKUP_MAIL}"
fi


# Moving the backup to S3 bucket (Monthly backup)
if [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/nodered/ s3://"${S3_BUCKET_NODERED}"/monthly_backup/nodered/;
then
       {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered Monthly backup"
        echo ""
        echo "STATUS: Nodered Monthly backup succeeded."
        echo "" >> /tmp/nodered.txt
        echo "******* Nodered Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NODERED}"/monthly_backup/nodered/  --human-readable | grep -i "${SOURCE_NAME}"_nodered_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_NODERED}""/monthly_backup/nodered/\/,,g" &>> /tmp/nodered.txt
        echo ""
        echo "************** END **************************"
         } >> /tmp/nodered.txt    
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered Monthly backup"
        echo ""
        echo "STATUS: Nodered Monthly backup failed"
        echo ""
        echo "Something went wrong, please check it" 
        }>> /tmp/nodered.txt
        < /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${BACKUP_MAIL}"
fi
fi


# Moving the backup to S3 bucket (Yearly backup)
if [ "$a" == "$b" ] || [ "$a" == "$c" ] || [ "$a" == "$d" ] || [ "$a" == "$e" ] && [ "$(date -d +1day +%d)" -eq 01 ]; then
if s3cmd put -r --no-mime-magic /var/lib/backup/nodered/ s3://"${S3_BUCKET_NODERED}"/yearly_backup/nodered/;
then
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered Yearly backup"
        echo ""
        echo "STATUS: Nodered Yearly backup succeeded."
        echo ""
        echo "******* Nodered Data Backup ****************"
        echo ""
        s3cmd ls --no-mime-magic s3://"${S3_BUCKET_NODERED}"/yearly_backup/nodered/  --human-readable | grep -i "${SOURCE_NAME}"_nodered_data | cut -d' ' -f3- | tac | head -10 | sed "s,s3:\/\/""${S3_BUCKET_NODERED}""/yearly_backup/nodered/\/,,g" &>> /tmp/nodered.txt
        echo ""
        echo "************** END **************************"
        } >> /tmp/nodered.txt
else
        {
        echo "DATE:" "$DATE"
        echo ""
        echo "DESCRIPTION: ${SOURCE_NAME}_Nodered Yearly backup"
        echo "" 
        echo "STATUS: Nodered Yearly backup failed" 
        echo ""
        echo "Something went wrong, please check it"  
        }>> /tmp/nodered.txt
        < /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${BACKUP_MAIL}"
fi
fi


< /tmp/nodered.txt mail -s "${SOURCE_NAME}: Nodered Data Backup" "${BACKUP_MAIL}"

# Remove the old backup data in local directory to avoid excessive storage use
find /var/lib/backup/nodered/ -type f -exec rm {} \;
rm /tmp/nodered.txt

###PRUNE###

# prune the old backup data in S3 bucket to avoid excessive storage use(Daily backup)
s3cmd ls -r s3://"${S3_BUCKET_NODERED}"/nodered/ | awk -v DEL="$(date +%F -d "31 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done


if [ "$(date -d +1day +%d)" -eq 01 ]; then
# prune the old backup data in S3 bucket to avoid excessive storage use(Monthly backup)
s3cmd ls -r s3://"${S3_BUCKET_NODERED}"/monthly_backup/nodered/ | awk -v DEL="$(date +%F -d "366 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done
fi
