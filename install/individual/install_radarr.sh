#!/bin/bash

RADARR_PORT=7878
APP_UID=$SUDO_USER
APP_GUID=users

HOST=$(hostname -I)
IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")

echo "-----------------------------Installing Radarr-----------------------------"
set -euo pipefail

app="radarr"
app_port=$RADARR_PORT          # Default App Port; Modify config.xml after install if needed
app_umask="0002"
branch="master"                # {Update me if needed} branch to install
installdir="/opt"              # {Update me if needed} Install Location
bindir="${installdir}/${app^}" # Full Path to Install Location
datadir="/var/lib/$app/"       # {Update me if needed} AppData directory to use
app_bin=${app^}                # Binary Name of the app

echo "This will install [${app^}] to [$bindir] and use [$datadir] for the AppData Directory"

echo "Stoping the App if running"
if service --status-all | grep -Fq "$app"; then
    systemctl stop "$app"
    systemctl disable "$app".service
    echo "Stopped existing $app."
fi

echo "Create Appdata Directories"
mkdir -p "$datadir"
chown -R "$APP_UID":"$APP_GUID" "$datadir"
chmod 775 "$datadir"
echo -e "Directories $bindir and $datadir created!"

echo "Download and install the App"
ARCH=$(dpkg --print-architecture)
dlbase="https://$app.servarr.com/v1/update/$branch/updatefile?os=linux&runtime=netcore"
case "$ARCH" in
"amd64") DLURL="${dlbase}&arch=x64" ;;
"armhf") DLURL="${dlbase}&arch=arm" ;;
"arm64") DLURL="${dlbase}&arch=arm64" ;;
*)
    echo -e "Your arch is not supported!"
    echo -e "Exiting installer script!"
    exit 1
    ;;
esac

echo -e "Removing tarballs..."
sleep 3
rm -f "${app^}".*.tar.gz
echo -e "Downloading required files..."
wget --inet4-only --content-disposition "$DLURL"
tar -xvzf "${app^}".*.tar.gz >/dev/null 2>&1
echo -e "Installation files downloaded and extracted!"

echo -e "Removing existing installation files from $bindir]"
rm -rf "$bindir"
sleep 2
echo -e "Attempting to install ${app^}..."
sleep 2
mv "${app^}" $installdir
chown "$APP_UID":"$APP_GUID" -R "$bindir"
chmod 775 "$bindir"
touch "$datadir"/update_required
chown "$APP_UID":"$APP_GUID" "$datadir"/update_required
echo -e "Successfully installed ${app^}!!"
rm -rf "${app^}.*.tar.gz"
sleep 2

echo "Removing old service file..."
rm -rf /etc/systemd/system/"$app".service
sleep 2

echo "Creating new service file..."
cat <<EOF | tee /etc/systemd/system/"$app".service >/dev/null
[Unit]
Description=${app^} Daemon
After=syslog.target network.target
[Service]
User=$APP_UID
Group=$APP_GUID
UMask=$app_umask
Type=simple
ExecStart=$bindir/$app_bin -nobrowser -data=$datadir
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sleep 2

echo -e "${app^} is attempting to start, this may take a few seconds..."
systemctl -q daemon-reload
systemctl enable --now -q "$app"
sleep 5

echo "Checking if the service is up and running..."
while ! systemctl is-active --quiet "$app"; do
    sleep 5
done

sed -i "s/>7878</>$app_port</" "$datadir"config.xml
systemctl restart -q $app

echo -e "${app^} installation and service start up is complete!"
echo -e "Attempting to check for a connection at http://$IP_LOCAL:$app_port..."
sleep 15

STATUS="$(systemctl is-active "$app")"
if [ "${STATUS}" = "active" ]; then
    echo "Setting more sensible quality values"
    QUALITIES=$(curl -s -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X GET "http://$IP_LOCAL:$RADARR_PORT/api/v3/qualitydefinition")

    QUALITY_MAP='{"Unknown":{"minSize":0,"maxSize":25,"preferredSize":20},"WORKPRINT":{"minSize":0,"maxSize":25,"preferredSize":20},"CAM":{"minSize":0,"maxSize":25,"preferredSize":20},"TELESYNC":{"minSize":0,"maxSize":25,"preferredSize":20},"TELECINE":{"minSize":0,"maxSize":25,"preferredSize":20},"REGIONAL":{"minSize":0,"maxSize":25,"preferredSize":20},"DVDSCR":{"minSize":0,"maxSize":25,"preferredSize":20},"SDTV":{"minSize":0,"maxSize":25,"preferredSize":20},"DVD":{"minSize":0,"maxSize":25,"preferredSize":20},"DVD-R":{"minSize":0,"maxSize":25,"preferredSize":20},"WEBDL-480p":{"minSize":0,"maxSize":25,"preferredSize":20},"WEBRip-480p":{"minSize":0,"maxSize":25,"preferredSize":20},"Bluray-480p":{"minSize":0,"maxSize":25,"preferredSize":20},"Bluray-576p":{"minSize":0,"maxSize":25,"preferredSize":20},"HDTV-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBDL-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBRip-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"Bluray-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"HDTV-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBDL-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBRip-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"Bluray-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"Remux-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"HDTV-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"WEBDL-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"WEBRip-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"Bluray-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"Remux-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"BR-DISK":{"minSize":0,"maxSize":80,"preferredSize":20},"Raw-HD":{"minSize":0,"maxSize":80,"preferredSize":20}}'
    NUM_QUALITIES=$(echo "$QUALITIES" | jq length)

    for ((i = 0; i < NUM_QUALITIES; i++)) ; do

        QUALITY_NAME=$(echo $QUALITIES | jq ".[$i].title" ) 
        QUALITY=$(echo $QUALITIES | jq ".[$i]" ) 

        MINSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.minSize")  
        MAXSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.maxSize")  
        PREFSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.preferredSize")

        if [ "$MINSIZE" != "null" ] ; then
                QUALITY=$(echo $QUALITY | jq ".minSize=$MINSIZE | .maxSize=$MAXSIZE | .preferredSize=$PREFSIZE")
        fi

        curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$RADARR_PORT/api/v3/qualitydefinition" --data "${QUALITY}"
    done

    echo "Setting permissions settings"
    curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$RADARR_PORT/api/v3/config/mediamanagement"  --data '{"autoUnmonitorPreviouslyDownloadedMovies":false,"recycleBin":"","recycleBinCleanupDays":7,"downloadPropersAndRepacks":"preferAndUpgrade","createEmptyMovieFolders":false,"deleteEmptyFolders":true,"fileDate":"none","rescanAfterRefresh":"always","autoRenameFolders":true,"pathsDefaultStatic":false,"setPermissionsLinux":true,"chmodFolder":"755","chownGroup":"'"$APP_GUID"'","skipFreeSpaceCheckWhenImporting":false,"minimumFreeSpaceWhenImporting":100,"copyUsingHardlinks":true,"useScriptImport":false,"scriptImportPath":"","importExtraFiles":true,"extraFileExtensions":"srt","enableMediaInfo":true,"id":1}'

    RADARR_URL="http://$IP_LOCAL:$app_port"
    echo "Browse to $RADARR_URL for the ${app^} GUI"
else
    echo "${app^} failed to start"
fi

rm -f "${app^}".*.tar.gz
echo "Installled Radarr"