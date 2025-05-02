#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Common Scripts
    source "../common/disable_ip_v6.sh"
    source "../common/common_variables.sh"
    source "../../fixes/intel_gpu_hw_transcoding_fix.sh"
else
    source "../fixes/intel_gpu_hw_transcoding_fix.sh"
fi


echo "-----------------------------Installing Plex-----------------------------"

curl -s https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
apt update
apt install plexmediaserver -y
echo "Waiting for Plex to start:"

sleep 10
echo "Setting Plex permissions:"
usermod -a -G $APP_GUID plex
systemctl restart plexmediaserver

PLEX_URL="http://$IP_LOCAL:32400"
echo "Installled Plex"