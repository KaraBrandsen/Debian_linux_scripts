#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Common Scripts
    source "../common/common_variables.sh"
fi

MQTT_PORT=8888

echo "-----------------------------Installing Tdarr Transcoder-----------------------------"

mkdir -p $DOCKER_DIR/config/tdarr/configs
mkdir -p $DOCKER_DIR/config/tdarr/server
mkdir -p $DOCKER_DIR/config/tdarr/logs

cat <<EOF | tee "$DOCKER_DIR/config/tdarr/configs/Tdarr_Server_Config.json" >/dev/null
{
  "serverPort": "8266",
  "webUIPort": "8085",
  "serverIP": "0.0.0.0",
  "serverBindIP": false,
  "handbrakePath": "",
  "ffmpegPath": "",
  "mkvpropeditPath": "",
  "ccextractorPath": "",
  "openBrowser": false,
  "cronPluginUpdate": "",
  "auth": false,
  "authSecretKey": "",
  "maxLogSizeMB": 10
}
EOF

cat <<EOF | tee "$DOCKER_DIR/config/tdarr/configs/Tdarr_Node_Config.json" >/dev/null
{
  "nodeName": "TDARR-NODE",
  "serverURL": "http://0.0.0.0:8266",
  "serverIP": "0.0.0.0",
  "serverPort": "8266",
  "handbrakePath": "",
  "ffmpegPath": "",
  "mkvpropeditPath": "",
  "pathTranslators": [
    {
      "server": "",
      "node": ""
    }
  ],
  "nodeType": "mapped",
  "unmappedNodeCache": "",
  "priority": -1,
  "cronPluginUpdate": "",
  "apiKey": "",
  "maxLogSizeMB": 10,
  "pollInterval": 2000,
  "startPaused": false
}
EOF

#Server Compose - Note: this is configured for iGPU transcoding
if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  tdarr-server:
    container_name: tdarr-server
    image: "ghcr.io/haveagitgat/tdarr:latest"
    restart: unless-stopped
    network_mode: bridge
    ports:
      - 8085:8085 # webUI port
      - 8266:8266 # server port
    environment:
      - TZ=$TIME_ZONE
      - PUID=1000
      - PGID=1000
      - UMASK_SET=002
      - internalNode=true
      - inContainer=true
      - ffmpegVersion=7
      - nodeName=TDARR-NODE
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - $DOCKER_DIR/config/tdarr/server:/app/server
      - $DOCKER_DIR/config/tdarr/configs:/app/configs
      - $DOCKER_DIR/config/tdarr/logs:/app/logs
      - /mnt/nas:/media
      - /transcode_cache:/temp

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "stirling-pdf" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  tdarr-server:
    container_name: tdarr-server
    image: "ghcr.io/haveagitgat/tdarr:latest"
    restart: unless-stopped
    network_mode: bridge
    ports:
      - 8085:8085 # webUI port
      - 8266:8266 # server port
    environment:
      - TZ=$TIME_ZONE
      - PUID=1000
      - PGID=1000
      - UMASK_SET=002
      - internalNode=true
      - inContainer=true
      - ffmpegVersion=7
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - $DOCKER_DIR/config/tdarr/server:/app/server
      - $DOCKER_DIR/config/tdarr/configs:/app/configs
      - $DOCKER_DIR/config/tdarr/logs:/app/logs
      - /mnt/nas:/media
      - /transcode_cache:/temp

EOF
    fi
fi

#Node Compose - Note: this is configured for iGPU transcoding
if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  tdarr-node:
    container_name: tdarr-node
    image: ghcr.io/haveagitgat/tdarr_node:latest
    restart: unless-stopped
    network_mode: service:tdarr-server
    environment:
      - TZ=Europe/London
      - PUID=1000
      - PGID=1000
      - UMASK_SET=002
      - inContainer=true
      - ffmpegVersion=7
      - transcodegpuWorkers=1
      - transcodecpuWorkers=1
      - healthcheckgpuWorkers=1
      - healthcheckcpuWorkers=1
    volumes:
      - $DOCKER_DIR/config/tdarr/configs:/app/configs
      - $DOCKER_DIR/config/tdarr/logs:/app/logs
      - /mnt/nas:/media
      - /transcode_cache:/temp
    devices:
      - /dev/dri:/dev/dri

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "stirling-pdf" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  tdarr-node:
    container_name: tdarr-node
    image: ghcr.io/haveagitgat/tdarr_node:latest
    restart: unless-stopped
    network_mode: service:tdarr
    environment:
      - TZ=Europe/London
      - PUID=1000
      - PGID=1000
      - UMASK_SET=002
      - inContainer=true
      - ffmpegVersion=7
      - transcodegpuWorkers=1
      - transcodecpuWorkers=1
      - healthcheckgpuWorkers=1
      - healthcheckcpuWorkers=1
    volumes:
      - $DOCKER_DIR/config/tdarr/configs:/app/configs
      - $DOCKER_DIR/config/tdarr/logs:/app/logs
      - /mnt/nas:/media
      - /transcode_cache:/temp
    devices:
      - /dev/dri:/dev/dri

EOF
    fi
fi

docker compose up -d tdarr-server
docker compose up -d tdarr-node