#
# Dockerfile for building EXPO
#

# Build the EXPO using phusion base image

FROM phusion/baseimage:master-amd64

# Enabling SSH service
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Installing the required Packages
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - 
RUN apt-get update && apt-get install nodejs tmux -y
RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update && apt-get install git -y
RUN npm install expo-cli --global

# Copying public keys to get SSH access to this Container
COPY *.pub /tmp/
RUN cat /tmp/*.pub >> /root/.ssh/authorized_keys && rm -f /tmp/*.pub

# Starting Expo Service
COPY expo_start /etc/service/expo_start/run
RUN chmod +x /etc/service/expo_start/run
