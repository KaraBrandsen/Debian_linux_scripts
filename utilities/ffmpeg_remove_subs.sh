#!/bin/bash

#Extracts the wanted subtitle from the files in the SOURCE_DIR

#Check for Sub stream with:
#ffprobe -v quiet -print_format json -show_format -show_streams -pretty -i file_name

SOURCE_DIR="/mnt/nas/"
SUB_NAME="Dialogue (PGS)"

mkdir "$SOURCE_DIR/processed"

find "$SOURCE_DIR" -maxdepth 1 -mindepth 1 -type f -execdir ffmpeg -i "$SOURCE_DIR/{}" -c copy -map 0:v -map 0:a -map 0:s:m:title:"$SUB_NAME" "$SOURCE_DIR/processed/{}" ';'
