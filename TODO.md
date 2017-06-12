1. Convert to [phusion](https://github.com/phusion/baseimage-docker); documents are [here](http://phusion.github.io/baseimage-docker/)

2. Prepare a script that queries the user during the setup and sets the `.env` file.

4. Figure out what to do if the user changes GRAFANA\_ENV\_ADMIN\_PASSWORD after the image has been launched once, it wil be reset. This might be a maintenance script and/or a makefile so that the system detects edits and does the right thing.

4. the script should also get names and roles for access to node-red and influxdb. It then will seed .hgaccess and .htgroup.

5. same script should be able to show user-by-user roles, and adjust them.

6. Add the auto-update cron script.

7. integrate the other things from SETUP.txt

8. Add scripts to backup and restore the user's data directories. Backup should run offline (unless there's a very good way to backup the datasets from all the servers while they're up). restore must run offline. Scripts should do the necessary to ensure that the servers are in fact stopped.

10. update the README.md (again)
