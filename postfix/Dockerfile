#
# Dockerfile for building POSTFIX
#
# Build the Postfix  using phusion base image
FROM phusion/baseimage:bionic-1.0.0

# some basic package installation for troubleshooting
RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    debconf-utils

# passing arguments to build postfix image
ARG hostname
ARG relay_ip
ARG domain
ARG smtp_login
ARG smtp_password

# Install Postfix
run echo "postfix postfix/mailname string $hostname" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
    echo "postfix postfix/relayhost string $relay_ip" | debconf-set-selections

run apt-get update && apt-get install -y postfix libsasl2-modules
run postconf -e myhostname=$hostname
run postconf -e mydomain=$domain
run postconf -e myorigin=\$mydomain
run postconf -e masquerade_domains=\$mydomain
run postconf -e mydestination="\$myhostname, $hostname, localhost, localhost.localdomain, localhost"
run postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16" 
run echo $domain > /etc/mailname

# set up the credentials for SMTP authentication using username and password
run echo "$relay_ip $smtp_login:$smtp_password" >/etc/postfix/sasl_passwd && chmod 600 /etc/postfix/sasl_passwd && postmap /etc/postfix/sasl_passwd && \
    printf '%s\n' '# set up login for SMTP' \
        'smtp_sasl_auth_enable=yes' \
        'smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd' \
        'smtp_sasl_security_options=noanonymous' \
        'smtp_sasl_tls_security_options=noanonymous' \
        'smtp_sasl_mechanism_filter=AUTH LOGIN' >> /etc/postfix/main.cf

# This will replace local mail addresses by valid Internet addresses when mail leaves the machine via SMTP. 
run echo "root@${domain} iotmail@${domain}" > /etc/postfix/generic
run postconf -e smtp_generic_maps=hash:/etc/postfix/generic
run postmap /etc/postfix/generic

# mail command would be used for sending mails
run apt-get install -y mailutils 

# Start the postfix daemon during container startup
RUN mkdir -p /etc/my_init.d
COPY postfix.sh /etc/my_init.d/postfix.sh
RUN chmod +x /etc/my_init.d/postfix.sh
