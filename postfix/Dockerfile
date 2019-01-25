#
# Dockerfile for building POSTFIX
#
# Build the Postfix  using phusion base image
FROM phusion/baseimage

# some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils

# passing arguments to build postfix image
ARG relay_ip
ARG host_name
ARG domain

# Install Postfix
run echo "postfix postfix/mailname string $host_name" | debconf-set-selections
run echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
run apt-get update && apt-get install -y postfix
run postconf -e relayhost=$relay_ip
run postconf -e myhostname=$host_name
run postconf -e mydomain=$domain
run postconf -e smtp_generic_maps=hash:/etc/postfix/generic
run postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.18.0.0/16"
run postconf -e smtpd_use_tls=no

# This will replace local mail addresses by valid Internet addresses when mail leaves the machine via SMTP. so please change it according to container.
run echo "root@aa7fde2ee7f1 iotmail@example.com" > /etc/postfix/generic
run postmap /etc/postfix/generic

# mail command would be used for sending mails
run apt-get install -y mailutils

# Start the postfix daemon during container startup
RUN mkdir -p /etc/my_init.d
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh
