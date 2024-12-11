#!/bin/bash
source "secrets.sh"

#Variables
RUSTDESK_PASS=$RUSTDESK_PASS                            #Rustdesk Client Password. Used to log into a device
RUSTDESK_CFG=$RUSTDESK_CFG                              #Config string from and existing Rustdesk client. https://rustdesk.com/docs/en/self-host/client-configuration/#setup-using-import-or-export    


echo "-----------------------------Installing Rustdesk Client-----------------------------"
apt install xserver-xorg-video-all -y

wget https://github.com/rustdesk/rustdesk/releases/download/1.3.2/rustdesk-1.3.2-x86_64.deb
apt-get install -fy ./rustdesk-1.3.2-x86_64.deb > null

# Apply new password to RustDesk
rustdesk --password $RUSTDESK_PASS &> /dev/null
rustdesk --config $RUSTDESK_CFG
systemctl restart rustdesk

sed -i "s/#WaylandEnable=false/WaylandEnable=false/" "/etc/gdm3/custom.conf"
echo "Installed Rustdesk Client"