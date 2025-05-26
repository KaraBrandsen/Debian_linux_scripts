#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"
    
    #Variables
    STIRLING_PDF_PORT=8101                                       #Port Stirling PDF should be served on

    #Common Scripts
    source "../common/common_variables.sh"
fi


echo "-----------------------------Installing Stirling PDF-----------------------------"

mkdir -p $DOCKER_DIR/config/StirlingPDF/

if [ ! -f "$DOCKER_DIR/docker-compose.yaml" ]; then
    echo "No Docker compose file found. Creating on now"

    cat <<EOF | tee "$DOCKER_DIR/docker-compose.yaml" >/dev/null
services:
  stirling-pdf:
    container_name: Stirling-PDF
    image: docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest
    restart: unless-stopped
    ports:
      - '$STIRLING_PDF_PORT:8080'
    volumes:
      - $DOCKER_DIR/config/StirlingPDF/trainingData:/usr/share/tessdata # Required for extra OCR languages
      - $DOCKER_DIR/config/StirlingPDF/extraConfigs:/configs
      - $DOCKER_DIR/config/StirlingPDF/customFiles:/customFiles/
      - $DOCKER_DIR/config/StirlingPDF/logs:/logs/
      - $DOCKER_DIR/config/StirlingPDF/pipeline:/pipeline/
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - LANGS=en_GB

EOF
else
    echo "Existing Docker compose file found. appending new services"

    if grep -F "stirling-pdf" $DOCKER_DIR/docker-compose.yaml ; then
        echo "Existing service found. Skipping appending."
    else

    cat <<EOF | tee -a "$DOCKER_DIR/docker-compose.yaml" >/dev/null
  stirling-pdf:
    container_name: Stirling-PDF
    image: docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest
    restart: unless-stopped
    ports:
      - '$STIRLING_PDF_PORT:8080'
    volumes:
      - $DOCKER_DIR/config/StirlingPDF/trainingData:/usr/share/tessdata # Required for extra OCR languages
      - $DOCKER_DIR/config/StirlingPDF/extraConfigs:/configs
      - $DOCKER_DIR/config/StirlingPDF/customFiles:/customFiles/
      - $DOCKER_DIR/config/StirlingPDF/logs:/logs/
      - $DOCKER_DIR/config/StirlingPDF/pipeline:/pipeline/
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - LANGS=en_GB

EOF
    fi
fi

docker compose up -d stirling-pdf