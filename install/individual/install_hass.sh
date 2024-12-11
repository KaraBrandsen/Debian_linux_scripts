#!/bin/bash

echo "-----------------------------Installing Home Assistant-----------------------------"

add-apt-repository ppa:mosquitto-dev/mosquitto-ppa -y
apt install -y python3 python3-dev python3-venv python3-pip bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata ffmpeg liblapack3 liblapack-dev libatlas-base-dev mosquitto mosquitto-clients

useradd -r -m homeassistant

mkdir /srv/homeassistant
chmod 777 -R /srv/homeassistant

echo '#!/bin/bash' > /srv/homeassistant/Install_HAS.sh
echo cd /srv/homeassistant >> /srv/homeassistant/Install_HAS.sh
echo python3 -m venv . >> /srv/homeassistant/Install_HAS.sh
echo source bin/activate >> /srv/homeassistant/Install_HAS.sh
echo python3 -m pip install wheel >> /srv/homeassistant/Install_HAS.sh
echo pip3 install homeassistant >> /srv/homeassistant/Install_HAS.sh
echo mkdir -p /home/homeassistant/.homeassistant >> /srv/homeassistant/Install_HAS.sh

chown -R homeassistant:homeassistant /srv/homeassistant 
chmod +x /srv/homeassistant/Install_HAS.sh

sudo -u homeassistant -H -s /srv/homeassistant/Install_HAS.sh 

echo [Unit] > /etc/systemd/system/home-assistant.service
echo Description=Home Assistant >> /etc/systemd/system/home-assistant.service
echo After=network-online.target >> /etc/systemd/system/home-assistant.service
echo " " >> /etc/systemd/system/home-assistant.service
echo [Service] >> /etc/systemd/system/home-assistant.service
echo Type=simple >> /etc/systemd/system/home-assistant.service
echo User=homeassistant >> /etc/systemd/system/home-assistant.service
echo WorkingDirectory=/home/homeassistant/.homeassistant >> /etc/systemd/system/home-assistant.service
echo ExecStart=/srv/homeassistant/bin/hass -c "/home/homeassistant/.homeassistant" >> /etc/systemd/system/home-assistant.service
echo Environment="PATH=/srv/homeassistant/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/homeassistant/.local/bin" >>  /etc/systemd/system/home-assistant.service
echo RestartForceExitStatus=100 >> /etc/systemd/system/home-assistant.service
echo " " >> /etc/systemd/system/home-assistant.service
echo [Install] >> /etc/systemd/system/home-assistant.service
echo WantedBy=multi-user.target >> /etc/systemd/system/home-assistant.service

echo " " >> /etc/mosquitto/mosquitto.conf
echo "listener 8888" >> /etc/mosquitto/mosquitto.conf
echo "allow_anonymous true" >> /etc/mosquitto/mosquitto.conf

systemctl --system daemon-reload
systemctl enable home-assistant
systemctl start home-assistant
systemctl restart mosquitto

echo "Installled Home Assistant"