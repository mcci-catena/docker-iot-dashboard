# To-do list

1. Prepare a script that queries the user during the setup and sets the `.env` file.

2. The script should also get names and roles for access to node-red and influxdb. It then will seed `.htaccess` and `.htgroup`.

3. Same script should be able to show user-by-user roles, and adjust them. (Right now the matrix is transposed; for each role you can look at `.htgroup` and find the members, but you can't easily see all the roles for a member.)

4. Figure out what to do if the user changes GRAFANA\_ENV\_ADMIN\_PASSWORD after the image has been launched once; at present, this is ignored. This might be a maintenance script and/or a makefile so that the system detects edits and does the right thing.

5. Add the auto-update cron script so that VMs get patched. If things are running unattended, they'd better really run unattended.

6. integrate the other things from SETUP.md

7. Add scripts to backup and restore the user's data directories. Backup should run offline (unless there's a very good way to backup the datasets from all the servers while they're up). restore must run offline. Scripts should do the necessary to ensure that the servers are in fact stopped.  This is now partially done with the AWS changes, but more work needs to be done.
