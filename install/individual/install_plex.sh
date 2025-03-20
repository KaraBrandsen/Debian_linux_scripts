#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Variables
    APP_GUID=users
    HOST=$(hostname -I)
    IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")
    
    #Common Scripts
    source "../../fixes/disable_ip_v6.sh"
fi


echo "-----------------------------Installing Plex-----------------------------"

INTEL_GPU=$(lspci -k | grep -EA3 'VGA|3D|Display' | grep "Intel" | xargs)
    
if [ "$INTEL_GPU" != "" ]; then
    DISTRO=$(lsb_release -i | grep "Distributor" | cut -d ':' -f 2 | xargs | cut -d '.' -f 1)

    if [ "$DISTRO" == "Ubuntu" ]; then
        VERSION=$(lsb_release -r | grep "Release" | cut -d ':' -f 2 | xargs)

        echo Intel GPU detected on $DISTRO $VERSION

        if [ "$VERSION" == "22.04" ]; then
            wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
            echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list
            apt update
            apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-22.04
        elif [ "$VERSION" == "24.04" ]; then
            wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
            echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | tee /etc/apt/sources.list.d/intel-gpu-noble.list
            sudo apt update
            apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-24.04
        fi
    fi
fi

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