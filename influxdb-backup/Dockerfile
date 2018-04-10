#
# Dockerfile for building the extra-instance-for-influxdb-backup
#

# Build the extra-instance using phusion base image 
FROM phusion/baseimage

# Change workdir
RUN mkdir -p /opt/influxdb-backup
WORKDIR "/opt/influxdb-backup"

# passing arguments to install influxdb specific version
ARG version

# Install influxdb database
RUN apt-get update && apt-get install -y wget
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_${version}_amd64.deb
RUN dpkg -i influxdb_${version}_amd64.deb

# To backup influxdb to S3 Bucket, some packages need to be installed as follows:
RUN apt-get update && apt-get install -y python-pip 
RUN pip install awscli --upgrade  

# Default InfluxDB host
ENV INFLUX_HOST=influxdb

# Amazon S3 bucket's backup working Directory
RUN mkdir -p /var/lib/amazon-bucket

# Backup script
COPY showdb.sh /bin/showdb.sh
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/showdb.sh
RUN chmod +x /bin/backup.sh

# Backup directory
RUN mkdir -p /var/lib/influxdb-backup

# end of file
