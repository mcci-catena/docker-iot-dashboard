# 
# Dockerfile for building the apache image
#

# gack. start from ubuntu.
FROM ubuntu:latest

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
    /usr/sbin/a2enmod authz_user authz_groupfile proxy_wstunnel

# RUN mkdir -p /root
COPY setup.sh proxy-*.conf /root/

#
# we need to run cron (for letsencrypt update) and apache. Try doing it
# by launching with bash... supervisord is sort of heavy for our purposes.
# 
CMD [ "/bin/bash", "/root/setup.sh" ]
# end of file
