# 
# Dockerfile for building the apache image
#

# Start from Phusion.
FROM phusion/baseimage

RUN /usr/bin/apt-get update && /usr/bin/apt-get install software-properties-common -y
RUN /usr/bin/add-apt-repository ppa:certbot/certbot && /usr/bin/apt-get update && /usr/bin/apt-get install apache2 -y
#
#  Add the certbot layer
#
RUN /usr/bin/apt-get install python-certbot-apache -y
#
# enable proxys and generally set up.
#
RUN /usr/sbin/a2enmod proxy && \
    /usr/sbin/a2enmod proxy_http && \
    echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
    /usr/sbin/a2enconf fqdn.conf && \
    /usr/sbin/a2enmod authz_user authz_groupfile proxy_wstunnel headers

# RUN mkdir -p /root
COPY setup.sh proxy-*.conf /root/

# Running scripts during container startup for letsencrypt update and Apache
RUN mkdir -p /etc/my_init.d
COPY setup.sh /etc/my_init.d/setup.sh
RUN chmod +x /etc/my_init.d/setup.sh

# Enable letsencrypt renewal crontab
COPY certbot_cron.sh /etc/my_init.d/certbot_cron.sh
RUN chmod +x /etc/my_init.d/certbot_cron.sh

# Start the Apache2 daemon during container startup
RUN mkdir /etc/service/apache2
COPY apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

# end of file
