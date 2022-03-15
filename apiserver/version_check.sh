#!/usr/bin/env bash
#Author: Murugan Chandrasekar

#set -e

src_p="/opt/docker/"
cd $src_p || exit

while IFS= read -r i
do
    echo "$i"
    if docker-compose --env-file "${i}/.env" -f "${i}/docker-compose.yml" ps | grep -i "nginx" | grep -i "up" > /dev/null
    then
            wd="$i"
            echo "$wd"
            break
    fi
done < <(find $src_p -type f -iname ".env" -printf "%h\n")

if [ -z "$wd" ]; then exit 1 ; fi

cd "$wd" || exit

for j in $(docker-compose ps --services)
do
        case $j in
                mqtts)
                        if [ "$j" = "mqtts" ]; then mqsv=$(docker-compose exec -T mqtts mosquitto -h | sed -n '/version/p' | awk '{print $3}' | tr -cd '[:print:]') ; fi
                        ;;
                influxdb)
                        if [ "$j" = "influxdb" ]; then inbv=$(docker-compose exec -T influxdb influx --version | awk -F: '{print $2}' | tr -cd '[:print:]') ; fi
                        ;;
                postfix)
                        if [ "$j" = "postfix" ]; then poxv=$(docker-compose exec -T postfix postconf -d mail_version | awk '{print $3}' | tr -cd '[:print:]'); fi
                        ;;
                grafana)
                        if [ "$j" = "grafana" ]; then grav=$(docker-compose exec -T grafana grafana-server -v | awk '{print $2}' | tr -cd '[:print:]') ; fi
                        ;;
                node-red)
                        if [ "$j" = "node-red" ]; then nodv=$(docker-compose exec -T node-red env | grep -i NODE_RED_VERSION | cut -d'=' -f2- | tr -cd '[:print:]'); fi
                        ;;
                apiserver)
                        if [ "$j" = "apiserver" ]; then aprv=$(docker-compose exec -T apiserver node --version | tr -d 'v' | tr -cd '[:print:]'); fi
                        ;;
                mongodb)
                        if [ "$j" = "mongodb" ]; then mobv=$(docker-compose exec -T mongodb mongod --version | sed -n '/db version/p' | awk '{print $3}' | tr -d 'v' | tr -cd '[:print:]') ; fi
                        ;;
                expo)
                        if [ "$j" = "expo" ]; then exov=$(docker-compose exec -T expo expo --version | tr -cd '[:print:]') ; fi
                        ;;
                nginx)  if [ "$j" = "nginx" ]; then ngxv=$(docker-compose exec -T nginx nginx -v 2>&1 | awk -F/ '{print $2}' | tr -cd '[:print:]') ; fi
                        ;;
        esac

done

dorv=$(docker --version | cut -d' ' -f3-)

dorcev=$(docker-compose --version | cut -d' ' -f3-)

pnuv=$(apt list --upgradable | grep -icv Listing)

orv=$(lsb_release -d | cut -f2-)

lpudv=$(< /var/log/dpkg.log grep -i upgrade | sort -rn | awk 'NR==1{print $1}')

function _parseenv {
        sed -n -e 's/#.*$//g' -e 's/^[ \t]*//' -e 's/[ \t]*=[ \t]*/=/' -e 's/^\([A-Za-z0-9_][A-Za-z0-9_]*\)=\(.*\)$/\1 \2/p' "$1"
}

IOT_DASHBOARD_DATA="$(_parseenv ".env" | sed -ne 's/^IOT_DASHBOARD_DATA //p')"

dncsrv=$(cd "${IOT_DASHBOARD_DATA}"apiserver/dncserver && git describe --tags || echo "Oops, something went wrong")

dncgiv=$(cd "${IOT_DASHBOARD_DATA}"apiserver/dncgiplugin && git describe --tags || echo "Oops, something went wrong")

dncstdv=$(cd "${IOT_DASHBOARD_DATA}"apiserver/dncstdplugin && git describe --tags || echo "Oops, something went wrong")

dncuiv=$(cd "${IOT_DASHBOARD_DATA}"expo/dncui && git describe --tags || echo "Oops, something went wrong")

#datv=$(date +%Y-%m-%d_%H:%M:%S%Z)
datv=$(date)
#<b>Updated on: "$datv"</b><br>

tee "${IOT_DASHBOARD_DATA}"apiserver/version/ver_info <<EOF

<html lang="en">
<body style="background-color:antiquewhite;">
<b>Updated on: "$datv"</b><br>


<h1>System Info:</h1>
<ul>
        <li><b>OS_release: "$orv"</b></li><br>

        <li><b>Date_of_last_package_upgrade: "$lpudv"</b></li><br>

        <li><b>Number_of_packages_needed_to_be_upgraded: "$pnuv packages can be upgraded"</b></li><br>

        <li><b>Docker_version: "$dorv"</b></li><br>

        <li><b>Docker_compose_cersion: "$dorcev"</b></li><br>
</ul>
<h1>Docker-IoT-Dashboard Info:</h1>
<ul>

        <li><b>Mqtts_version: "$mqsv"</b></li><br>

        <li><b>Influxdb_version: "$inbv"</b></li><br>

        <li><b>Postfix_version: "$poxv"</b></li><br>

        <li><b>Grafana_version: "$grav"</b></li><br>

        <li><b>Node-RED_version: "$nodv"</b></li><br>

        <li><b>Apiserver-Node_version: "$aprv"</b></li><br>

        <li><b>Mongodb_version: "$mobv"</b></li><br>

        <li><b>Expo_version: "$exov"</b></li><br>

        <li><b>Nginx_version: "$ngxv"</b></li><br>

        <li><b>DNC-server_version: "$dncsrv"</b></li><br>

        <li><b>DNC-GI_plugin_version: "$dncgiv"</b></li><br>

        <li><b>DNC-STD_plugin_version: "$dncstdv"</b></li><br>

        <li><b>DNC-UI__version: "$dncuiv"</b></li><br>
</ul>
</body>
</html>
EOF
