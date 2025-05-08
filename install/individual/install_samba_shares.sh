#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    source "../secrets.sh"
fi

#Variables
WIN_HOST=$WIN_HOST                                      #IP address of the windows host 
WIN_SHARES=$WIN_SHARES                                  #An array of the shared folders
WIN_USER=$WIN_USER                                      #Username used to access the windows shares
WIN_PASS=$WIN_PASS                                      #Password used to access the windows shares
APP_UID=$SUDO_USER
APP_GUID=users


echo "-----------------------------Installing Windows Shares-----------------------------"

apt install cifs-utils ntfs-3g -y

for SHARE in ${WIN_SHARES[@]}; do
    mkdir -p /mnt/$SHARE

cat <<EOF | tee /etc/systemd/system/mnt-$SHARE.mount >/dev/null
[Unit]
Description=//$WIN_HOST/$SHARE
Requires=network-online.target
After=network-online.target systemd-resolved.service
Wants=network-online.target systemd-resolved.service

[Mount]
What=//$WIN_HOST/$SHARE
Where=/mnt/$SHARE
Type=cifs
Options=user=$WIN_USER,password=$WIN_PASS,uid=$APP_UID,gid=$APP_GUID

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | tee /etc/systemd/system/mnt-$SHARE.automount >/dev/null
[Unit]
Description=Automount //$WIN_HOST/$SHARE

[Automount]
Where=/mnt/$SHARE

[Install]
WantedBy=multi-user.target
EOF

    systemctl start mnt-$SHARE.mount
    systemctl enable mnt-$SHARE.automount

    if ! command -v gnome-shell 2>&1 >/dev/null ; then
        echo "Gnome Shell could not be found. Not adding desktop shortcuts."
    else
        ln -s /mnt/$SHARE /home/$SUDO_USER/Desktop
    fi
done

echo "Installled Windows Shares"