1. Make sure that you have the following tools installed on the host server.

   Tool|On Ubuntu|On CentOS 7
   ----|---------|-----------
   `htpasswd`|`sudo apt-get install apache2-utils`|`sudo yum install httpd-tools`

2. get a fully-qualified domain name for your server, for which you control DNS. Call this the "FQDN" (fully-qualified domain name).

3. Createa a `.env` file as instructed in README.md. 

4. Be aware that the grafana env admin\_password is ignored **except on the
first boot**.

5. Follow the instructions from README.md to get grafana working and to get the server up.

6. verify that grafana is working at https://{FQDN}/ and https://{FQDN}/grafana

7. using `docker-compose apache run /bin/bash`, 

   1. add Apache's /etc/apache2/authdata as user www-data
   ```sh
	mkdir /etc/apache2/authdata
	chown www-data /etc/apache2/authdata
   ```
   2. add Apache's /etc/apache2/authdata/.htpasswd as user www-data
   ```sh
	touch /etc/apache2/authdata/.htpasswd
	chown www-data /etc/apache2/authdata/.htpasswd
   ```
   3. Add user logins for influxdb, queries, node-red. Make `USERS` be a list of login IDs.
   ```sh
   	export USERS="tmm amy josh"
	for each USER in $USERS ; do 
		htpasswd /etc/apache2/authdata/.htpasswd $USER
   >>>>enter password twice
	done
   ```
   4. add Apache's /etc/apache2/authdata/.htgroup (owned by www-data)
   ```sh
   	# this assumes USERS is still set from previous step.
	touch /etc/apache2/authdata/.htgroup
	chown www-data /etc/apache2/authdata/.htgroup
	echo "node-red: ${USERS}" >>/etc/apache2/authdata/.htgroup
	echo "admin: ${USERS}" >>/etc/apache2/authdata/.htgroup
	echo "query: ${USERS}" >>/etc/apache2/authdata/.htgroup
   ```

8. verify that you can log in as https://{FQDN}/node-red/. 

9. Current versions of influxdb may support an administrative interface at https://{FQDN}/influxdb/. If so, in the influxdb UI, change the query URL to https://{FQDN}/influxdb, [x] SSL. Don't fill in user name here, just press save. Browser will ask for credentials; provide credentials.
