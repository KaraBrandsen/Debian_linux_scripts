#!/bin/bash

APP_UID=$SUDO_USER
APP_GUID=users
HOST=$(hostname -I)
IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")

if [ "$INSTALL_SHELL_EXTENSIONS" == "true" ] ; then
    if ! command -v gnome-shell 2>&1 >/dev/null ; then
        echo "Gnome Shell could not be found. Not installing shell extensions."
        INSTALL_SHELL_EXTENSIONS=false
    else
        GNOME_VERSION=$(gnome-shell --version | cut -d ' ' -f 3 | cut -d '.' -f 1)
    fi
fi