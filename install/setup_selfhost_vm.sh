#!/bin/bash
source "secrets.sh"

ZT_TOKEN=$ZT_TOKEN	 	              
NWID=$NWID
DUCK_DNS_KEY=$DUCK_DNS_KEY
KUMA_USER=$KUMA_USER
KUMA_PASS=$KUMA_PASS
KUMA_PORT=8080
SIGNAL_PORT=8079

apt update
apt upgrade -y
apt install git pipx curl python3-pip pipx python3-dev jq build-essential openssh-server htop net-tools bmon software-properties-common ca-certificates -y

#DuckDNS
echo "-----------------------------Installing DuckDNS-----------------------------"
mkdir duckdns
mkdir /var/log/duckdns
cd duckdns

cat <<EOF | tee ./duck.sh >/dev/null
    echo url="https://www.duckdns.org/update?domains=oriondev&token=$DUCK_DNS_KEY&ip=" | curl -k -o /var/log/duckdns/duck.log -K -
EOF

chmod 700 duck.sh
(crontab -l 2>/dev/null; echo "*/5 * * * * $PWD/duckdns/duck.sh >/dev/null 2>&1") | crontab -
./duck.sh
cd ..

#Zerotier Setup
echo "-----------------------------Installing Zerotier-----------------------------"

curl -s https://install.zerotier.com | bash
zerotier-cli join $NWID

MEMBER_ID=$(zerotier-cli info | cut -d " " -f 3)

curl -H "Authorization: token $ZT_TOKEN" -X POST "https://api.zerotier.com/api/v1/network/$NWID/member/$MEMBER_ID" --data '{"config": {"authorized": true}, "name": "'"${HOSTNAME}"'"}'

#Uptime Kuma
echo "-----------------------------Installing Uptime Kuma-----------------------------"

LATEST_VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/nvm-sh/nvm/releases | jq -r '.[0].tag_name')
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$LATEST_VERSION/install.sh | bash

NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 20
npm install pm2 -g

CUR_DIR=$PWD
cd /opt
rm -r ./uptime-kuma

git clone https://github.com/louislam/uptime-kuma.git
cd uptime-kuma
npm run setup
npm install pm2 -g && pm2 install pm2-logrotate
pm2 unstartup
pm2 stop all
pm2 start server/server.js --name uptime-kuma -- --host=0.0.0.0 --port=$KUMA_PORT
pm2 save && pm2 startup

python3 -m venv .
source bin/activate
pip3 install uptime-kuma-api

echo "from uptime_kuma_api import UptimeKumaApi, MonitorType" > init.py
echo "api = UptimeKumaApi(\"http://localhost:$KUMA_PORT\")" >> init.py
echo "try:" >> init.py
echo "  api.setup(\"$KUMA_USER\", \"$KUMA_PASS\")" >> init.py
echo "  api.login(\"$KUMA_USER\", \"$KUMA_PASS\")" >> init.py
echo "  api.disconnect()" >> init.py
echo "except:" >> init.py
echo "  pass" >> init.py

echo "Configuring Monitors"
python3 ./init.py
rm ./init.py

cd $CUR_DIR
KUMA_URL="http://$IP_LOCAL:$KUMA_PORT"
echo "Installed Uptime Kuma"

#Signal CLI
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

mkdir -p $HOME/.local/share/signal-api
docker run -d --name signal-api --restart=always -p $SIGNAL_PORT:8080 -v $HOME/.local/share/signal-api:/home/.local/share/signal-cli -e 'MODE=native' bbernhard/signal-cli-rest-api

#Rust Desk
wget https://raw.githubusercontent.com/techahold/rustdeskinstall/master/install.sh
chmod +x install.sh
./install.sh

echo "Public Key: "
echo ""
cat ./id_ed25519.pub
echo ""