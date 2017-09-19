FROM influxdb:1.2.4

# Backup the following databases, separator ":"
#ENV DATABASES=demo:_internal:testdb

#default InfluxDB host
ENV INFLUX_HOST=influxdb

# Change workdir
RUN mkdir -p /opt/influxdb-backup
WORKDIR "/opt/influxdb-backup"

# Backup script
COPY showdb.sh /bin/showdb.sh
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/backup.sh

# Backup directory
RUN mkdir -p /var/lib/influxdb-backup
