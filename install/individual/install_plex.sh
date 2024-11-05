#!/bin/bash

HOST=$(hostname -I)
IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")

echo "-----------------------------Installing Plex-----------------------------"

apt install curl software-properties-common -y

curl -s https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
apt update
apt install plexmediaserver -y
echo "Waiting for Plex to start:"

sleep 10
echo "Setting Plex permissions:"
usermod -a -G $SUDO_USER plex
systemctl restart plexmediaserver

PLEX_URL="http://$IP_LOCAL:32400"
echo "Installled Plex: $PLEX_URL"