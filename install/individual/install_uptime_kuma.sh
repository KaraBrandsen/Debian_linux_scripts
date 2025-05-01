#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    
    #Variables
    KUMA_PORT=8080                                          #Port to be used for the Uptime Kuma Web Interface
    SIGNAL_PORT=8079                                        #Port to be used for the Signal API used for notifications
    WAHA_PORT=8079                                          #Port to be used for the Whatsapp API used for notifications
    
    #Common Scripts
    source "../secrets.sh"
    source "../common/disable_ip_v6.sh"
fi

KUMA_USER=$KUMA_USER                                    #Username to be used for the Uptime Kuma Web Interface
KUMA_PASS=$KUMA_PASS                                    #Password to be used for the Uptime Kuma Web Interface
WAHA_API_KEY=$WAHA_API_KEY                              #APIkey to be used by Uptime Kuma for the notification service
WAHA_DASH_USER=$WAHA_DASH_USER                          #Username to be used for the WAHA Web Interface
WAHA_DASH_PASS=$WAHA_DASH_PASS                          #Password to be used for the WAHA Web Interface
WAHA_SWAGGER_USER=$WAHA_SWAGGER_USER                    #Username to be used for the WAHA Swagger
WAHA_SWAGGER_PASS=$WAHA_SWAGGER_PASS                    #Password to be used for the WAHA Swagger


echo "-----------------------------Installing Uptime Kuma-----------------------------"

cat <<EOF | tee docker-compose.yaml >/dev/null
version: '3.3'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:beta
    container_name: uptime-kuma
    volumes:
      - ./uptime-kuma-data:/app/data
    ports:
      - $KUMA_PORT:3001  # <Host Port>:<Container Port>
    restart: always

  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api
    container_name: signal-api
    volumes:
      - /home/karabrandsen/.local/share/signal-api:/home/.local/share/signal-cli
    ports:
      - $SIGNAL_PORT:8080
    restart: always
    environment:
      - MODE=native

  waha:
    image: devlikeapro/waha
    ports:
      - '$WAHA_PORT:3000/tcp'
    volumes:
      - './sessions:/app/.sessions'
      - './.media:/app/.media'
    restart: always
    env_file:
      - .env
EOF

cat <<EOF | tee docker-compose.yaml >/dev/null
WAHA_BASE_URL=http://localhost:3000
WHATSAPP_API_KEY=$WAHA_API_KEY
WAHA_DASHBOARD_USERNAME=$WAHA_DASH_USER
WAHA_DASHBOARD_PASSWORD=$WAHA_DASH_PASS
WAHA_LOG_FORMAT=JSON
WAHA_LOG_LEVEL=info
WHATSAPP_DEFAULT_ENGINE=WEBJS
WAHA_PRINT_QR=False
WHATSAPP_SWAGGER_USERNAME=$WAHA_SWAGGER_USER
WHATSAPP_SWAGGER_PASSWORD=$WAHA_SWAGGER_PASS
WAHA_MEDIA_STORAGE=LOCAL
WHATSAPP_FILES_LIFETIME=0
WHATSAPP_FILES_FOLDER=/app/.media
EOF

docker compose up -d

# Configuring Uptime Kuma

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