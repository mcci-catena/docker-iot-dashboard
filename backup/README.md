# [cron-backup](./cron-backup) Docker Container Usage

This instance provides backup support for the `Nginx`, `Node-red` and `Grafana` containers and pushed the backed up data to S3-compatible storage.

## Shell script

For backing up the directory data

- It uses [`grafana_backup.sh`](backup\grafana_backup.sh) for `Grafana` container.
- It uses [`nodered_backup.sh`](backup\nodered_backup.sh) for `Node-red` container.
- It uses [`nginx_backup.sh`](backup\nginx_backup.sh) for `Nginx` container.
- It uses [`mqtts_backup.sh`](backup\mqtts_backup.sh) for `Mqtts` container.

## Scheduling backup using `Daemon thread`

The following backup jobs are added to run at specific time.

``` bash

# Start up the Process
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
```

## Mail Alert

The above backup shell scripts were configured to send mail for the both successful/unsuccessful run.
