#!/bin/sh

cd /root
#write out current crontab
crontab -l > mycron

#echo new cron into cron file
echo "35 6 * * * /bin/bash -l -c '/bin/backup.sh'" > mycron

#install new cron file
crontab mycron
