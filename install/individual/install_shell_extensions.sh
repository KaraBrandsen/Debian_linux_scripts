#!/bin/bash

#Get the settings string by running the get_extension_settings.sh script on your current PC before reformatting.
EXTENSION_SETTINGS='default'

#List of shell extensions to install. Get from: https://extensions.gnome.org
EXTENSION_LIST=( https://extensions.gnome.org/extension/1160/dash-to-panel/
 https://extensions.gnome.org/extension/1460/vitals/
 https://extensions.gnome.org/extension/3628/arcmenu/
 https://extensions.gnome.org/extension/1319/gsconnect/
 https://extensions.gnome.org/extension/3843/just-perfection/)


echo "-----------------------------Installing Shell Extensions-----------------------------"
apt install gnome-menus dbus-x11 -y

for i in "${EXTENSION_LIST[@]}" ; do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    SEARCH_ID=$(echo $EXTENSION_ID | cut -d '@' -f 1)
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$SEARCH_ID" | jq '.extensions | map(select(.uuid=="'$EXTENSION_ID'")) | .[0].shell_version_map."'$GNOME_VERSION'".pk')

    echo "Installing: $EXTENSION_ID"

    wget --inet4-only -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    sudo -u $SUDO_USER -H -s gnome-extensions install --force ${EXTENSION_ID}.zip
    sudo -u $SUDO_USER -H -s gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done

if [ "$EXTENSION_SETTINGS" == "default" ] ; then
    echo "No extension settings configured"
else
    echo "Loading extension settings"
    echo $EXTENSION_SETTINGS | base64 -d | gunzip >> /home/$SUDO_USER/extension_settings.conf

    sudo  -i -u $SUDO_USER bash <<-EOF
    cat /home/$SUDO_USER/extension_settings.conf | dconf load /org/gnome/
EOF

    rm /home/$SUDO_USER/extension_settings.conf
fi

echo "Installled Shell Extensions"