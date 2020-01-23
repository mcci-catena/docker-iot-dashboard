#
# Dockerfile for building the influxdb instance with S3-backup and Mail alert setup
#

FROM phusion/baseimage

# Default InfluxDB host
ENV INFLUX_HOST=influxdb

# Install Influxdb stable release
RUN apt-get update && apt-get install -y  wget
ARG distrib_id
ARG distrib_codename

RUN echo "${distrib_id}"
RUN wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
RUN /bin/bash -c "source /etc/lsb-release"
RUN echo "deb https://repos.influxdata.com/${distrib_id} ${distrib_codename} stable" | tee /etc/apt/sources.list.d/influxdb.list

#some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils

# passing arguments to build postfix image
ARG hostname
ARG relay_ip
ARG domain

# Install Postfix
run echo "postfix postfix/mailname string $host_name" | debconf-set-selections
run echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
run apt-get update && apt-get install -y postfix
run postconf -e relayhost=$relay_ip
run postconf -e myhostname=$hostname
run postconf -e mydomain=$domain
run postconf -e masquerade_domains=$domain
run postconf -e mydestination="\$myhostname, $hostname, localhost, localhost.localdomain, localhost"
run postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.0.0.0/8"
run postconf -e smtpd_use_tls=no
run echo $domain > /etc/mailname

# This will replace local mail addresses by valid Internet addresses when mail leaves the machine via SMTP.
run echo "root@${domain} influxdbbackup@${domain}" > /etc/postfix/generic
run postconf -e smtp_generic_maps=hash:/etc/postfix/generic
run postmap /etc/postfix/generic

# mail command would be used for sending mails
run apt-get install -y mailutils

# Change workdir
RUN mkdir -p /opt/influxdb-backup
WORKDIR "/opt/influxdb-backup"

# To backup influxdb to S3 Bucket, some packages need to be installed as follows:
RUN apt-get update && apt-get install -y python-pip influxdb
RUN pip install awscli --upgrade  

# Backup script for influxdb
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/backup.sh
COPY influxdb.conf /etc/influxdb/influxdb.conf

# Enable influxdb database automatic backup crontab
RUN mkdir -p /etc/my_init.d
COPY influxdb_cron.sh /etc/my_init.d/influxdb_cron.sh
RUN chmod +x /etc/my_init.d/influxdb_cron.sh

# Start the postfix daemon during container startup
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh

# Starting influxd daemon service 
RUN mkdir /etc/service/influx
COPY influx.sh /etc/service/influx/run
RUN chmod +x /etc/service/influx/run

# end of file
