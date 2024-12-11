#!/bin/bash

SONARR_PORT=7878
APP_UID=$SUDO_USER
APP_GUID=users

HOST=$(hostname -I)
IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")

echo "-----------------------------Installing Sonarr-----------------------------"
set -euo pipefail

app="sonarr"
app_port=$SONARR_PORT
app_umask="0002"
branch="main"
installdir="/opt"              # {Update me if needed} Install Location
bindir="${installdir}/${app^}" # Full Path to Install Location
datadir="/var/lib/$app/"       # {Update me if needed} AppData directory to use
app_bin=${app^}                # Binary Name of the app
APP_UID=$(echo "$APP_UID" | tr -d ' ')
APP_UID=${APP_UID:-$app}
APP_GUID=$(echo "$APP_GUID" | tr -d ' ')
APP_GUID=${APP_GUID:-media}

echo "This will install [${app^}] to [$bindir] and use [$datadir] for the AppData Directory"

echo "Stoppin the App if running"
if service --status-all | grep -Fq "$app"; then
    systemctl stop "$app"
    systemctl disable "$app".service
    echo "Stopped existing $app"
fi

mkdir -p "$datadir"
chown -R "$APP_UID":"$APP_GUID" "$datadir"
chmod 775 "$datadir"
echo "Directories created"

echo "Downloading and installing the App"
ARCH=$(dpkg --print-architecture)
dlbase="https://services.sonarr.tv/v1/download/$branch/latest?version=4&os=linux"
case "$ARCH" in
"amd64") DLURL="${dlbase}&arch=x64" ;;
"armhf") DLURL="${dlbase}&arch=arm" ;;
"arm64") DLURL="${dlbase}&arch=arm64" ;;
*)
    echo "Arch not supported"
    exit 1
    ;;
esac

rm -f "${app^}".*.tar.gz
wget --inet4-only --content-disposition "$DLURL"
tar -xvzf "${app^}".*.tar.gz
echo "Installation files downloaded and extracted"

echo "Removing existing installation"
rm -rf "$bindir"

echo "Installing..."
mv "${app^}" $installdir
chown "$APP_UID":"$APP_GUID" -R "$bindir"
chmod 775 "$bindir"
rm -rf "${app^}.*.tar.gz"
touch "$datadir"/update_required
chown "$APP_UID":"$APP_GUID" "$datadir"/update_required
echo "App Installed"

echo "Removing old service file"
rm -rf /etc/systemd/system/"$app".service

echo "Creating service file"
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

echo "Service file created. Attempting to start the app"
systemctl -q daemon-reload
systemctl enable --now -q "$app"
sleep 5

echo "Checking if the service is up and running..."
while ! systemctl is-active --quiet "$app"; do
    sleep 5
done

sed -i "s/>8989</>$app_port</" "$datadir"config.xml
systemctl restart -q $app

echo -e "${app^} installation and service start up is complete!"
echo -e "Attempting to check for a connection at http://$IP_LOCAL:$app_port..."

sleep 15

STATUS="$(systemctl is-active "$app")"
if [ "${STATUS}" = "active" ]; then
    echo "Setting more sensible quality values"
    QUALITIES=$(curl -s -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X GET "http://$IP_LOCAL:$SONARR_PORT/api/v3/qualitydefinition")

    QUALITY_MAP='{"Unknown":{"minSize":1,"maxSize":25,"preferredSize":20},"SDTV":{"minSize":2,"maxSize":25,"preferredSize":20},"WEBRip-480p":{"minSize":2,"maxSize":25,"preferredSize":20},"WEBDL-480p":{"minSize":2,"maxSize":25,"preferredSize":20},"DVD":{"minSize":2,"maxSize":25,"preferredSize":20},"Bluray-480p":{"minSize":2,"maxSize":25,"preferredSize":20},"HDTV-720p":{"minSize":3,"maxSize":30,"preferredSize":20},"HDTV-1080p":{"minSize":4,"maxSize":35,"preferredSize":20},"Raw-HD":{"minSize":4,"maxSize":35,"preferredSize":20},"WEBRip-720p":{"minSize":3,"maxSize":30,"preferredSize":20},"WEBDL-720p":{"minSize":3,"maxSize":30,"preferredSize":20},"Bluray-720p":{"minSize":4,"maxSize":30,"preferredSize":20},"WEBRip-1080p":{"minSize":4,"maxSize":35,"preferredSize":20},"WEBDL-1080p":{"minSize":4,"maxSize":35,"preferredSize":20},"Bluray-1080p":{"minSize":4,"maxSize":35,"preferredSize":20},"Bluray-1080p Remux":{"minSize":0,"maxSize":35,"preferredSize":20},"HDTV-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"WEBRip-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"WEBDL-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"Bluray-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"Bluray-2160p Remux":{"minSize":35,"maxSize":50,"preferredSize":35}}'
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

        curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$SONARR_PORT/api/v3/qualitydefinition" --data "${QUALITY}"
    done

    echo "Setting Permissions"
    curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$SONARR_PORT/api/v3/config/mediamanagement"  --data '{"autoUnmonitorPreviouslyDownloadedEpisodes":false,"recycleBin":"","recycleBinCleanupDays":7,"downloadPropersAndRepacks":"preferAndUpgrade","createEmptySeriesFolders":false,"deleteEmptyFolders":true,"fileDate":"none","rescanAfterRefresh":"always","setPermissionsLinux":true,"chmodFolder":"755","chownGroup":"'"$APP_GUID"'","episodeTitleRequired":"always","skipFreeSpaceCheckWhenImporting":false,"minimumFreeSpaceWhenImporting":100,"copyUsingHardlinks":true,"useScriptImport":false,"scriptImportPath":"","importExtraFiles":true,"extraFileExtensions":"srt","enableMediaInfo":true,"id":1}'

    echo "Setting Naming Conventions"
    curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$SONARR_PORT/api/v3/config/naming"  --data '{"renameEpisodes":true,"replaceIllegalCharacters":true,"colonReplacementFormat":4,"customColonReplacementFormat":"","multiEpisodeStyle":5,"standardEpisodeFormat":"{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}","dailyEpisodeFormat":"{Series Title} - {Air-Date} - {Episode Title} {Quality Full}","animeEpisodeFormat":"{Series Title} - {absolute:000} - {Episode Title} {Quality Full}","seriesFolderFormat":"{Series Title}","seasonFolderFormat":"Season {season}","specialsFolderFormat":"Specials","id":1}'

    SONARR_URL="http://$IP_LOCAL:$app_port"
    echo "Browse to $SONARR_URL for the ${app^} GUI"
else
    echo "${app^} failed to start"
fi

rm -f "${app^}".*.tar.gz
echo "Installled Sonarr"