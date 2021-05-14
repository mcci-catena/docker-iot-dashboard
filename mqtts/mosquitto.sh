#!/bin/bash
# Linking letsencrypt certificates to mosquitto conf
< /etc/letsencrypt/live/${ssl_cert}/cert.pem cat > /etc/mosquitto/cert.pem
< /etc/letsencrypt/live/${ssl_cert}/chain.pem cat > /etc/mosquitto/chain.pem
< /etc/letsencrypt/live/${ssl_cert}/privkey.pem cat > /etc/mosquitto/privkey.pem

# Changing ownership to mosquitto user
chown mosquitto /etc/mosquitto/*.pem

# Starting the mosquitto service
/usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf 
