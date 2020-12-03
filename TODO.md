# To-do list

1. Prepare a script that queries the user during the setup and sets the `.env` file.

2. The script should also get names and roles for access to Node-red and InfluxDB. It then will seed `.htpasswd` files.

3. Same script should be able to show user-by-user roles, and adjust them.

4. Figure out what to do if the user changes `GRAFANA_ENV_ADMIN_PASSWORD` after the image has been launched once; at present, this is ignored. This might be a maintenance script and/or a makefile so that the system detects edits and does the right thing.

5. Add the auto-update cron script so that VMs get patched. If things are running unattended, they'd better really run unattended.

6. Integrate the other things from `SETUP.md`.

7. Add documention on setting up backups.
