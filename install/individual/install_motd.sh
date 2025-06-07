#!/bin/bash

ARG=${1:-"desktop"}
TARGET_DIR=/opt/smart_monitor   
BASE_SCRIPT_DIR=..

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    # if file is run standalone target dir is on level higher
    BASE_SCRIPT_DIR=../..
fi

if [ "$ARG" == "media" ]; then
    ARG="desktop"
fi

echo "-----------------------------Installing MOTD Scripts-----------------------------"
apt install lolcat figlet -y

rm /etc/update-motd.d/*
echo Copying MOTD files.

if [ ! -f "$BASE_SCRIPT_DIR/motd/$ARG/10-hostname" ] ; then
    if [ ! -f "./Debian_linux_scripts/motd/$ARG/10-hostname" ] ; then
        git clone https://github.com/KaraBrandsen/Debian_linux_scripts.git
    fi

    cp ./Debian_linux_scripts/motd/$ARG/* /etc/update-motd.d
else
    cp $BASE_SCRIPT_DIR/motd/$ARG/* /etc/update-motd.d
fi

/usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd
chmod +x -R /etc/update-motd.d/

if [ ! -f "$TARGET_DIR/smart_data_collection.sh" ] && [ -f "/etc/update-motd.d/50-disk-status" ]; then
    echo Installing prerequisites for displaying HDD SMART data.
    mkdir -p $TARGET_DIR

    cp "$BASE_SCRIPT_DIR/utilities/smart_data_collection.sh" "$TARGET_DIR/smart_data_collection.sh"
    chmod +x "$TARGET_DIR/smart_data_collection.sh"

    echo Testing SMART data collection script:
    echo $TARGET_DIR/smart_data_collection.sh show
fi

echo Installing Crontab for long running commands.
crontab -l > root_cron

if grep -F "/usr/bin/env figlet" root_cron ; then
    echo "Existing Cron job found for Figlet"
else
    echo "0 */12 * * * /usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd" >> root_cron
    echo "@reboot /usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd" >> root_cron
fi

if [ -f "/etc/update-motd.d/50-disk-status" ]; then
    if grep -F "$TARGET_DIR/smart_data_collection.sh" root_cron ; then
        echo "Existing Cron job found for SMART Monitor"
    else
        echo "0 */1 * * * $TARGET_DIR/smart_data_collection.sh >> $TARGET_DIR/log.txt 2>&1" >> root_cron
        echo "@reboot $TARGET_DIR/smart_data_collection.sh >> $TARGET_DIR/log.txt 2>&1" >> root_cron
    fi
fi

crontab root_cron
rm root_cron