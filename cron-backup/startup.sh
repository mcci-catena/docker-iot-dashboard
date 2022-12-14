#!/bin/bash
while true
do
    HOUR="$(date +'%H')"
    MINUTE="$(date +'%M')"

    if [ "$HOUR" = "06" ] && [ "$MINUTE" = "35" ]
    then
                 /bin/nodered_backup.sh
    sleep 60
    fi
    if [ "$HOUR" = "07" ] && [ "$MINUTE" = "35" ]
    then
              /bin/grafana_backup.sh
     sleep 60
    fi
    if [ "$HOUR" = "08" ] && [ "$MINUTE" = "35" ]
    then
                /bin/nginx_backup.sh
    sleep 60
    fi
    if [ "$HOUR" = "09" ] && [ "$MINUTE" = "35" ]
    then
                /bin/mqtts_backup.sh
    sleep 60
    fi
done