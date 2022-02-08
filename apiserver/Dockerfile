#
# Dockerfile for building APISERVER
#

# Build the APISERVER using phusion base image

FROM phusion/baseimage:master-amd64

# Installing nodejs 
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update && apt-get install nodejs -y

# Copying public keys to get SSH access to this Container
COPY *.pub /tmp/
RUN cat /tmp/*.pub >> /root/.ssh/authorized_keys && rm -f /tmp/*.pub

# Enabling SSH service
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Coying the version-source 
ADD version.tar.gz /
COPY version_start /etc/service/version_start/run
RUN chmod +x /etc/service/version_start/run

# To start DNC-SERVER during system boot
COPY dncserver_start /etc/service/dncserver_start/run
RUN chmod +x /etc/service/dncserver_start/run

# TO start DNC-STANDARD-PLUGIN during system boot
COPY dncstdplugin_start /etc/service/dncstdplugin_start/run
RUN chmod +x /etc/service/dncstdplugin_start/run

# TO start DNC-GRAFANA-INFLUXDB-PLUGIN during system boot
COPY dncgiplugin_start /etc/service/dncgiplugin_start/run
RUN chmod +x /etc/service/dncgiplugin_start/run
