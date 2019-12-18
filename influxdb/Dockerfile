#
# Dockerfile for building the influxdb instance with backup setup
#

# passing arguments to install influxdb specific version
ARG version

FROM influxdb:${version}

# Default InfluxDB host
ENV INFLUX_HOST=influxdb

# Change workdir
RUN mkdir -p /opt/influxdb-backup
WORKDIR "/opt/influxdb-backup"

# To backup influxdb to S3 Bucket, some packages need to be installed as follows:
RUN apt-get update && apt-get install -y python-pip 
RUN pip install awscli --upgrade  

# Backup script
COPY showdb.sh /bin/showdb.sh
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/showdb.sh
RUN chmod +x /bin/backup.sh

# end of file
