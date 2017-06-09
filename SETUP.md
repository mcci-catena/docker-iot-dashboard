1. in `./apache/certbot-config.sh`, change the FQDN to the FQDN of this server.

2. in `./apache/certbot-config.sh`, add CERTBOT\_EMAIL with the right email address for use with certbot certificate requests.

3. Be aware that the grafana env admin\_password doesn't take unless it's correct **on the
first boot**.

4. get a fully-qualified domain name for your server, for which you control DNS. Call this the "FQDN" (fully-qualified domain name).

5. in `./apache/proxy-*.sh`, change all the FQDNs to the FQDN of this server.

6. using `docker-compose apache run /bin/bash`, 

   1. add {APACHE}/etc/apache2/authdata as user www-data
   ```sh
	mkdir /etc/apache2/authdata
	chown www-data /etc/apache2/authdata
   ```
   2. add {APACHE}/etc/apache2/authdata/.htpasswd as user www-data
   ```sh
	touch /etc/apache2/authdata/.htpasswd
	chown www-data /etc/apache2/.htpasswd
   ```
   3. Add user logins for influxdb, queries, node-red. Make `USERS` be a list of login IDs.
   ```sh
	for each USER in $USERS ; do 
		htpasswd /etc/apache2/authdata/.htpasswd $USER
   >>>>enter password twice
	done
   ```
   4. add {APACHE}/etc/apache2/authdata/.htgroup (owned by www-data)
   ```sh
	touch /etc/apache2/authdata/.htgroup
	chown www-data /etc/apache2/authdata/.htgroup
	echo "node-red: ${USERS}" >>/etc/apache2/authdata/.htgroup
	echo "admin: ${USERS}" >>/etc/apache2/authdata/.htgroup
	echo "group: ${USERS}" >>/etc/apache2/authdata/.htgroup
   ```

7. verify that grafana is working at https://{FQDN}/ and https://{FQDN}/grafana

8. verify that you can log in as https://{FQDN}/node-red/ and
https://{FQDN}/influxdb/

9. In influxdb UI, change the query URL to https://{FQDN}/influxdb, [x] SSL,
don't fill in user name here, just press save. Browser will ask for credentials; provide credentials.


