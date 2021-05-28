#!/bin/sh

# exit on unchecked errors
set -e

# backups are scheduled via the root crontab. Start by heading there
cd /root

#write out current crontab
crontab -l > mycron || echo "no crontab for root, going on"

#echo new cron into cron file
echo "15 3 * * * /usr/bin/certbot renew --preferred-challenges http-01,dns-01" >> mycron

#delete duplicated lines
sort -u -o mycron mycron

#install new cron file
crontab mycron
