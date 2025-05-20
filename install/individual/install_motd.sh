#!/bin/bash

ARG=${1:-"desktop"}   

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ "$ARG" == "media" ]; then
    ARG="desktop"
fi

echo "-----------------------------Installing MOTD Scripts-----------------------------"
apt install lolcat figlet -y

rm /etc/update-motd.d/*
echo Copying MOTD files.

# if file is run standalone target dir is on level higher
if [ ${SOURCED} -eq 0 ]; then
    if [ ! -f "../../motd/$ARG/10-hostname" ] ; then
        if [ ! -f "./Debian_linux_scripts/motd/$ARG/10-hostname" ] ; then
            git clone https://github.com/KaraBrandsen/Debian_linux_scripts.git
        fi

        cp ./Debian_linux_scripts/motd/$ARG/* /etc/update-motd.d
    else
        cp ../../motd/$ARG/* /etc/update-motd.d
    fi
else
    if [ ! -f "../motd/$ARG/10-hostname" ] ; then
        if [ ! -f "./Debian_linux_scripts/motd/$ARG/10-hostname" ] ; then
            git clone https://github.com/KaraBrandsen/Debian_linux_scripts.git
        fi

        cp ./Debian_linux_scripts/motd/$ARG/* /etc/update-motd.d
    else
        cp ../motd/$ARG/* /etc/update-motd.d
    fi
fi 

/usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd
chmod +x -R /etc/update-motd.d/

echo Installing Crontab for long running commands.
crontab -l > root_cron
if grep -F "/usr/bin/env figlet" root_cron ; then
    echo "Existing Cron job found"
else
    echo "0 */12 * * * /usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd" >> root_cron
    echo "@reboot /usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd" >> root_cron
fi

crontab root_cron
rm root_cron