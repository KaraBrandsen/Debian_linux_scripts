#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Variables
    CONVERTX_PORT=8100                                       #Port Convertx should be served on
fi


echo "-----------------------------Installing ConvertX-----------------------------"

if [ ! -f "/home/$SUDO_USER/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "/home/$SUDO_USER/docker-compose.yaml" >/dev/null
version: '3.3'
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
      - ./data:/app/data

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "convertx" /home/$SUDO_USER/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "/home/$SUDO_USER/docker-compose.yaml" >/dev/null
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
      - ./data:/app/data

EOF
    fi
fi

docker compose up -d
