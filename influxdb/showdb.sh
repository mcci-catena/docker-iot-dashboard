#! /bin/bash
# TO Show all Databases that will be used by backup.sh script for backup

showdb(){
influx  -host "$INFLUX_HOST" -port 8086 -execute 'SHOW DATABASES'
}

DATABASES=$(showdb)

echo "$DATABASES" | sed -e 's/[\r]//g' | sed -e 's/^.\{26\}//' | sed 's/ /:/g'
