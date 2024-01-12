#
# Dockerfile for building the influxdb instance with S3-backup and Mail alert setup
#

FROM phusion/baseimage:jammy-1.0.1

# Default InfluxDB host
ENV INFLUX_HOST=influxdb

# Install Influxdb stable release
RUN apt-get update && apt-get install -y  wget
ARG distrib_id
ARG distrib_codename

RUN echo "${distrib_id}"
RUN wget -qO- https://repos.influxdata.com/influxdata-archive_compat.key | apt-key add -
RUN /bin/bash -c "source /etc/lsb-release"
RUN echo "deb https://repos.influxdata.com/${distrib_id} ${distrib_codename} stable" | tee /etc/apt/sources.list.d/influxdb.list

#some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils

# Change workdir
RUN mkdir -p /opt/influxdb-backup
WORKDIR "/opt/influxdb-backup"

# To backup influxdb to S3 Bucket, some packages need to be installed as follows:
RUN apt-get update && apt-get install -y python3-pip influxdb
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
RUN echo "root@${hostname} influxdbbackup@${domain}" > /etc/postfix/generic
RUN postconf -e smtp_generic_maps=hash:/etc/postfix/generic
RUN postmap /etc/postfix/generic

# Backup script for influxdb
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/backup.sh
COPY influxdb.conf /etc/influxdb/influxdb.conf

# Enable influxdb database automatic backup crontab
RUN mkdir -p /etc/my_init.d

# Start the postfix daemon during container startup
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh

# Starting influxd daemon service
RUN mkdir /etc/service/influx
COPY influx.sh /etc/service/influx/run
RUN chmod +x /etc/service/influx/run

# Backup script for influxdb
COPY influxstart.sh /etc/service/influxstart/run
RUN chmod +x /etc/service/influxstart/run

# end of file
