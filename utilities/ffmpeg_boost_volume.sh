#!/bin/bash

#Boosts the Volume of files in SOURCE_DIR

SOURCE_DIR="/mnt/nas/"

find "$SOURCE_DIR" -maxdepth 2 -mindepth 1 -type f -exec sh -c '
    target="$1"
    folder=$(dirname "$target")
    file=$(echo $target | rev | cut -d '/' -f 1 | rev)
    mkdir "$folder/processed"

    ffmpeg -i "$folder/$file" -vcodec copy -af "volume=10dB" "$folder/processed/$file"
' find-sh {} \;
