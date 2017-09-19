echo 'Backup Influx metadata'
influxd backup -host $INFLUX_HOST:8088 /tmp/backup

# Replace colons with spaces to create list.
for db in ${DATABASES//:/ }; do
  echo "Creating backup for $db"
  influxd backup -database $db -host $INFLUX_HOST:8088 /tmp/backup
done

DATE=`date +%Y-%m-%d-%H-%M-%S`
