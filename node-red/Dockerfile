FROM cpswan/node-red

RUN mkdir /root/.node-red
ADD settings.js /root/.node-red/settings.js

RUN mkdir /root/.node-red/lib
RUN mkdir /root/.node-red/lib/flows
ADD evb /root/.node-red/lib/flows/evb

WORKDIR /root/.node-red
RUN npm install -g node-red-contrib-influxdb

CMD ["/usr/local/bin/node-red"]
