#!/bin/bash

# This will only work with a single co-ordinator that is SiLabs Based

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Common Scripts
    source "../common/common_variables.sh"
fi

MQTT_PORT=8888

echo "-----------------------------Installing Zigbee2MQTT-----------------------------"

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

echo "Setting Zigbee2MQTT container:"
mkdir -p $DOCKER_DIR/config/zigbee2mqtt/

DEVICE=$(ls -l /dev/serial/by-id | grep "Zigbee" | cut -d ' ' -f '9')

if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  zigbee2mqtt:
    container_name: zigbee2mqtt
    image: ghcr.io/koenkk/zigbee2mqtt
    restart: unless-stopped
    volumes:
      - $DOCKER_DIR/config/zigbee2mqtt/:/app/data
      - /run/udev:/run/udev:ro
    ports:
      # Frontend port
      - 8104:8080
    group_add:
      - dialout
    user: 1000:1000
    environment:
      - TZ=$TIME_ZONE
    devices:
      # Make sure this matched your adapter location
      - /dev/serial/by-id/$DEVICE:/dev/ttyUSB0

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "stirling-pdf" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  zigbee2mqtt:
    container_name: zigbee2mqtt
    image: ghcr.io/koenkk/zigbee2mqtt
    restart: unless-stopped
    volumes:
      - $DOCKER_DIR/config/zigbee2mqtt/:/app/data
      - /run/udev:/run/udev:ro
    ports:
      # Frontend port
      - 8104:8080
    group_add:
      - dialout
    user: 1000:1000
    environment:
      - TZ=$TIME_ZONE
    devices:
      # Make sure this matched your adapter location
      - /dev/serial/by-id/$DEVICE:/dev/ttyUSB0

EOF
    fi
fi

cat <<EOF | tee -a "$DOCKER_DIR/config/zigbee2mqtt/configuration.yaml" >/dev/null
version: 4
mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://$LOCAL_IP:$MQTT_PORT
serial:
  port: /dev/ttyUSB0
  adapter: ember
  baudrate: 115200
  rtscts: false
advanced:
  log_level: info
  channel: 25
  network_key:
    - 164
    - 145
    - 119
    - 1
    - 74
    - 145
    - 39
    - 9
    - 215
    - 193
    - 248
    - 133
    - 141
    - 227
    - 45
    - 89
  pan_id: 9349
  ext_pan_id:
    - 115
    - 94
    - 73
    - 70
    - 110
    - 135
    - 122
    - 144
frontend:
  enabled: false
  port: 8080
homeassistant:
  enabled: true
EOF

docker compose up -d zigbee2mqtt