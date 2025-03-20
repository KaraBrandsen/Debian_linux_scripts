#!/bin/bash
source "../secrets.sh"

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Common Scripts
    source "../common/common_variables.sh"
fi

#Variables
ZT_TOKEN=$ZT_TOKEN                                      #Your Zerotier API Token - Get this from https://my.zerotier.com/account -> "new token"
NWID=$NWID                                              #Your Zerotier Network ID - Get this from https://my.zerotier.com/


echo "-----------------------------Installing Zerotier-----------------------------"

curl -s https://install.zerotier.com | bash
zerotier-cli join $NWID

MEMBER_ID=$(zerotier-cli info | cut -d " " -f 3)
echo "Joined network: $NWID with member_id: $MEMBER_ID"

curl -s -o /dev/null -H "Authorization: token $ZT_TOKEN" -X POST "https://api.zerotier.com/api/v1/network/$NWID/member/$MEMBER_ID" --data '{"config": {"authorized": true}, "name": "'"${HOST}"'"}'

sleep 5
VIA_IP=$(curl -s -H "Authorization: token $ZT_TOKEN" -X GET "https://api.zerotier.com/api/v1/network/$NWID/member/$MEMBER_ID" | jq '.config.ipAssignments[0]' | cut -d '"' -f2)
ZT_IFACE=$(ifconfig | grep zt* | cut -d ":" -f 1 | head --lines 1)

echo "Authorized Zerotier Interface: $ZT_IFACE with IP: $VIA_IP"
echo "Installled Zerotier"