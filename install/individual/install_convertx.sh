#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Variables
    CONVERTX_PORT=8100                                       #Port Convertx should be served on

    #Common Scripts
    source "../common/common_variables.sh"
fi


echo "-----------------------------Installing ConvertX-----------------------------"

mkdir -p $DOCKER_DIR/config/convertx/data

if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: ConvertX
    restart: unless-stopped
    ports:
      - "$CONVERTX_PORT:3000"
    environment:
      - ALLOW_UNAUTHENTICATED=true
      - HTTP_ALLOWED=true
    volumes:
      - $DOCKER_DIR/config/convertx/data:/app/data

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "convertx" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: ConvertX
    restart: unless-stopped
    ports:
      - "$CONVERTX_PORT:3000"
    environment:
      - ALLOW_UNAUTHENTICATED=true
      - HTTP_ALLOWED=true
    volumes:
      - $DOCKER_DIR/config/convertx/data:/app/data

EOF
    fi
fi

docker compose up -d convertx
