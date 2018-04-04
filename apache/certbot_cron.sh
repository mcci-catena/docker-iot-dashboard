#!/bin/sh

cd /root
#write out current crontab
crontab -l > mycron

#echo new cron into cron file
echo "15 3 * * * /usr/bin/certbot renew" >> mycron

#install new cron file
crontab mycron
