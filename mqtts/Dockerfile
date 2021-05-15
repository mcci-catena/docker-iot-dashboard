#
# Dockerfile for building MQTTS
#

# Build the MQTTS using phusion base image
FROM phusion/baseimage:master-amd64

# Installing mosquitto packages and certbot
RUN apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
RUN apt-get update && apt-get install -y \
	certbot \ 
	mosquitto \ 
	mosquitto-clients

# Copying mosquitto configuration
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf

# Start the MQTTS daemon during container startup
RUN mkdir /etc/service/mosquitto
COPY mosquitto.sh /etc/service/mosquitto/run
RUN chmod +x /etc/service/mosquitto/run

