#!/bin/bash

# set up the environment; these might not be set.
export HOME="/root"
export PATH="${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# start cron as a daemon
cron || exit 1

# test that we have a proper setup.
cd $HOME || exit 2

# test that authentication is set up, and set permissions as needed by us
if [ ! -d /etc/apache2/authdata ] ; then
	echo "The authdata directory is not set; refer to docker-compose script"
	exit 3
fi
if [ ! -f /etc/apache2/authdata/.htpasswd ]; then
	echo ".htpasswd file not found"
	exit 3
fi
if [ ! -f /etc/apache2/authdata/.htgroup ]; then
	echo ".htgroup file not found"
	exit 3
fi
chown www-data /etc/apache2/authdata /etc/apache2/authdata/.htpasswd /etc/apache2/authdata/.htgroup
chmod 700 /etc/apache2/authdata
chmod 600 /etc/apache2/authdata/.htpasswd /etc/apache2/authdata/.htgroup

# check that we got the vars we need
if [ -z "$CERTBOT_DOMAINS" -o "$CERTBOT_DOMAINS" = "." ]; then
	echo "The docker-compose script must set CERTBOT_DOMAINS to value to be passed to certbot for --domains" 
	exit 3
fi

if [ -z "$CERTBOT_EMAIL" -o "$CERTBOT_EMAIL" = "." ]; then
	echo "The docker-compose script must set CERTBOT_EMAIL to an email address useful to certbot/letsencrypt for notifications"
	exit 3
fi

if [ -z "$APACHE_FQDN" -o "$APACHE_FQDN" = "." ]; then
	echo "The docker-compose script must set APACHE_FQDN to the (single) fully-qualified domain at the top level"
	exit 3
fi

# run cerbot to set up apache
if [ "$CERTBOT_TEST" != "test" ]; then
    certbot --agree-tos --email "${CERTBOT_EMAIL}" --non-interactive --domains "$CERTBOT_DOMAINS" --apache --agree-tos --rsa-key-size 4096 --redirect || exit 4

    # certbot actually launched apache. The simple hack is to stop it; then launch 
    # it again after we've edited the config files.
    /usr/sbin/apache2ctl stop
fi

# now, add the fields to the virtual host section for https.
set -- proxy-*.conf
if [ "$1" != "proxy-*.conf" ] ; then
	echo "add proxy-specs to configuration from:" "$@"
	sed -e "s/@{FQDN}/${APACHE_FQDN}/g" "$@" > /tmp/proxyspecs.conf || exit 5
	sed -e '/^ServerName/r/tmp/proxyspecs.conf' /etc/apache2/sites-available/000-default-le-ssl.conf > /tmp/000-default-le-ssl-local.conf || exit 6
	mv /tmp/000-default-le-ssl-local.conf /etc/apache2/sites-available || exit 7
	echo "enable the modified site, and disable the ssl defaults"
	/usr/sbin/a2dissite 000-default-le-ssl.conf || exit 8
	/usr/sbin/a2ensite 000-default-le-ssl-local.conf || exit 9
fi

# launch apache
if [ "$APACHE_TEST" != "test" ]; then
    echo "launch apache"
    exec /usr/sbin/apache2ctl -DFOREGROUND
fi
