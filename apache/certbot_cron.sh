#!/bin/sh

cd /root
#write out current crontab
crontab -l > mycron

#echo new cron into cron file
echo "15 3 * * * /usr/bin/certbot renew --preferred-challenges http-01,dns-01" >> mycron

#install new cron file
crontab mycron
