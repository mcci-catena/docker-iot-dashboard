1) in ./apache/certbot-config.sh, change the FQDN to the FQDN of this server.
1a) in ./apache/certbot-config.sh, add CERTBOT_EMAIL with the right 
1b) the grafana env admin_password doesn't take unless it's correct *on the
first boot*.

2) in ./apache/proxy-*.sh, change all the FQDNs to the FQDN of this server.

3) using `docker-compose apache run /bin/bash`, 

3.1) add {APACHE}/etc/apache2/authdata as user www-data
	mkdir /etc/apache2/authdata
	chown www-data /etc/apache2/authdata

4) add {APACHE}/etc/apache2/authdata/.htpasswd as user www-data
	touch /etc/apache2/authdata/.htpasswd
	chown www-data /etc/apache2/.htpasswd

5) for each USER in $USERS ; do 
	htpasswd /etc/apache2/authdata/.htpasswd $USER
>>>>enter password twice

6) add {APACHE}/etc/apache2/authdata/.htgroup (owned by www-data)
	touch /etc/apache2/authdata/.htgroup
	chown www-data /etc/apache2/authdata/.htgroup
	echo "node-red: ${USERS} >>/etc/apache2/authdata/.htgroup
	echo "admin: ${USERS} >>/etc/apache2/authdata/.htgroup
	echo "group: ${USERS} >>/etc/apache2/authdata/.htgroup

7) verify that grafana is working at https://{FQDN}/ and https:{{F

8) verify that you can log in as https://ithaca-power.mcci.com/node-red/ and
https://ithaca-power.mcci.com/influxdb/

9) In influxdb UI, change the query URL to https://{FQDN}/influxdb, [x] SSL,
don't fill in user name here, just press save. Browser will ask for credentials; provide credentials;


