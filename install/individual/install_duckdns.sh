#!/bin/bash

DUCK_DNS_KEY=$DUCK_DNS_KEY

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