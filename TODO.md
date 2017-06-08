1. Convert to (phusion)[https://github.com/phusion/baseimage-docker]; documents are (here)[http://phusion.github.io/baseimage-docker/]

1. Prepare a script that queries the user during the setup and sets the grafana admin user name and initial password (seeding grafana/.env, or overriding it).

2. don't forget to exclude grafana/.env from the git repo, so there are no passwords at all. 

2. the script should also get names and roles for access to node-red and influxdb. It then will seed .hgaccess and .htgroup.

3. same script should be able to show user-by-user roles, and adjust them.

4. Add the auto-update cron script.

5. See if there's a way to make the docker-compose print a message and stop if the configuration operation hasn't been done.

6. Add scripts to backup and restore the user's data directories. Backup should run offline (unless there's a very good way to backup the datasets from all the servers while they're up). restore must run offline. Scripts should do the necessary to ensure that the servers are in fact stopped.

7. update the README.md (again)
