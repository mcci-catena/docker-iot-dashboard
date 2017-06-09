1. Convert to [phusion](https://github.com/phusion/baseimage-docker); documents are [here](http://phusion.github.io/baseimage-docker/)

2. Prepare a script that queries the user during the setup and sets the grafana admin user name and initial password (seeding grafana/.env, or overriding it). Also set name of influxdb database (change from demo).  And change all the FQDNs.And change the email address in certbot-config.sh.

3. don't forget to exclude grafana/.env from the git repo, so there are no passwords at all.

4. The grafana instance had better be customized to remove the admin password (or have a reset step) so if the user changes GRAFANA\_ENV\_ADMIN\_PASSWORD after the image has been launched once, it wil be reset. This might be a maintenance script and/or a makefile so that the system detects edits and does the right thing.

4. the script should also get names and roles for access to node-red and influxdb. It then will seed .hgaccess and .htgroup.

5. same script should be able to show user-by-user roles, and adjust them.

6. Add the auto-update cron script.

7. See if there's a way to make the docker-compose print a message and stop if the configuration operation hasn't been done.

8. integrate the other things from SETUP.txt

9. Add scripts to backup and restore the user's data directories. Backup should run offline (unless there's a very good way to backup the datasets from all the servers while they're up). restore must run offline. Scripts should do the necessary to ensure that the servers are in fact stopped.

10. update the README.md (again)
