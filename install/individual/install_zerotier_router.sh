#!/bin/bash
source "../secrets.sh"

ZT_TOKEN=$ZT_TOKEN                                      #Your Zerotier API Token - Get this from https://my.zerotier.com/account -> "new token"
NWID=$NWID                                              #Your Zerotier Network ID - Get this from https://my.zerotier.com/

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Variables
    SET_AS_EXIT_NODE=false                                  #Use this instance as an exit node for internet traffic. Recommend only 1 exit node per Zerotier network
    VIA_IP=$(curl -s -H "Authorization: token $ZT_TOKEN" -X GET "https://api.zerotier.com/api/v1/network/$NWID/member/$MEMBER_ID" | jq '.config.ipAssignments[0]' | cut -d '"' -f2)
    ZT_IFACE=$(ifconfig | grep zt* | cut -d ":" -f 1 | head --lines 1)

    #Common Scripts
    source "../common/common_variables.sh"
fi


echo "-----------------------------Installing Zerotier Router-----------------------------"

apt-get -y install iptables iptables-persistent

if [ "$PHY_IFACE" == "default" ] ; then
    PHY_IFACE=$(ifconfig | grep -E 'eth|enp|end' | cut -d ":" -f 1 | cut -d " " -f 1 | xargs)
    echo "Detected Ethernet Connection: $PHY_IFACE"
fi

echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT

LOCAL_IP="$(ifconfig $PHY_IFACE | grep "inet " | xargs | cut -d " " -f 2)"
NET_MASK="$(ifconfig $PHY_IFACE | grep "inet " | xargs | cut -d " " -f 4)"
TARGET_RANGE="$(ifconfig $PHY_IFACE | grep "inet " | xargs | cut -d " " -f 2 | cut -d "." -f 1,2,3).0"

echo "Detected Local IP: $LOCAL_IP with Netmask: $NET_MASK"

if [ "$SET_AS_EXIT_NODE" == "true" ] ; then
    NEW_ROUTES="$(curl -s -H "Authorization: token $ZT_TOKEN" -X GET "https://api.zerotier.com/api/v1/network/$NWID" | jq '.config.routes' | cut -d ']' -f1), {\"target\":\"${TARGET_RANGE}/23\", \"via\":\"${VIA_IP}\"}, {\"target\":\"0.0.0.0/0\", \"via\":\"${VIA_IP}\"}]"
else
    NEW_ROUTES="$(curl -s -H "Authorization: token $ZT_TOKEN" -X GET "https://api.zerotier.com/api/v1/network/$NWID" | jq '.config.routes' | cut -d ']' -f1), {\"target\":\"${TARGET_RANGE}/23\", \"via\":\"${VIA_IP}\"}]"
fi

echo "Configuring new routes:"
echo $NEW_ROUTES | jq '.'

if [ "$INSTALL_PIHOLE" == "true" ] ; then
    NEW_DNS="$(curl -s -H "Authorization: token $ZT_TOKEN" -X GET "https://api.zerotier.com/api/v1/network/$NWID" | jq '.config.dns.servers' | cut -d ']' -f1), \"${VIA_IP}\"]"
    echo "Configuring new DNS servers:"
    echo $NEW_DNS | jq '.'
    
    curl -s -o /dev/null -H "Authorization: token $ZT_TOKEN" -X POST "https://api.zerotier.com/api/v1/network/$NWID" --data '{"config": {"routes": '"$NEW_ROUTES"', "dns":{"domain": "'"$HOSTNAME"'.local", "servers" :'"$NEW_DNS"'}}}'
else
    curl -s -o /dev/null -H "Authorization: token $ZT_TOKEN" -X POST "https://api.zerotier.com/api/v1/network/$NWID" --data '{"config": {"routes": '"$NEW_ROUTES"'}}'
fi

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

bash -c iptables-save > /etc/iptables/rules.v4

echo "Installled Zerotier Router"