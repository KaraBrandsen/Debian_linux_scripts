#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Common Scripts
    source "../common/common_variables.sh"
fi


echo "-----------------------------Installing Glances Server-----------------------------"

mkdir -p $DOCKER_DIR/config/glances

    cat <<EOF | tee "$DOCKER_DIR/config/glances/glances.conf" >/dev/null
[global]
refresh=2
check_update=false

[fs]
hide=/boot.*,/snap.*,/etc.*,/usr.*,loop.*
show=sda.*

[network]
hide=docker.*,lo,veth.*,br.*,loop.*

[wifi]
disable=False
careful=-65
warning=-75
critical=-85

[diskio]
hide=^sd..$,loop.*,^nvme0n..$

[containers]
disable=True
EOF


if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  glances:
    image: nicolargo/glances:latest-full
    container_name: glances
    restart: unless-stopped
    privileged: true
    network_mode: host
    environment:
    - "TZ=${TIME_ZONE}"
    - "GLANCES_OPT=-w"
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - /etc/os-release:/etc/os-release:ro
    - $DOCKER_DIR/config/glances/glances.conf:/etc/glances/glances.conf
    pid: host

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "glances" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  glances:
    image: nicolargo/glances:latest-full
    container_name: glances
    restart: unless-stopped
    privileged: true
    network_mode: host
    environment:
    - "TZ=${TIME_ZONE}"
    - "GLANCES_OPT=-w"
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - /etc/os-release:/etc/os-release:ro
    - $DOCKER_DIR/config/glances/glances.conf:/etc/glances/glances.conf
    pid: host

EOF
    fi
fi