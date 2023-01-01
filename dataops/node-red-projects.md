 # Node-RED Projects for Git Version Control
 
 Node-RED projects implement Git for flows management.

## Enable Node-RED Projects

** Node-RED Projects are enabled by editing the Settings.js file.**
 
 > `cd /opt/docker/dashstack`

 > `docker-compose exec node-red bash`

 > `vi /usr/src/node-red/.node-red/settings.js`

## Node-RED projects

Repo Parts:

* Flows
* Servers
* Credentials
* Credentials encryption key

```
   editorTheme: {
       projects: {
           enabled: true
       }
   },
```