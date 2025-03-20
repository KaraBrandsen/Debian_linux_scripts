#!/bin/bash
source "../secrets.sh"

#Variables
WIN_HOST=$WIN_HOST                                      #IP address of the windows host 
WIN_SHARES=$WIN_SHARES                                  #An array of the shared folders
WIN_USER=$WIN_USER                                      #Username used to access the windows shares
WIN_PASS=$WIN_PASS                                      #Password used to access the windows shares


echo "-----------------------------Installing Windows Shares-----------------------------"

apt install cifs-utils ntfs-3g-y

for SHARE in ${WIN_SHARES[@]}; do
    mkdir -p /mnt/$SHARE

    cat <<EOF | tee /etc/systemd/system/mnt-$SHARE.mount >/dev/null
    [Unit]
    Description=//$WIN_HOST/$SHARE

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
    Requires=network-online.target

    [Automount]
    Where=/mnt/$SHARE

    [Install]
    WantedBy=multi-user.target
EOF

    systemctl start mnt-$SHARE.mount
    systemctl enable mnt-$SHARE.automount

    ln -s /mnt/$SHARE /home/$SUDO_USER/Desktop
done

echo "Installled Windows Shares"