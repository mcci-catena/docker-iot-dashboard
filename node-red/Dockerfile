FROM cpswan/node-red

RUN mkdir -p /root/.node-red /root/node-red-files
RUN mkdir /root/.node-red/lib
RUN mkdir /root/.node-red/lib/flows

WORKDIR /root/.node-red
RUN npm install -g node-red-contrib-influxdb
RUN npm install -g node-red-contrib-ttn

# seed the files that have to be present, but in an area
# that doesn't get overlaid by host file-system files
ADD settings.js evb start-node-red.sh /root/node-red-files/

CMD ["/bin/bash", "/root/node-red-files/start-node-red.sh", "/usr/local/bin/node-red"]
