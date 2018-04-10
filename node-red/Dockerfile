# 
# Dockerfile for building the node red image.
#

# build the node red image using the offical node red distribution
# passing arguments to build specific image
ARG node_red_version
FROM nodered/node-red-docker:${node_red_version}

# To avoid SSL certification issue
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# add the influxDB connector
RUN npm install node-red-contrib-influxdb

# add The Things Network connector
# passing arguments to build specific 
ARG node_red_contrib_version
RUN npm install node-red-contrib-ttn@${node_red_contrib_version}

# copy the settings file
USER node-red
COPY settings.js /usr/src/node-red/.node-red/

# change the startup command to be sure to use our settings.
CMD ["npm", "start", "--", "--userDir", "/data", "--settings", "/usr/src/node-red/.node-red/settings.js"]

# end of file

