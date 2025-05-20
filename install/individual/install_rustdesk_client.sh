#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    source "../secrets.sh"
fi

#Variables
RUSTDESK_PASS=$RUSTDESK_PASS                            #Rustdesk Client Password. Used to log into a device
RUSTDESK_SERVER=$RUSTDESK_SERVER                        #Rendezvous Server
RUSTDESK_KEY=$RUSTDESK_KEY                              #Server Key


echo "-----------------------------Installing Rustdesk Client-----------------------------"
apt install xserver-xorg-video-all -y

wget https://github.com/rustdesk/rustdesk/releases/download/1.4.0/rustdesk-1.4.0-x86_64.deb
apt-get install -fy ./rustdesk-1.4.0-x86_64.deb > null

# Apply new password to RustDesk
rustdesk --password $RUSTDESK_PASS &> /dev/null
rustdesk --option allow-remote-config-modification Y
rustdesk --option custom-rendezvous-server $RUSTDESK_SERVER
rustdesk --option key $RUSTDESK_KEY
rustdesk --option enable-lan-discovery Y
rustdesk --option direct-server Y

systemctl restart rustdesk

sed -i "s/#WaylandEnable=false/WaylandEnable=false/" "/etc/gdm3/custom.conf"
echo "Installed Rustdesk Client"