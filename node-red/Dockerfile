# 
# Dockerfile for building the node red image.
#

# build the node red image using the offical node red distribution
# passing arguments to build specific image
ARG node_red_version
FROM nodered/node-red:${node_red_version}

# To avoid SSL certification issue
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Install required modules
ARG node_red_install_modules
RUN npm install ${node_red_install_modules}
# we always want the influxdb plug-in.
RUN npm install node-red-contrib-influxdb
# fix any dependency issues
RUN npm audit fix

# add The Things Network connector -- this must be after npm audit fix becuase
# it uses a deprecated API.
ARG node_red_contrib_ttn_version
RUN npm install node-red-contrib-ttn@${node_red_contrib_ttn_version}

# copy the settings file
USER node-red
COPY settings.js /usr/src/node-red/.node-red/

# change the startup command to be sure to use our settings.
CMD ["npm", "start", "--", "--userDir", "/data", "--settings", "/usr/src/node-red/.node-red/settings.js"]

# end of file
