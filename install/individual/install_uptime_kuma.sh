#!/bin/bash
source "../secrets.sh"

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Variables
    KUMA_PORT=8080                                          #Port to be used for the Uptime Kuma Web Interface
    
    #Common Scripts
    source "../fixes/disable_ip_v6.sh"
fi

KUMA_USER=$KUMA_USER                                    #Username to be used for the Uptime Kuma Web Interface
KUMA_PASS=$KUMA_PASS                                    #Password to be used for the Uptime Kuma Web Interface


echo "-----------------------------Installing Uptime Kuma-----------------------------"

LATEST_VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/nvm-sh/nvm/releases | jq -r '.[0].tag_name')
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$LATEST_VERSION/install.sh | bash

NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 20
npm install pm2 -g

CUR_DIR=$PWD
cd /opt
rm -r ./uptime-kuma

git clone https://github.com/louislam/uptime-kuma.git
cd uptime-kuma
npm run setup
npm install pm2 -g && pm2 install pm2-logrotate
pm2 unstartup
pm2 stop all
pm2 start server/server.js --name uptime-kuma -- --host=0.0.0.0 --port=$KUMA_PORT
pm2 save && pm2 startup

python3 -m venv .
source bin/activate
pip3 install uptime-kuma-api

echo "from uptime_kuma_api import UptimeKumaApi, MonitorType" > init.py
echo "api = UptimeKumaApi(\"http://localhost:$KUMA_PORT\")" >> init.py
echo "try:" >> init.py
echo "  api.setup(\"$KUMA_USER\", \"$KUMA_PASS\")" >> init.py
echo "  api.login(\"$KUMA_USER\", \"$KUMA_PASS\")" >> init.py

if [ "$INSTALL_ZEROTIER" == "true" ] || [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.PING, name='Zerotier', hostname=\"192.168.194.1\")" >> init.py
fi
if [ "$INSTALL_PIHOLE" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='PiHole UI', url=\"http://localhost/admin\")" >> init.py
    echo "  api.add_monitor(type=MonitorType.DNS, name='PiHole DNS', hostname=\"google.com\")" >> init.py
fi
if [ "$INSTALL_HASS" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='Home Assistant', url=\"http://localhost:8123\")" >> init.py
fi
if [ "$INSTALL_LIBRE_SPEEDTEST" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='Libre Speed Test', url=\"http://localhost:$LIBREST_PORT\")" >> init.py
fi
if [ "$INSTALL_SABNZBD" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='SABNZBd', url=\"http://localhost:$SABNZBD_PORT\")" >> init.py
fi
if [ "$INSTALL_DELUGE" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='Deluge', url=\"http://localhost:$DELUGE_PORT\")" >> init.py
fi
if [ "$INSTALL_SONARR" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='Sonarr', url=\"http://localhost:$SONARR_PORT\")" >> init.py
fi
if [ "$INSTALL_RADARR" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='Radarr', url=\"http://localhost:$RADARR_PORT\")" >> init.py
fi
if [ "$INSTALL_PLEX_SERVER" == "true" ] ; then
    echo "  api.add_monitor(type=MonitorType.HTTP, name='Plex', url=\"http://localhost:32400/web\")" >> init.py
fi

echo "  api.disconnect()" >> init.py
echo "except:" >> init.py
echo "  pass" >> init.py

echo "Configuring Monitors"
python3 ./init.py
rm ./init.py

cd $CUR_DIR
KUMA_URL="http://$IP_LOCAL:$KUMA_PORT"
echo "Installed Uptime Kuma"