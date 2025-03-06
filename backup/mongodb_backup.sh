#!/bin/bash
# Shell script for MongoDB backup with pruning and S3 strategy

DATE1=$(date +%Y%m%d%H%M)
DATE=$(date +%d-%m-%y_%H-%M)
MONTH=$(date +%b)
backup_dir="/var/lib/backup/mongodb"
mongodb_backup_dir="/var/lib/mongodb-backup"
mongodb_data_dir="/root/mongodb_data"
report_file="/tmp/mongodbbackup.txt"

mkdir -p $backup_dir $mongodb_backup_dir $mongodb_data_dir

# Full MongoDB backup
mongodump --host mongodb:27017 --authenticationDatabase admin -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" -o $mongodb_backup_dir

# List databases
mongosh --quiet --host mongodb:27017 --eval "printjson(db.adminCommand('listDatabases'))" \
  -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" \
  | grep -i name | awk -F'"' '{print $4}' > /mongo_dbs.txt

# Backup listed databases
while read -r db; do
  echo "Creating backup for $db"
  mongodump --host mongodb:27017 --db "$db" --authenticationDatabase admin \
    -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" -o $mongodb_backup_dir
done < /mongo_dbs.txt

# Archive backups
tar czf "$backup_dir/${SOURCE_NAME}_mongodb_db_backup_${DATE1}.tgz" $mongodb_backup_dir/. \
  && rsync -avr /var/lib/mongodb/ $mongodb_data_dir/ \
  && tar czf "$backup_dir/${SOURCE_NAME}_mongodb_data_backup_${DATE1}.tgz" $mongodb_data_dir/.

# Upload backups to S3 (Daily Backup)
if s3cmd put -r --no-mime-magic $backup_dir/ s3://"${S3_BUCKET_MONGODB}"/daily_backup/; then
  echo "Daily backup succeeded." >> $report_file
else
  echo "Daily backup failed." >> $report_file
fi

# Monthly Backup
if [ "$(date -d +1day +%d)" -eq 1 ]; then
  if s3cmd put -r --no-mime-magic $backup_dir/ s3://"${S3_BUCKET_MONGODB}"/monthly_backup/; then
    echo "Monthly backup succeeded." >> $report_file
  else
    echo "Monthly backup failed." >> $report_file
  fi
fi

# Quarterly Backup
if [[ "$MONTH" == "Mar" || "$MONTH" == "Jun" || "$MONTH" == "Sep" || "$MONTH" == "Dec" ]] && [ "$(date -d +1day +%d)" -eq 1 ]; then
  if s3cmd put -r --no-mime-magic $backup_dir/ s3://"${S3_BUCKET_MONGODB}"/quarterly_backup/; then
    echo "Quarterly backup succeeded." >> $report_file
  else
    echo "Quarterly backup failed." >> $report_file
  fi
fi

# Prune old backups from S3
# Daily Backup Prune (31 days)
s3cmd ls -r s3://"${S3_BUCKET_MONGODB}"/daily_backup/ | \
  awk -v DEL="$(date +%F -d "31 days ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done

# Monthly Backup Prune (1 year)
s3cmd ls -r s3://"${S3_BUCKET_MONGODB}"/monthly_backup/ | \
  awk -v DEL="$(date +%F -d "3 months ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done

# Quarterly Backup Prune (3 years)
s3cmd ls -r s3://"${S3_BUCKET_MONGODB}"/quarterly_backup/ | \
  awk -v DEL="$(date +%F -d "3 years ago")" '$1 < DEL {print $4}' | while read -r file; do s3cmd rm "$file"; done

# Send report via email
< $report_file mail -s "${SOURCE_NAME}: MongoDB Backup Report" "${CRON_BACKUP_MAIL}"

# Clean up local backup data
find $backup_dir $mongodb_data_dir $mongodb_backup_dir -type f -exec rm {} \;
rm $report_file

