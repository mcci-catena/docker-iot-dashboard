# 
# Dockerfile for building the Nginx image
#

# Start from Phusion.
FROM phusion/baseimage:master-amd64

# Installing the required packages
RUN apt-get update && apt-get install -y \
	software-properties-common \
	certbot \
	python3-certbot-nginx \
	nginx \
	apache2-utils

# Copying Proxy files 
COPY setup.sh proxy-*.conf /root/

# Running scripts during container startup for letsencrypt update and configuring proxy files behind Nginx
RUN mkdir -p /etc/my_init.d
COPY setup.sh /etc/my_init.d/setup.sh
RUN chmod +x /etc/my_init.d/setup.sh

# Enable letsencrypt renewal crontab
COPY certbot_cron.sh /etc/my_init.d/certbot_cron.sh
RUN chmod +x /etc/my_init.d/certbot_cron.sh

# Start the Nginx daemon during container startup
RUN mkdir /etc/service/nginx
COPY nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# end of file
