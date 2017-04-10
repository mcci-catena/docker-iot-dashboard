#!/bin/bash

# set up the environment; these might not be set.
export HOME="/root"
export PATH="${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# start cron as a daemon
cron || exit 1

# test that we have a proper setup.
cd $HOME || exit 2
if [ -f certbot-config.sh ]; then
	source certbot-config.sh
fi

if [ -z "$CERTBOT_DOMAINS" ]; then
	echo "You must set CERTBOT_DOMAINS to value to be passed to certbot for --domains" 
	exit 3
fi

# run cerbot to set up apache
certbot --non-interactive --domains "$CERTBOT_DOMAINS" --apache --agree-tos --rsa-key-size 4096 --redirect || exit 4

# certbot actually launched apache. The simple hack is to stop it; then launch 
# it again after we've edited the config files.
/usr/sbin/apache2ctl stop

# now, add the fields to the virtual host section for https.
set -- proxy-*.conf
if [ "$1" != "proxy-*.conf" ] ; then
	echo "add proxy-specs to configuration from:" "$@"
	cat "$@" > /tmp/proxyspecs.conf || exit 5
	sed -e '/^ServerName/r/tmp/proxyspecs.conf' /etc/apache2/sites-available/000-default-le-ssl.conf > /tmp/000-default-le-ssl-local.conf || exit 6
	mv /tmp/000-default-le-ssl-local.conf /etc/apache2/sites-available || exit 7
	echo "enable the modified site, and disable the ssl defaults"
	/usr/sbin/a2dissite 000-default-le-ssl.conf || exit 8
	/usr/sbin/a2ensite 000-default-le-ssl-local.conf || exit 9
fi

# launch apache
echo "launch apache"
exec /usr/sbin/apache2ctl -DFOREGROUND
