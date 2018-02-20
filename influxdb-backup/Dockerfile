FROM phusion/baseimage

# Install influxdb database
RUN curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
RUN echo "deb https://repos.influxdata.com/ubuntu xenial stable" > /etc/apt/sources.list.d/influxdb.list

#To backup influxdb to S3 Bucket, some package need to be installed as follows:
RUN apt-get update && apt-get install -y \
    python-pip \
    influxdb
RUN pip install awscli --upgrade  

#default InfluxDB host
ENV INFLUX_HOST=influxdb

# Amazon S3 bucket's backup working Directory
RUN mkdir -p /var/lib/amazon-bucket

# Change workdir
RUN mkdir -p /opt/influxdb-backup
WORKDIR "/opt/influxdb-backup"

# Backup script
COPY showdb.sh /bin/showdb.sh
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/backup.sh

# Backup directory
RUN mkdir -p /var/lib/influxdb-backup
