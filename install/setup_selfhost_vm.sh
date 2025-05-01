#!/bin/bash
source "secrets.sh"

ZT_TOKEN=$ZT_TOKEN	 	              
NWID=$NWID

KUMA_USER=$KUMA_USER
KUMA_PASS=$KUMA_PASS
KUMA_PORT=8080
SIGNAL_PORT=8079
WAHA_PORT=8079

apt update
apt upgrade -y
apt install git pipx curl python3-pip pipx python3-dev jq build-essential openssh-server htop net-tools bmon software-properties-common ca-certificates -y

#DuckDNS
source "./individual/install_duckdns.sh"

#Zerotier Setup
source "./individual/install_zerotier.sh"

#Docker
source "./individual/install_docker.sh"

#Uptime Kuma
source "./individual/install_uptime_kuma.sh"

#Rust Desk
source "./individual/install_rustdesk_server.sh"