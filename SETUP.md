1. Make sure that you have the following tools installed on the host server.

   Tool|On Ubuntu|On CentOS 7
   ----|---------|-----------
   `htpasswd`|`sudo apt-get install apache2-utils`|`sudo yum install httpd-tools`

2. Get a fully-qualified domain name (FQDN) for your server, for which you control DNS.

3. Create a `.env` file as instructed in README.md.

7. Using `docker-compose run apache /bin/bash`:
   * If this fails with the message, `ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?`, then probably your user ID is not in the `docker` group. To fix this, `sudo adduser MYUSER docker`, where "MYUSER" is your login ID. Then (**very important**) log out and log back in.

   1. Add Apache's `/etc/apache2/authdata` as user www-data
   ```sh
	chown www-data /etc/apache2/authdata
   ```
   2. Add Apache's `/etc/apache2/authdata/.htpasswd`.
   ```sh
	touch /etc/apache2/authdata/.htpasswd
	chown www-data /etc/apache2/authdata/.htpasswd
   ```
   3. Add user logins for node-red and influxdb queries. Make `USERS` be a list of login IDs.
   ```sh
	export USERS="tmm amy josh"
	for USER in $USERS; do echo "Set password for "$USER; htpasswd /etc/apache2/authdata/.htpasswd $USER; done
   ```
   4. Add Apache's `/etc/apache2/authdata/.htgroup`.
   ```sh
	# this assumes USERS is still set from previous step.
	touch /etc/apache2/authdata/.htgroup
	chown www-data /etc/apache2/authdata/.htgroup
	echo "node-red: ${USERS}" >>/etc/apache2/authdata/.htgroup
	echo "query: ${USERS}" >>/etc/apache2/authdata/.htgroup
   ```
   5. Exit Apache's container with Ctrl-D.
