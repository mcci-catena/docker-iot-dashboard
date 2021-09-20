#
# Dockerfile for building Node-red
#

# Build the Node-red using phusion base image
FROM phusion/passenger-nodejs:latest

# Installing basic net tools 
RUN apt-get update && apt-get install net-tools -y

# Copying the library files
COPY lib/* /nodered_lib/

# Install Node-red 
RUN npm install -g --unsafe-perm node-red node-red-admin

# Starting Node-red service 
RUN mkdir /etc/service/nodered_start
COPY anodered_start /etc/service/nodered_start/run
RUN chmod +x /etc/service/nodered_start/run

# Moving Library files
RUN mkdir /etc/service/nodered_start_lib
COPY bnodered_start_lib /etc/service/nodered_start_lib/run
RUN chmod +x /etc/service/nodered_start_lib/run
