#!/bin/bash

# This script is intended to trick plex into scanning for new media and generating intro and credit markers.
# Often if plex is processing a large number of files the generation of various markers gets interrupted but
# Plex does not automatically resume after starting up again. This script fixes that issue.

MEDIA_DIR="/mnt/nas/Series"

find "$SOURCE_DIR" -type f -exec touch -m -c {} +