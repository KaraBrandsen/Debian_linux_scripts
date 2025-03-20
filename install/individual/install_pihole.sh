#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Variables
    PHY_IFACE=default                                       #The physical interface to bind services to. Default auto detects 
    DNS_1=8.8.8.8                                           #DNS Server used by your ISP - Get this from ifconfig/connection properties on any PC or from your router. Leave as is to use Google's DNS server
    DNS_2=8.8.4.4                                           #DNS Server used by your ISP - Get this from ifconfig/connection properties on any PC or from your router. Leave as is to use Google's DNS server
    DNS_3=2001:4860:4860::8888                              #DNS Server used by your ISP - Leave as is if the ISP has not IPV6 DNS
    DNS_4=2001:4860:4860::8844                              #DNS Server used by your ISP - Leave as is if the ISP has not IPV6 DNS
    
    #Common Scripts
    source "../common/disable_ip_v6.sh"
fi

echo "-----------------------------Installing PiHole-----------------------------"

if [ "$PHY_IFACE" == "default" ] ; then
    PHY_IFACE=$(ifconfig | grep -E 'eth|enp|end' | cut -d ":" -f 1 | cut -d " " -f 1 | xargs)
    echo "Detected Ethernet Connection: $PHY_IFACE"
fi

mkdir /etc/pihole

echo PIHOLE_INTERFACE=$PHY_IFACE > /etc/pihole/setupVars.conf
echo PIHOLE_DNS_1=$DNS_1 >> /etc/pihole/setupVars.conf
echo PIHOLE_DNS_2=$DNS_2 >> /etc/pihole/setupVars.conf
echo PIHOLE_DNS_3=$DNS_3 >> /etc/pihole/setupVars.conf
echo PIHOLE_DNS_4=$DNS_4 >> /etc/pihole/setupVars.conf
echo QUERY_LOGGING=true >> /etc/pihole/setupVars.conf
echo INSTALL_WEB_SERVER=true >> /etc/pihole/setupVars.conf
echo INSTALL_WEB_INTERFACE=true >> /etc/pihole/setupVars.conf
echo LIGHTTPD_ENABLED=true >> /etc/pihole/setupVars.conf
echo CACHE_SIZE=10000 >> /etc/pihole/setupVars.conf
echo DNS_FQDN_REQUIRED=true >> /etc/pihole/setupVars.conf
echo DNS_BOGUS_PRIV=true >> /etc/pihole/setupVars.conf
echo DNSMASQ_LISTENING=local >> /etc/pihole/setupVars.conf
echo WEBPASSWORD=dfc3c40f4febab4fca7f76a6936def7c3b6e82397e231ba65e55531c92f7dbff >> /etc/pihole/setupVars.conf
echo BLOCKING_ENABLED=true >> /etc/pihole/setupVars.conf
echo WEBUIBOXEDLAYOUT=boxed >> /etc/pihole/setupVars.conf
echo WEBTHEME=default-dark >> /etc/pihole/setupVars.conf

curl -L https://install.pi-hole.net | bash /dev/stdin --unattended

#Fix for Pihole installer bug
chown -R www-data:www-data /var/log/lighttpd/
service lighttpd restart

echo "Installed PiHole"