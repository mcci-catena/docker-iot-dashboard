# [cron-backup](./cron-backup) Docker Container Usage

This instance provides backup support for the `Nginx`, `Node-red` and `Grafana` containers and pushed the backed up data to S3-compatible storage.

## Shell script

For backing up the directory data

- It uses [`grafana_backup.sh`](cron-backup\grafana_backup.sh) for `Grafana` container.
- It uses [`nodered_backup.sh`](cron-backup\nodered_backup.sh) for `Node-red` container.
- It uses [`nginx_backup.sh`](cron-backup\nginx_backup.sh) for `Nginx` container.

## Scheduling backup using `crontab`

The following backup jobs are added to run at specific time.

``` bash

# echo new cron into cron file
{ 
    echo "35 6 * * * /bin/bash -l -c '/bin/nodered_backup.sh'"
    echo "35 7 * * * /bin/bash -l -c '/bin/grafana_backup.sh'" 
    echo "35 8 * * * /bin/bash -l -c '/bin/nginx_backup.sh'"
} >> mycron

```

## Mail Alert

The above backup shell script is configured to send mail for the both successful/unsuccessful run.