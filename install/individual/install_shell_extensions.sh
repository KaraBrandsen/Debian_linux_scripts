#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Variables
    #Get the settings string by running the get_extension_settings.sh script on your current PC before reformatting.
    EXTENSION_SETTINGS='H4sIAAAAAAAAA+VWS2/jOAy++1cUuXgXqOIk7XSaAgb6mkOx7TToFgssiqBQJNrWRJYMic5jiv73pRwnTV+LorO3vSQ2yY8SyY+k7yT4KdoqqcCpqgDHtU9KW3sYR4ZjTe/MC2e1TjNSQRTdvYVAW4ui4vIdEM4ty5TJwbVyemZg+ESDTNHVz9w6NeNiOY4cVNYhQxCFUYJcVs4SoPQvEQ5Ki8A2r7IaRyvnK0vUnglwmMZJYUtIptzxpKst+Ux8wR0kuSE5e+2HEbQrHMaNjyksP+mCkPH7F54ZMY54jQUrAQsr07ji3s+tk/GzOJ4cePBeWTOOlNTBj+bLtFYG9wY7w16PDD0gUo49k5zOMkml61wZn1R2Dm4NU2VbHq8BKqYMF6hmwLhgqEqwNaZ7B+TuDfWygjQ2Fgs6JETmC9B6HEnlw3UZ0ccxWCCYcE3fHtNq5bbmLq4ntcGaSSumx6vnrrBlvC7hC2vuRAmmPm7/G9PdnVhyXzC0rOIG9PEPCc56GHZzhUU9WRvlXlhjQOAxN3JZWF2CX5soGyx+1B4Z8TojIzpwXaHjF/Jg+pdCCur4zDo4s5LS0N464zPrFFWXV1W4MEm7ubW5hu5Z4Ygj3dZpcGJd3m2I0/1O9Ve69m9rb8GVlH+9rcVZt9Kw6I7o53wl3qjH0Ry0CISUimubM80pAF/YuWEzcCGZabx/0O1tapc8ZTlpc0vlhIzXGll4YzMF8zQ+0fp+5GzueOnjqFFMakTKFcUL1BVGEDMuKNFxVDnIPOG8CpyoeA5pj7pagEG9JD55ymAocJspb3jFPFJC71tOeJvhnJprKy5PZ4iCZge6JZtQixDRHJeq9ulvoUl2dwZffo9CpA1vHCWNqjhTAjZj41W8z8hDnWhUyVcFVBQHKyyljK2kgRQNEtOH+OZiNLr8Fh/t7FM5Rpcn3/9on/+8uFop+o/R2kvJHXVgur8R0LQMtAmSGVe66RtqVUUJoGz0KPuWOGe9wqZap9e3t9dXcVRYpGniWbgUtT2jKk9sGt9+uxpd35zcXFz+HUcaMpzYxeYI1o+a2CgIUQT38UOn1znqXF2cn19+6zzGrRpoulJom1PXhncPnVZFoJDbE6rYaVP2zm6nLXDnqOny3c4aHWyRiynI28vO4+62j2aSkBH8kpcQ5qldbIMbCnwEi9xPJ9x9ChsIDO6DJ5/evEA7lRcfvfYrsF96hPKK2u5TcEm8/jx41YSvK/ZvHsYbcmkwORZrSvV7vY3Gq5+wlu8NgthRr1F/t+1AU4M8Yu3Zs8YhVqOjDth6nysjqfNp8IRpRVsMw+DZ9NDt9ejNgRfg40gUIKZs0e/P+VLThnh3XrzYBoSkD4HpakpuDuu9JWU2y2g1k/J/uQszRRvBLu7b//9kE45bErVbqCVDwylK86+swVkTFflfF0+ZVU5pZDcLZsKR5sByxZNGknGz/qQKrzOrMWy9lkjY3j3RkNMXLn3p2kxp8EfJ0aQvhRhKyb4MDgZsXx7SVjw82GPicPgVDuTw63AyfNrHITga/LouiQf9Qe+5wtm5pw+36B8kf6MK2wsAAA=='
            
            #List of shell extensions to install. Get from: https://extensions.gnome.org
    EXTENSION_LIST=( https://extensions.gnome.org/extension/1160/dash-to-panel/
        https://extensions.gnome.org/extension/1460/vitals/
        https://extensions.gnome.org/extension/3628/arcmenu/
        https://extensions.gnome.org/extension/1319/gsconnect/
        https://extensions.gnome.org/extension/3843/just-perfection/)
fi


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