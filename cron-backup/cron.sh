#!/bin/sh

# exit on unchecked errors
set -e

# backups are scheduled via the root crontab. Start by heading there
cd /root

#write out current crontab
crontab -l > mycron || echo "no crontab for root, going on"

#echo new cron into cron file
echo "35 6 * * * /bin/bash -l -c '/bin/nodered_backup.sh'" >> mycron
echo "35 7 * * * /bin/bash -l -c '/bin/grafana_backup.sh'" >> mycron
echo "35 8 * * * /bin/bash -l -c '/bin/nginx_backup.sh'" >> mycron

#delete duplicated lines
sort -u -o mycron mycron

#install new cron file
crontab mycron
