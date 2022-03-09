#
# Dockerfile for building the cron-backup instance with S3-backup and Mail alert setup for the below service
# 1. Node-red
# 2. Grafana
# 3. Nginx
# 4. Mqtts
# 5. mongodb

# To find the version of installed Mongodb service
FROM mongo:latest AS mongodb
RUN env | grep MON > /root/env


# Building cron-backup instance
FROM phusion/baseimage:master-amd64
# Copying mongodb's version
COPY --from=mongodb /root/env /root/env

# Installing same Mongodb's tools as in the copied version here in the cron-backup instance
RUN set -x \
        && export $(xargs < /root/env) \
        && echo "deb http://$MONGO_REPO/apt/ubuntu focal/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR multiverse" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list" \
        && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B00A0BD1E2C63C11 \
        && export DEBIAN_FRONTEND=noninteractive && apt-get update && ln -s /bin/true /usr/local/bin/systemctl && apt-get install -y \
                ${MONGO_PACKAGE}=$MONGO_VERSION \
                ${MONGO_PACKAGE}-tools=$MONGO_VERSION


# some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils \
    rsync

# Change workdir
RUN mkdir -p /opt/backup
WORKDIR "/opt/backup"

# To backup Mongodb to S3 Bucket, some packages need to be installed as follows:
RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install s3cmd
ARG AWS_ACCESS_KEY_ID
ARG AWS_DEFAULT_REGION
ARG AWS_HOST_BASE
ARG AWS_HOST_BUCKET
ARG AWS_SECRET_ACCESS_KEY
RUN set -x \
        && echo "[default]\naccess_key = ${AWS_ACCESS_KEY_ID}\nbucket_location = $AWS_DEFAULT_REGION\nhost_base = $AWS_HOST_BASE\nhost_bucket = $AWS_HOST_BUCKET\nsecret_key = $AWS_SECRET_ACCESS_KEY" | tee /root/.s3cfg

# passing arguments to build postfix image
ARG hostname
ARG relay_ip
ARG domain

# Install Postfix
RUN echo "postfix postfix/mailname string $host_name" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type select Satellite system" | debconf-set-selections
RUN apt-get update && apt-get install -y postfix mailutils
RUN postconf -e relayhost=$relay_ip

# This will replace local mail addresses by valid Internet addresses when mail leaves the machine via SMTP.
RUN echo "root@${hostname} backup@${domain}" > /etc/postfix/generic
RUN postconf -e smtp_generic_maps=hash:/etc/postfix/generic
RUN postmap /etc/postfix/generic

# Backup script for node-red data directory backup
COPY nodered_backup.sh /bin/nodered_backup.sh
RUN chmod +x /bin/nodered_backup.sh

# Backup script for Grafana data directory backup
COPY grafana_backup.sh /bin/grafana_backup.sh
RUN chmod +x /bin/grafana_backup.sh

# Backup script for Nginx data directory backup
COPY nginx_backup.sh /bin/nginx_backup.sh
RUN chmod +x /bin/nginx_backup.sh

# Backup script for Mqtts data directory backup
COPY mqtts_backup.sh /bin/mqtts_backup.sh
RUN chmod +x /bin/mqtts_backup.sh

# Backup script for mongodb
COPY mongodb_backup.sh /bin/mongodb_backup.sh
RUN chmod +x /bin/mongodb_backup.sh

# Start the postfix daemon during container startup
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh

# To Enable crontab
RUN mkdir -p /etc/my_init.d
COPY cron.sh /etc/my_init.d/cron.sh
RUN chmod +x /etc/my_init.d/cron.sh
# end of file
