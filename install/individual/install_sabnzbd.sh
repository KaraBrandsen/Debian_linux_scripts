#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    source "../secrets.sh"

    #Variables
    SABNZBD_PORT=8081                                       #Port SABNZBD should be served on
    
    #Common Scripts
    source "../common/disable_ip_v6.sh"
    source "../common/common_variables.sh"
fi

SERVERS=$SERVERS                                        #News server details in JSON format. Can be multiple servers.


echo "-----------------------------Installing SABNZBd-----------------------------"

add-apt-repository ppa:jcfp/nobetas -y
apt-get update -y
apt-get install sabnzbdplus -y
    
echo "Creating new service file..."
cat <<EOF | tee /etc/default/sabnzbdplus >/dev/null
# This file is sourced by /etc/init.d/sabnzbdplus
#
# When SABnzbd+ is started using the init script, the
# --daemon option is always used, and the program is
# started under the account of $APP_UID, as set below.
#
# Each setting is marked either "required" or "optional";
# leaving any required setting un-configured will cause
# the service to not start.

# [required] user or uid of account to run the program as:
USER=$APP_UID

# [optional] full path to the configuration file of your choice;
#            otherwise, the default location (in $APP_UID's home
#            directory) is used:
CONFIG=

# [optional] hostname/ip and port number to listen on:
HOST=0.0.0.0
PORT=$SABNZBD_PORT

# [optional] extra command line options, if any:
EXTRAOPTS=
EOF

echo "Waiting for background processes"
service sabnzbdplus stop
systemctl daemon-reload
sleep 1
service sabnzbdplus restart
sleep 9
service sabnzbdplus stop
sleep 1

if grep -F "[servers]" /home/$APP_UID/.sabnzbd/sabnzbd.ini ; then
    echo "Existing Servers Found!"
else
    echo "Creating new config in /home/$APP_UID/.sabnzbd/sabnzbd.ini"
    echo [servers] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini

    NUM_SERVERS=$(echo "$SERVERS" | jq length)

    for ((i = 0; i < NUM_SERVERS; i++)) ; do

        SERVER_HOST=$(echo $SERVERS | jq ".[$i].SERVER_HOST")
        SERVER_PORT=$(echo $SERVERS | jq ".[$i].SERVER_PORT")
        SERVER_USERNAME=$(echo $SERVERS | jq ".[$i].SERVER_USERNAME")
        SERVER_PASSWORD=$(echo $SERVERS | jq ".[$i].SERVER_PASSWORD")
        SERVER_CONNECTIONS=$(echo $SERVERS | jq ".[$i].SERVER_CONNECTIONS")
        SERVER_SSL=$(echo $SERVERS | jq ".[$i].SERVER_SSL")

        echo [[$SERVER_HOST]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = $SERVER_HOST >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo displayname = $SERVER_HOST >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo host = $SERVER_HOST >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo port = $SERVER_PORT >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo timeout = 30 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo username = $SERVER_USERNAME >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo "password = $SERVER_PASSWORD" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo connections = $SERVER_CONNECTIONS >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo ssl = $SERVER_SSL >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo ssl_verify = 2 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo ssl_ciphers = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo enable = 1 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo required = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo optional = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo retention = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo expire_date = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo quota = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo usage_at_start = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo notes = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    done


    echo [categories] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[*]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo "name = *" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = 3 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = None >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[movies]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo name = movies >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[tv]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo name = tv >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[audio]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo name = audio >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[software]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo name = software >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[sonarr]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo name = sonarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = sonarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo [[radarr]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo name = radarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo dir = radarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
fi

sed -i 's/permissions = ""/permissions = 775/' /home/$APP_UID/.sabnzbd/sabnzbd.ini

systemctl daemon-reload
service sabnzbdplus restart

SABNZBD_URL="http://$IP_LOCAL:$SABNZBD_PORT"
echo "SABNZBd Is running: Browse to $SABNZBD_URL for the SABNZBd GUI"
echo "Installled SABNZBd"