#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Variables
    STIRLING_PDF_PORT=8101                                       #Port Stirling PDF should be served on
fi


echo "-----------------------------Installing Stirling PDF-----------------------------"

if [ ! -f "/home/$SUDO_USER/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "/home/$SUDO_USER/docker-compose.yaml" >/dev/null
services:
  stirling-pdf:
    container_name: Stirling-PDF
    image: docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest
    restart: unless-stopped
    ports:
      - '$STIRLING_PDF_PORT:8080'
    volumes:
      - ./StirlingPDF/trainingData:/usr/share/tessdata # Required for extra OCR languages
      - ./StirlingPDF/extraConfigs:/configs
      - ./StirlingPDF/customFiles:/customFiles/
      - ./StirlingPDF/logs:/logs/
      - ./StirlingPDF/pipeline:/pipeline/
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - LANGS=en_GB

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "stirling-pdf" /home/$SUDO_USER/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "/home/$SUDO_USER/docker-compose.yaml" >/dev/null
  stirling-pdf:
    container_name: Stirling-PDF
    image: docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest
    restart: unless-stopped
    ports:
      - '$STIRLING_PDF_PORT:8080'
    volumes:
      - ./StirlingPDF/trainingData:/usr/share/tessdata # Required for extra OCR languages
      - ./StirlingPDF/extraConfigs:/configs
      - ./StirlingPDF/customFiles:/customFiles/
      - ./StirlingPDF/logs:/logs/
      - ./StirlingPDF/pipeline:/pipeline/
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - LANGS=en_GB

EOF
    fi
fi

docker compose up -d