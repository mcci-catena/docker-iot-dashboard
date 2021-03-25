#
# Dockerfile for building the cron-backup instance with S3-backup and Mail alert setup for the below service
# 1. mongodb
#
FROM phusion/baseimage:bionic-1.0.0

#some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils \
    rsync

# passing arguments to build postfix image
ARG hostname
ARG relay_ip
ARG domain

# Install Postfix
run echo "postfix postfix/mailname string $host_name" | debconf-set-selections
run echo "postfix postfix/main_mailer_type select Satellite system" | debconf-set-selections
run apt-get update && apt-get install -y postfix mailutils
run postconf -e relayhost=$relay_ip

# This will replace local mail addresses by valid Internet addresses when mail leaves the machine via SMTP.
run echo "root@${hostname} backup@${domain}" > /etc/postfix/generic
run postconf -e smtp_generic_maps=hash:/etc/postfix/generic
run postmap /etc/postfix/generic

# Change workdir
RUN mkdir -p /opt/backup
WORKDIR "/opt/backup"

# To backup Mongodb to S3 Bucket, some packages need to be installed as follows:
RUN apt-get update && apt-get install -y python-pip
RUN pip install s3cmd
ARG AWS_ACCESS_KEY_ID
ARG AWS_DEFAULT_REGION
ARG AWS_HOST_BASE
ARG AWS_HOST_BUCKET
ARG AWS_SECRET_ACCESS_KEY
RUN set -x \
        && echo "[default]\naccess_key = ${AWS_ACCESS_KEY_ID}\nbucket_location = $AWS_DEFAULT_REGION\nhost_base = $AWS_HOST_BASE\nhost_bucket = $AWS_HOST_BUCKET\nsecret_key = $AWS_SECRET_ACCESS_KEY" | tee /root/.s3cfg

# Backup script for node-red data directory backup
COPY nodered_backup.sh /bin/nodered_backup.sh
RUN chmod +x /bin/nodered_backup.sh

# Backup script for Grafana data directory backup
COPY grafana_backup.sh /bin/grafana_backup.sh
RUN chmod +x /bin/grafana_backup.sh

# Backup script for Nginx data directory backup
COPY nginx_backup.sh /bin/nginx_backup.sh
RUN chmod +x /bin/nginx_backup.sh

# Start the postfix daemon during container startup
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh

# To Enable crontab
RUN mkdir -p /etc/my_init.d
COPY cron.sh /etc/my_init.d/cron.sh
RUN chmod +x /etc/my_init.d/cron.sh
# end of file
