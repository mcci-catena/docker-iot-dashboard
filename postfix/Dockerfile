#
# Dockerfile for building POSTFIX
#
# Build the Postfix  using phusion base image
FROM phusion/baseimage

# some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils \
    mailutils

# passing arguments to build postfix image
ARG relay_ip
ARG host_name
ARG domain

# Install Postfix
RUN echo "postfix postfix/mailname string $host_name" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y postfix
RUN postconf -e relayhost=$relay_ip
RUN postconf -e myhostname=$host_name
RUN postconf -e mydomain=$domain
RUN postconf -e smtp_generic_maps=hash:/etc/postfix/generic
RUN postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.18.0.0/16"
RUN postconf -e smtpd_use_tls=no
RUN echo $host_name > /etc/mailname

# This will replace local mail addresses by valid Internet addresses when mail leaves the machine via SMTP. so please change it according to container.
RUN echo "root@aa7fde2ee7f1 iotmail@example.com" > /etc/postfix/generic
RUN postmap /etc/postfix/generic

# Start the postfix daemon during container startup
RUN mkdir -p /etc/my_init.d
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh
