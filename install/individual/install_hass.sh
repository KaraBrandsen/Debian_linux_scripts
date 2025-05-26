#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Common Scripts
    source "../common/common_variables.sh"
fi

MQTT_PORT=8888

echo "-----------------------------Installing Home Assistant-----------------------------"

echo "Installing moquitto MQTT broker:"
sudo apt install -y mosquitto mosquitto-clients

if grep -F "listener $MQTT_PORT" /etc/mosquitto/mosquitto.conf ; then
    echo "Mosquito already configured"
else
    echo " " >> /etc/mosquitto/mosquitto.conf
    echo "listener $MQTT_PORT" >> /etc/mosquitto/mosquitto.conf
    echo "allow_anonymous true" >> /etc/mosquitto/mosquitto.conf
fi

systemctl restart mosquitto

mkdir -p $DOCKER_DIR/config/hass/

if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - $DOCKER_DIR/config/hass/:/config
      - /etc/localtime:/etc/localtime:ro
      - /run/dbus:/run/dbus:ro
    restart: unless-stopped
    privileged: true
    network_mode: host
    devices:
     - /dev/ttyUSB0:/dev/ttyUSB0
     - /dev/ttyACM0:/dev/ttyACM0
     - /dev/ttyAMA0:/dev/ttyAMA0

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "stirling-pdf" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - $DOCKER_DIR/config/hass/:/config
      - /etc/localtime:/etc/localtime:ro
      - /run/dbus:/run/dbus:ro
    restart: unless-stopped
    privileged: true
    network_mode: host
    devices:
     - /dev/ttyUSB0:/dev/ttyUSB0
     - /dev/ttyACM0:/dev/ttyACM0
     - /dev/ttyAMA0:/dev/ttyAMA0

EOF
    fi
fi

docker compose up -d homeassistant