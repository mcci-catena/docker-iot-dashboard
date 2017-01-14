# 
# Dockerfile for building the node red image.
#

# build the node red image using the offical node red distribution
FROM nodered/node-red-docker

# add the influxDB connector
RUN npm install node-red-contrib-influxdb

# add The Things Network connector
RUN npm install node-red-contrib-ttn

# end of file

