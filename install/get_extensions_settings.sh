#!/bin/bash

if [ "$EUID" -lt 0 ]
  then echo "Please DO NOT run as root"
  exit
fi

echo "Getting current settings"

NEW_LINE=1
dconf dump /org/gnome/ | while read -r line; do

if [[ $line == "" ]] ; then
    NEW_LINE=1
else
    if [[ "$NEW_LINE" -eq 1 ]] ; then
        if [[ $line == "[shell"* ]] || [[ $line == "[desktop"* ]] ; then
            if [[ $line != "[desktop/app-folders"* ]] && [[ $line != "[desktop/input-sources"* ]] ; then
                if test -f "temp.txt"; then
                    echo "" >> temp.txt
                    echo ""
                fi

                echo $line >> temp.txt
                echo $line
                NEW_LINE=0
            fi
        fi
    else
        echo $line
        echo $line >> temp.txt
    fi
fi
done

EXTENSION_SETTINGS=$(cat temp.txt | gzip | base64 -w0)

rm temp.txt

echo ""
echo "Done"
echo ""
echo "Paste the line below in the installation script next to EXTENSION_SETTINGS="
echo ""
echo "$EXTENSION_SETTINGS"
echo ""