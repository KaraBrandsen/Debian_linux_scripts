#!/bin/bash


echo "-----------------------------Installing Home Assistant-----------------------------"

if [ ! -f "/home/$SUDO_USER/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "/home/$SUDO_USER/docker-compose.yaml" >/dev/null
services:
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - /opt/config:/config
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

    if grep -F "stirling-pdf" /home/$SUDO_USER/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "/home/$SUDO_USER/docker-compose.yaml" >/dev/null
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - /opt/config:/config
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

docker compose up -d