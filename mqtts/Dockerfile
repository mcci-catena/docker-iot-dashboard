#
# Dockerfile for building MQTTS
#

# Build the MQTTS using phusion base image

# passing arguments to map letsencrypt certs

FROM phusion/baseimage

# Installing mosquitto packages and certbot
RUN add-apt-repository ppa:certbot/certbot
RUN apt-get update && apt-get install -y \
	certbot \ 
	mosquitto \ 
	mosquitto-clients

# passing arguments to map letsencrypt certs
ARG ssl_cert

# Linking letsencrypt certiifcates to mosquitto conf
RUN ln -sf /etc/letsencrypt/live/${ssl_cert}/cert.pem /etc/mosquitto/cert.pem
RUN ln -sf /etc/letsencrypt/live/${ssl_cert}/chain.pem /etc/mosquitto/chain.pem
RUN ln -sf /etc/letsencrypt/live/${ssl_cert}/privkey.pem /etc/mosquitto/privkey.pem


# Copying mosquitto configuration
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf

# Start the MQTTS daemon during container startup
RUN mkdir /etc/service/mosquitto
COPY mosquitto.sh /etc/service/mosquitto/run
RUN chmod +x /etc/service/mosquitto/run

