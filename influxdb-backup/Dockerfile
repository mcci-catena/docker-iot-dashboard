FROM influxdb:1.2.4

# Backup the following databases, seperator ":"
ENV DATABASES=demo:_internal:testdb

#default InfluxDB host
ENV INFLUX_HOST=influxdb

# Change workdir
WORKDIR "/tmp"

# Backup script
COPY backup.sh /bin/backup.sh
RUN chmod +x /bin/backup.sh

# Backup directory
RUN mkdir -p /tmp/backup
