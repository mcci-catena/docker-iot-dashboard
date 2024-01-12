#!/bin/bash
while true
do
    HOUR="$(date +'%H')"
    MINUTE="$(date +'%M')"

    if [ "$HOUR" = "06" ] && [ "$MINUTE" = "35" ]
    then
                 /bin/backup.sh
    sleep 60
    fi
    done