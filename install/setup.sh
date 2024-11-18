#!/bin/bash
source "secrets.sh"

#You will need to run the following to make the script executable
#sudo chmod +x setup.sh
#Then run one of the following
#sudo ./setup.sh 
#sudo ./setup.sh desktop
#sudo ./setup.sh media
#sudo ./setup.sh nas
#sudo ./setup.sh pihole

#Variables
    #Zerotier
        ZT_TOKEN=$ZT_TOKEN                                      #Your Zerotier API Token - Get this from https://my.zerotier.com/account -> "new token"
        NWID=$NWID                                              #Your Zerotier Network ID - Get this from https://my.zerotier.com/
        SET_AS_EXIT_NODE=false                                  #Use this instance as an exit node for internet traffic. Recommend only 1 exit node per Zerotier network
        PHY_IFACE=default                                       #The physical interface to bind services to. Default auto detects 
    
    #MergerFS
        HDD_IDS=()                                              #The IDs of the HDD's you wan to add to the pool - Get from: ls -l /dev/disk/by-id
        MERGERFS_DIR="default"                                  #The directory name where the merged folder should be mounted
        READ_ONLY_SHARES=no                                     #Should the shared folder be read-only
        REMOTE_USER=$SAMBA_USER                                 #User to use for the SAMBA share. You will connect with this user.
        REMOTE_PASS=$SAMBA_PASS                                 #The above user's password.
    
    #SABNZBd
        SABNZBD_PORT=8081                                       #Port SABNZBD should be served on
        SERVERS=$SERVERS                                        #News server details in JSON format. Can be multiple servers.

    #Deluge
        DELUGE_PASSWORD="deluge"                                #Password for Deluge web UI
        DELUGE_PORT=8082                                        #Deluge web UI port
        
    #Sonarr
        SONARR_PORT=8083                                        #Port Sonarr should be served on
        SONARR_ROOT_FOLDER=("/mnt/nas/Series")                  #Folders to where you want to store series (Can already contain a few)
        INDEXERS=$INDEXERS                                      #Indexer details in JSON format. Can be multiple indexers.
        
    #Radarr
        RADARR_PORT=8084                                        #Port Radarr should be served on
        RADARR_ROOT_FOLDER=("/mnt/nas/Movies")                  #Folders to where you want to store movies (Can already contain a few)

    #Shares
        WIN_HOST=$WIN_HOST                                      #IP address of the windows host 
        WIN_SHARES=$WIN_SHARES                                  #An array of the shared folders
        WIN_USER=$WIN_USER                                      #Username used to access the windows shares
        WIN_PASS=$WIN_PASS                                      #Password used to access the windows shares

    #Pihole
        DNS_1=8.8.8.8                                           #DNS Server used by your ISP - Get this from ifconfig/connection properties on any PC or from your router. Leave as is to use Google's DNS server
        DNS_2=8.8.4.4                                           #DNS Server used by your ISP - Get this from ifconfig/connection properties on any PC or from your router. Leave as is to use Google's DNS server
        DNS_3=2001:4860:4860::8888                              #DNS Server used by your ISP - Leave as is if the ISP has not IPV6 DNS
        DNS_4=2001:4860:4860::8844                              #DNS Server used by your ISP - Leave as is if the ISP has not IPV6 DNS

    #Libre Speed Test
        LIBREST_PORT=8090                                       #Port used by Libre Speed Test

    #Uptime Kuma
        KUMA_USER=$KUMA_USER                                    #Username to be used for the Uptime Kuma Web Interface
        KUMA_PASS=$KUMA_PASS                                    #Password to be used for the Uptime Kuma Web Interface
        KUMA_PORT=8080                                          #Port to be used for the Uptime Kuma Web Interface

    #Rustdesk
        RUSTDESK_PASS=$RUSTDESK_PASS                            #Rustdesk Client Password. Used to log into a device
        RUSTDESK_CFG=$RUSTDESK_CFG                              #Config string from and existing Rustdesk client. https://rustdesk.com/docs/en/self-host/client-configuration/#setup-using-import-or-export    

    #Shell Extensions
        #Get the settings string by running the get_extension_settings.sh script on your current PC before reformatting.
        EXTENSION_SETTINGS='H4sIAAAAAAAAA+VWS2/jOAy++1cUuXgXqOIk7XSaAgb6mkOx7TToFgssiqBQJNrWRJYMic5jiv73pRwnTV+LorO3vSQ2yY8SyY+k7yT4KdoqqcCpqgDHtU9KW3sYR4ZjTe/MC2e1TjNSQRTdvYVAW4ui4vIdEM4ty5TJwbVyemZg+ESDTNHVz9w6NeNiOY4cVNYhQxCFUYJcVs4SoPQvEQ5Ki8A2r7IaRyvnK0vUnglwmMZJYUtIptzxpKst+Ux8wR0kuSE5e+2HEbQrHMaNjyksP+mCkPH7F54ZMY54jQUrAQsr07ji3s+tk/GzOJ4cePBeWTOOlNTBj+bLtFYG9wY7w16PDD0gUo49k5zOMkml61wZn1R2Dm4NU2VbHq8BKqYMF6hmwLhgqEqwNaZ7B+TuDfWygjQ2Fgs6JETmC9B6HEnlw3UZ0ccxWCCYcE3fHtNq5bbmLq4ntcGaSSumx6vnrrBlvC7hC2vuRAmmPm7/G9PdnVhyXzC0rOIG9PEPCc56GHZzhUU9WRvlXlhjQOAxN3JZWF2CX5soGyx+1B4Z8TojIzpwXaHjF/Jg+pdCCur4zDo4s5LS0N464zPrFFWXV1W4MEm7ubW5hu5Z4Ygj3dZpcGJd3m2I0/1O9Ve69m9rb8GVlH+9rcVZt9Kw6I7o53wl3qjH0Ry0CISUimubM80pAF/YuWEzcCGZabx/0O1tapc8ZTlpc0vlhIzXGll4YzMF8zQ+0fp+5GzueOnjqFFMakTKFcUL1BVGEDMuKNFxVDnIPOG8CpyoeA5pj7pagEG9JD55ymAocJspb3jFPFJC71tOeJvhnJprKy5PZ4iCZge6JZtQixDRHJeq9ulvoUl2dwZffo9CpA1vHCWNqjhTAjZj41W8z8hDnWhUyVcFVBQHKyyljK2kgRQNEtOH+OZiNLr8Fh/t7FM5Rpcn3/9on/+8uFop+o/R2kvJHXVgur8R0LQMtAmSGVe66RtqVUUJoGz0KPuWOGe9wqZap9e3t9dXcVRYpGniWbgUtT2jKk9sGt9+uxpd35zcXFz+HUcaMpzYxeYI1o+a2CgIUQT38UOn1znqXF2cn19+6zzGrRpoulJom1PXhncPnVZFoJDbE6rYaVP2zm6nLXDnqOny3c4aHWyRiynI28vO4+62j2aSkBH8kpcQ5qldbIMbCnwEi9xPJ9x9ChsIDO6DJ5/evEA7lRcfvfYrsF96hPKK2u5TcEm8/jx41YSvK/ZvHsYbcmkwORZrSvV7vY3Gq5+wlu8NgthRr1F/t+1AU4M8Yu3Zs8YhVqOjDth6nysjqfNp8IRpRVsMw+DZ9NDt9ejNgRfg40gUIKZs0e/P+VLThnh3XrzYBoSkD4HpakpuDuu9JWU2y2g1k/J/uQszRRvBLu7b//9kE45bErVbqCVDwylK86+swVkTFflfF0+ZVU5pZDcLZsKR5sByxZNGknGz/qQKrzOrMWy9lkjY3j3RkNMXLn3p2kxp8EfJ0aQvhRhKyb4MDgZsXx7SVjw82GPicPgVDuTw63AyfNrHITga/LouiQf9Qe+5wtm5pw+36B8kf6MK2wsAAA=='
        
        #List of shell extensions to install. Get from: https://extensions.gnome.org
        EXTENSION_LIST=( https://extensions.gnome.org/extension/1160/dash-to-panel/
 https://extensions.gnome.org/extension/1460/vitals/
 https://extensions.gnome.org/extension/3628/arcmenu/
 https://extensions.gnome.org/extension/1319/gsconnect/
 https://extensions.gnome.org/extension/3843/just-perfection/)


if [ "$EUID" -ne 0 ] ; then 
  echo "Please run as root"
  exit
fi

ARG=${1:-"desktop"}   

echo "---------------------------------------------------------------------------------"
echo "------------------------------Running $ARG setup------------------------------"
echo "---------------------------------------------------------------------------------"

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

add-apt-repository multiverse -y
add-apt-repository universe -y
apt update
apt upgrade -y
apt dist-upgrade -y

if [ "$ARG" == "nas" ]; then
    INSTALL_ZEROTIER=true                   #Install Zerotier - set to false to skip
    INSTALL_ZEROTIER_ROUTER=false           #Install Zerotier - set to false to skip
    INSTALL_PIHOLE=false                    #Install Pihole - set to false to skip
    INSTALL_HASS=false                      #Install Home Assistant - set to false to skip
    INSTALL_LIBRE_SPEEDTEST=false           #Install Libre Speedtest Server - set to false to skip
    INSTALL_FILE_SERVER=true                #Install MergerFS and SAMBA - set to false to skip
    INSTALL_SABNZBD=true                    #Install SABNZBD - set to false to skip
    INSTALL_DELUGE=true                     #Install Deluge - set to false to skip
    INSTALL_SONARR=true                     #Install Sonarr - set to false to skip
    INSTALL_RADARR=true                     #Install Radarr - set to false to skip
    INSTALL_PLEX_SERVER=true                #Install Plex Server- set to false to skip
    INSTALL_UPTIME_KUMA=false               #Install Uptime Kuma - set to false to skip
    INSTALL_SHARES=false                    #Install Windows Shares - set to false to skip
    INSTALL_SHELL_EXTENSIONS=false          #Install Shell Extensions - set to false to skip
    INSTALL_RUSTDESK_CLIENT=false           #Install Rustdesk Client - set to false to skip

    echo "Applying fix for inconsistent file system prompt"
    DEFAULT_CONFIG=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub)

    if [[ $DEFAULT_CONFIG == *"fsck.mode=force"* ]] || [ "$DEFAULT_CONFIG" == "" ]; then
        echo "No modification of Grub needed"
    else
        echo "Forcing Grub to disk check and repair if the system was not rebooted properly"
        NEW_CONFIG="${DEFAULT_CONFIG::-1}  fsck.mode=force  fsck.repair=yes\""
        sed -i "s/$DEFAULT_CONFIG/$NEW_CONFIG/" "/etc/default/grub"
        update-grub
    fi

    apt install sqlite3 -y
fi

if [ "$ARG" == "pihole" ]; then
    INSTALL_ZEROTIER=false                  #Install Zerotier - set to false to skip
    INSTALL_ZEROTIER_ROUTER=true            #Install Zerotier - set to false to skip
    INSTALL_PIHOLE=true                     #Install Pihole - set to false to skip
    INSTALL_HASS=true                       #Install Home Assistant - set to false to skip
    INSTALL_LIBRE_SPEEDTEST=true            #Install Libre Speedtest Server - set to false to skip
    INSTALL_FILE_SERVER=false               #Install MergerFS and SAMBA - set to false to skip
    INSTALL_SABNZBD=false                   #Install SABNZBD - set to false to skip
    INSTALL_DELUGE=false                    #Install Deluge - set to false to skip
    INSTALL_SONARR=false                    #Install Sonarr - set to false to skip
    INSTALL_RADARR=false                    #Install Radarr - set to false to skip
    INSTALL_PLEX_SERVER=false               #Install Plex Server- set to false to skip
    INSTALL_UPTIME_KUMA=false               #Install Uptime Kuma - set to false to skip                
    INSTALL_SHARES=false                    #Install Windows Shares - set to false to skip
    INSTALL_SHELL_EXTENSIONS=false          #Install Shell Extensions - set to false to skip
    INSTALL_RUSTDESK_CLIENT=false           #Install Rustdesk Client - set to false to skip

    echo "Applying fix for inconsistent file system prompt"
    DEFAULT_CONFIG=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub)

    if [[ $DEFAULT_CONFIG == *"fsck.mode=force"* ]] || [ "$DEFAULT_CONFIG" == "" ] ; then
        echo "No modification of Grub needed"
    else
        echo "Forcing Grub to disk check and repair if the system was not rebooted properly"
        NEW_CONFIG="${DEFAULT_CONFIG::-1}  fsck.mode=force  fsck.repair=yes\""
        sed -i "s/$DEFAULT_CONFIG/$NEW_CONFIG/" "/etc/default/grub"
        update-grub
    fi
fi

if [ "$ARG" == "desktop" ] || [ "$ARG" == "media" ] ; then
    INSTALL_ZEROTIER=true                   #Install Zerotier - set to false to skip
    INSTALL_ZEROTIER_ROUTER=false           #Install Zerotier - set to false to skip
    INSTALL_PIHOLE=false                    #Install Pihole - set to false to skip
    INSTALL_HASS=false                      #Install Home Assistant - set to false to skip
    INSTALL_LIBRE_SPEEDTEST=false           #Install Libre Speedtest Server - set to false to skip
    INSTALL_FILE_SERVER=false               #Install MergerFS and SAMBA - set to false to skip
    INSTALL_SABNZBD=false                   #Install SABNZBD - set to false to skip
    INSTALL_DELUGE=false                    #Install Deluge - set to false to skip
    INSTALL_SONARR=false                    #Install Sonarr - set to false to skip
    INSTALL_RADARR=false                    #Install Radarr - set to false to skip
    INSTALL_PLEX_SERVER=false               #Install Plex Server - set to false to skip
    INSTALL_UPTIME_KUMA=false               #Install Uptime Kuma - set to false to skip
    INSTALL_SHARES=false                    #Install Windows Shares - set to false to skip
    INSTALL_SHELL_EXTENSIONS=true           #Install Shell Extensions - set to false to skip
    INSTALL_RUSTDESK_CLIENT=true            #Install Rustdesk Client - set to false to skip

    if ! command -v gnome-shell 2>&1 >/dev/null ; then
        apt install flatpak piper gir1.2-gtop-2.0 lm-sensors gparted -y
    else
        apt install flatpak gnome-software-plugin-flatpak gnome-shell-extension-manager piper gir1.2-gtop-2.0 lm-sensors gnome-tweaks gparted -y
    fi

    INTEL_GPU=$(lspci -k | grep -EA3 'VGA|3D|Display' | grep "Intel" | xargs)
        
    if [ "$INTEL_GPU" != "" ]; then
        DISTRO=$(lsb_release -i | grep "Distributor" | cut -d ':' -f 2 | xargs | cut -d '.' -f 1)

        if [ "$DISTRO" == "Ubuntu" ]; then
            VERSION=$(lsb_release -r | grep "Release" | cut -d ':' -f 2 | xargs)

            echo Intel GPU detected on $DISTRO $VERSION

            if [ "$VERSION" == "22.04" ]; then
                wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
                echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list
                apt update
                apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-22.04
            elif [ "$VERSION" == "24.04" ]; then
                wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
                echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | tee /etc/apt/sources.list.d/intel-gpu-noble.list
                sudo apt update
                apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-24.04
            fi
        fi
    fi

    snap refresh
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 

    if [ "$ARG" == "desktop" ] ; then
        DISTRO=$(lsb_release -a | grep "Distributor" | cut -d ':' -f 2 | xargs | cut -d '.' -f 1)

        if [ "$DISTRO" == "Ubuntu" ]; then
            VERSION=$(lsb_release -a | grep "Release" | cut -d ':' -f 2 | xargs | cut -d '.' -f 1)

            if [ "$VERSION" -gt 22 ]; then
                dpkg --add-architecture i386
                apt update
                apt install steam-installer -y
            else
                apt install steam -y
            fi

            snap install --classic code
        fi

        flatpak install flathub com.google.Chrome com.discordapp.Discord org.videolan.VLC com.spotify.Client org.gimp.GIMP org.libreoffice.LibreOffice io.github.mimbrero.WhatsAppDesktop org.signal.Signal org.inkscape.Inkscape com.slack.Slack com.adobe.Reader com.skype.Client tv.plex.PlexDesktop cc.arduino.IDE2 org.raspberrypi.rpi-imager com.ultimaker.cura io.github.prateekmedia.appimagepool org.kicad.KiCad org.gnome.meld org.qbittorrent.qBittorrent com.notepadqq.Notepadqq org.wireshark.Wireshark us.zoom.Zoom com.github.tchx84.Flatseal -y
    else
        INSTALL_SHARES=true
        flatpak install flathub com.google.Chrome org.videolan.VLC com.spotify.Client org.libreoffice.LibreOffice com.adobe.Reader com.skype.Client tv.plex.PlexDesktop io.github.prateekmedia.appimagepool org.gnome.meld org.qbittorrent.qBittorrent com.notepadqq.Notepadqq us.zoom.Zoom com.github.tchx84.Flatseal -y
    fi
fi 

apt install curl nano jq cron rsyslog whois build-essential openssh-server git python3-pip pipx python3-dev htop net-tools bzip2 ntfs-3g bmon software-properties-common intel-gpu-tools -y

#Constants
APP_UID=$SUDO_USER
APP_GUID=users
HOST=$(hostname -I)
IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")

if [ "$INSTALL_SHELL_EXTENSIONS" == "true" ] ; then
    if ! command -v gnome-shell 2>&1 >/dev/null ; then
        echo "Gnome Shell could not be found. Not installing shell extensions."
        INSTALL_SHELL_EXTENSIONS=false
    else
        GNOME_VERSION=$(gnome-shell --version | cut -d ' ' -f 3 | cut -d '.' -f 1)
    fi
fi

#Zerotier Setup
if [ "$INSTALL_ZEROTIER" == "true" ] || [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
    echo "-----------------------------Installing Zerotier-----------------------------"

    curl -s https://install.zerotier.com | bash
    zerotier-cli join $NWID

    MEMBER_ID=$(zerotier-cli info | cut -d " " -f 3)
    echo "Joined network: $NWID with member_id: $MEMBER_ID"
    
    curl -s -o /dev/null -H "Authorization: token $ZT_TOKEN" -X POST "https://api.zerotier.com/api/v1/network/$NWID/member/$MEMBER_ID" --data '{"config": {"authorized": true}, "name": "'"${HOSTNAME}"'"}'

    sleep 5
    VIA_IP=$(curl -s -H "Authorization: token $ZT_TOKEN" -X GET "https://api.zerotier.com/api/v1/network/$NWID/member/$MEMBER_ID" | jq '.config.ipAssignments[0]' | cut -d '"' -f2)
    ZT_IFACE=$(ifconfig | grep zt* | cut -d ":" -f 1 | head --lines 1)

    echo "Authorized Zerotier Interface: $ZT_IFACE with IP: $VIA_IP"
    echo "Installled Zerotier"
fi

#Zerotier Router Setup
if [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
    echo "-----------------------------Installing Zerotier Router-----------------------------"

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

    apt-get -y install iptables-persistent
    bash -c iptables-save > /etc/iptables/rules.v4

    echo "Installled Zerotier Router"
fi

#PiHole
if [ "$INSTALL_PIHOLE" == "true" ] ; then
    echo "-----------------------------Installing PiHole-----------------------------"

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

    echo "Installled PiHole"
fi

#Home Assistant
if [ "$INSTALL_HASS" == "true" ] ; then
    echo "-----------------------------Installing Home Assistant-----------------------------"

    apt-get install -y python3 python3-dev python3-venv python3-pip bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata ffmpeg liblapack3 liblapack-dev libatlas-base-dev

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
    
    echo [Unit] > /etc/systemd/system/home-assistant@homeassistant.service
    echo Description=Home Assistant >> /etc/systemd/system/home-assistant@homeassistant.service
    echo After=network-online.target >> /etc/systemd/system/home-assistant@homeassistant.service
    echo " " >> /etc/systemd/system/home-assistant@homeassistant.service
    echo [Service] >> /etc/systemd/system/home-assistant@homeassistant.service
    echo Type=simple >> /etc/systemd/system/home-assistant@homeassistant.service
    echo User=%i >> /etc/systemd/system/home-assistant@homeassistant.service
    echo WorkingDirectory=/home/%i/.homeassistant >> /etc/systemd/system/home-assistant@homeassistant.service
    echo ExecStart=/srv/homeassistant/bin/hass -c "/home/%i/.homeassistant" >> /etc/systemd/system/home-assistant@homeassistant.service
    echo Environment="PATH=/srv/homeassistant/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/homeassistant/.local/bin" >>  /etc/systemd/system/home-assistant@homeassistant.service
    echo RestartForceExitStatus=100 >> /etc/systemd/system/home-assistant@homeassistant.service
    echo " " >> /etc/systemd/system/home-assistant@homeassistant.service
    echo [Install] >> /etc/systemd/system/home-assistant@homeassistant.service
    echo WantedBy=multi-user.target >> /etc/systemd/system/home-assistant@homeassistant.service
    
    systemctl --system daemon-reload
    systemctl enable home-assistant@homeassistant
    systemctl start home-assistant@homeassistant

    echo "Installled Home Assistant"
fi

if [ "$INSTALL_LIBRE_SPEEDTEST" == "true" ] ; then
    echo "-----------------------------Installing Libre Speed Test-----------------------------"

    echo "Installing Nginx"
    apt install nginx mariadb-server php-fpm php-mysql php-image-text php-gd php-sqlite3 -y

    rm -rf /etc/nginx/sites-available/speedtest

    echo "Configuring Nginx"
    echo "server {" > /etc/nginx/sites-available/speedtest
    echo "    listen $LIBREST_PORT;" >> /etc/nginx/sites-available/speedtest
    echo "    server_name speedtest www.speedtest;" >> /etc/nginx/sites-available/speedtest
    echo "    root /var/www/html/speedtest;" >> /etc/nginx/sites-available/speedtest
    echo "" >> /etc/nginx/sites-available/speedtest
    echo "    index index.html index.htm index.php;" >> /etc/nginx/sites-available/speedtest
    echo "" >> /etc/nginx/sites-available/speedtest
    echo "    location / {" >> /etc/nginx/sites-available/speedtest
    echo '        try_files $uri $uri/ =404;' >> /etc/nginx/sites-available/speedtest
    echo "    }" >> /etc/nginx/sites-available/speedtest
    echo "" >> /etc/nginx/sites-available/speedtest
    echo "    location ~ \.php$ {" >> /etc/nginx/sites-available/speedtest
    echo "        include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/speedtest
    echo "        fastcgi_pass unix:/var/run/php/php-fpm.sock;" >> /etc/nginx/sites-available/speedtest
    echo "    }" >> /etc/nginx/sites-available/speedtest
    echo "" >> /etc/nginx/sites-available/speedtest
    echo "    location ~ /\.ht {" >> /etc/nginx/sites-available/speedtest
    echo "        deny all;" >> /etc/nginx/sites-available/speedtest
    echo "    }" >> /etc/nginx/sites-available/speedtest
    echo "" >> /etc/nginx/sites-available/speedtest
    echo "}" >> /etc/nginx/sites-available/speedtest

    ln -s /etc/nginx/sites-available/speedtest /etc/nginx/sites-enabled/
    unlink /etc/nginx/sites-enabled/default

    systemctl reload nginx

    FPM_VERSION=$(ls /var/run/php | grep "php8.*fpm.sock") 
    INI_LOCATION="/etc/php/${FPM_VERSION:3:3}/fpm/php.ini"

    echo "Configuring PHP"
    sed -i 's/post_max_size = 8M/post_max_size = 100M/' $INI_LOCATION
    sed -i 's/;extension=gd/extension=gd/' $INI_LOCATION
    sed -i 's/;extension=pdo_sqlite/extension=pdo_sqlite/' $INI_LOCATION

    systemctl restart nginx    

    echo "Installing Libre Speed Test"

    rm -rf /var/www/html/speedtest/
    mkdir -p /var/www/html/speedtest
    chown -R $SUDO_USER:$SUDO_USER /var/www/html/speedtest
    
    git clone https://github.com/librespeed/speedtest.git

    sleep 3

    cp -f ./speedtest/index.html /var/www/html/speedtest/
    cp -f ./speedtest/speedtest.js /var/www/html/speedtest/
    cp -f ./speedtest/speedtest_worker.js /var/www/html/speedtest/
    cp -f ./speedtest/favicon.ico /var/www/html/speedtest/
    cp -rf ./speedtest/backend/  /var/www/html/speedtest/
    cp -rf ./speedtest/results/  /var/www/html/results/

    rm -rf ./speedtest
    echo "Installled Libre Speed Test"
fi

#MergerFS Setup
if [ "$INSTALL_FILE_SERVER" == "true" ] ; then
    echo "-----------------------------Installing MergerFS-----------------------------"

    echo "Setting up Shared Folders"
    apt install samba mergerfs smartmontools -y

    #TODO: Fix usb hdd detection

    if [ ${#HDD_IDS[@]} -eq 0 ]; then
        echo "No HDD configured using default options"
        echo "Seaching for suitable drives..."

        ls /dev/disk/by-id | grep -v "part\|DVD\|CD\|mmc" | grep "ata\|usb\|nvme\|scsi" | while read -r DRIVE ; do
            echo "Found Drive: $DRIVE"

            PARTITIONS=$(ls /dev/disk/by-id | grep "$DRIVE-part1")
            
            ls /dev/disk/by-id | grep "$DRIVE-part" | while read -r PARTITION ; do
                MOUNT_POINT=$(lsblk -r /dev/disk/by-id/$PARTITION | grep "sd" | cut -d " " -f 7)
                FSTYPE=$(lsblk -n -o FSTYPE /dev/disk/by-id/$PARTITION)
                
                if [ -z ${MOUNT_POINT} ]; then
                    echo "  Found Partition: $PARTITION which is not mounted"

                    if [ -z ${FSTYPE} ]; then
                        echo "      Partition $PARTITION is not formatted. Formatting now..."
                        mkfs.ntfs -f /dev/disk/by-id/$PARTITION
                    fi

                    echo "      Adding partition to MergerFS Pool"
                    echo $PARTITION >> hdd_ids.temp
                else
                    echo "  Found Partition: $PARTITION mounted at $MOUNT_POINT"

                    if [ "$MOUNT_POINT" = "/" ] || [[ "$MOUNT_POINT" = "/var/"* ]] || [[ "$MOUNT_POINT" = "/boot/"* ]] || [[ "$MOUNT_POINT" = "/root/"* ]] || [[ "$MOUNT_POINT" = *"/snap/"* ]] || [[ "$MOUNT_POINT" = *"/run/"* ]] || [[ "$MOUNT_POINT" = *"/dev/"* ]] || [[ "$MOUNT_POINT" = *"/sys/"* ]]; then
                        echo "      Partition mounted on root: skipping"
                    else

                        echo "      Adding partition to MergerFS Pool"
                        echo $PARTITION >> hdd_ids.temp
                    fi
                fi
            done
            
            if [ -z ${PARTITIONS} ]; then
                echo "  Drive has no partitions: "
                echo "  Attempting to create them now..."

                sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/disk/by-id/$DRIVE
                    o # clear the in memory partition table
                    n # new partition
                    p # primary partition
                    1 # partition number 1
                        # default, start immediately after preceding partition
                        # default, extend partition to end of disk
                    p # print the in-memory partition table
                    w # write the partition table
                    q # and we're done
EOF
                sleep 5
                PARTITION=$(ls /dev/disk/by-id | grep "$DRIVE-part1")

                echo "  Formatting with NTFS:"
                mkfs.ntfs -f /dev/disk/by-id/$PARTITION

                echo "Adding to MergerFS pool"
                echo $PARTITION >> hdd_ids.temp
            fi
        done
    fi

    if [ ${#HDD_IDS[@]} -eq 0 ]; then
        mapfile -t HDD_IDS < hdd_ids.temp
        rm -f hdd_ids.temp
    fi

    if [ ${#HDD_IDS[@]} -eq 0 ]; then
        echo "No suitable drives found for MergerFS. Skipping setup"
    else
        echo "Configuring MergerFS:"

        COUNTER=1
        for HDD_ID in ${HDD_IDS[@]}; do
            HDD=$(ls /dev/disk/by-id | grep "$HDD_ID")

            if [ -z ${HDD} ]; then
                echo "Invalid disk ID: $HDD_ID, skipping"
                continue
            fi

            FSNAME=$(lsblk -n -o NAME /dev/disk/by-id/$HDD_ID)
            FSTYPE=$(lsblk -n -o FSTYPE /dev/disk/by-id/$HDD_ID)

            if grep -F "/dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER" /etc/fstab ; then
                echo "Found existing disk: $FSNAME, with partition type: $FSTYPE, mounted on: /mnt/disk$COUNTER"
                COUNTER=$[ $COUNTER + 1 ]
                continue
            fi

            echo "Detected new disk: $FSNAME with partition type: $FSTYPE"

            mkdir -p /mnt/disk$COUNTER
            if [ "$FSTYPE" == "ntfs" ]; then
                echo "/dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER   $FSTYPE defaults,nofail,permissions 0 0" >> /etc/fstab
            else
                echo "/dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER   $FSTYPE defaults,nofail 0 0" >> /etc/fstab
            fi

            mount /dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER
            COUNTER=$[ $COUNTER + 1 ]
        done

        if [ "$MERGERFS_DIR" == "default" ]; then
            MERGERFS_DIR="nas"
        fi

        if grep -F "/mnt/disk* /mnt/$MERGERFS_DIR fuse.mergerfs" /etc/fstab ; then
            echo "MergerFS already found"
        else
            mkdir -p /mnt/$MERGERFS_DIR

            echo "/mnt/disk*/ /mnt/$MERGERFS_DIR fuse.mergerfs defaults,nonempty,allow_other,use_ino,cache.files=off,moveonenospc=true,dropcacheonclose=true,minfreespace=10G,fsname=mergerfs 0 0" >> /etc/fstab
            mergerfs -o defaults,nonempty,allow_other,use_ino,cache.files=off,moveonenospc=true,dropcacheonclose=true,minfreespace=20G,fsname=mergerfs /mnt/disk\* /mnt/$MERGERFS_DIR
        fi

        chown -R $APP_UID:$APP_GUID /mnt/$MERGERFS_DIR
        echo "Created /mnt/$MERGERFS_DIR using mergerfs."
        echo "Creating SAMBA Shares:"

        if grep -F "comment = MergerFS Share" /etc/samba/smb.conf ; then
            echo "Share Already Exists"
        else
            echo "[$MERGERFS_DIR]" >> /etc/samba/smb.conf
            echo "    comment = MergerFS Share" >> /etc/samba/smb.conf
            echo "    path = /mnt/$MERGERFS_DIR" >> /etc/samba/smb.conf
            echo "    read only = $READ_ONLY_SHARES" >> /etc/samba/smb.conf
            echo "    browsable = yes" >> /etc/samba/smb.conf

            service smbd restart

            if [ "$REMOTE_USER" == "default" ]; then
                REMOTE_USER=$SUDO_USER
            fi

            useradd -r $REMOTE_USER
            sleep 1
            echo -ne "$REMOTE_PASS\n$REMOTE_PASS\n" | passwd -q $REMOTE_USER
            echo -ne "$REMOTE_PASS\n$REMOTE_PASS\n" | smbpasswd -a -s $REMOTE_USER
        fi
        SMB_URL="smb://$IP_LOCAL/$MERGERFS_DIR"
        echo "Samba share can now be accessed at: $SMB_URL"
    fi

    echo "Installled MergerFS"
fi

#SABNZBd
if [ "$INSTALL_SABNZBD" == "true" ] ; then
    echo "-----------------------------Installing SABNZBd-----------------------------"

    add-apt-repository ppa:jcfp/nobetas -y
    apt-get update -y
    apt-get install sabnzbdplus -y
       
    echo "Creating new service file..."
    cat <<EOF | tee /etc/default/sabnzbdplus >/dev/null
    # This file is sourced by /etc/init.d/sabnzbdplus
    #
    # When SABnzbd+ is started using the init script, the
    # --daemon option is always used, and the program is
    # started under the account of $USER, as set below.
    #
    # Each setting is marked either "required" or "optional";
    # leaving any required setting un-configured will cause
    # the service to not start.

    # [required] user or uid of account to run the program as:
    USER=$APP_UID

    # [optional] full path to the configuration file of your choice;
    #            otherwise, the default location (in $USER's home
    #            directory) is used:
    CONFIG=

    # [optional] hostname/ip and port number to listen on:
    HOST=0.0.0.0
    PORT=$SABNZBD_PORT
    
    # [optional] extra command line options, if any:
    EXTRAOPTS=
EOF

    echo "Waiting for background processes"
    service sabnzbdplus stop
    systemctl daemon-reload
    service sabnzbdplus restart
    sleep 9
    service sabnzbdplus stop
    sleep 1
    
    if grep -F "[servers]" /home/$APP_UID/.sabnzbd/sabnzbd.ini ; then
        echo "Existing Servers Found!"
    else
        echo "Creating new config in /home/$APP_UID/.sabnzbd/sabnzbd.ini"
        echo [servers] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini

        NUM_SERVERS=$(echo "$SERVERS" | jq length)

        for ((i = 0; i < NUM_SERVERS; i++)) ; do

            SERVER_HOST=$(echo $SERVERS | jq ".[$i].SERVER_HOST")
            SERVER_PORT=$(echo $SERVERS | jq ".[$i].SERVER_PORT")
            SERVER_USERNAME=$(echo $SERVERS | jq ".[$i].SERVER_USERNAME")
            SERVER_PASSWORD=$(echo $SERVERS | jq ".[$i].SERVER_PASSWORD")
            SERVER_CONNECTIONS=$(echo $SERVERS | jq ".[$i].SERVER_CONNECTIONS")
            SERVER_SSL=$(echo $SERVERS | jq ".[$i].SERVER_SSL")

            echo [[$SERVER_HOST]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo name = $SERVER_HOST >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo displayname = $SERVER_HOST >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo host = $SERVER_HOST >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo port = $SERVER_PORT >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo timeout = 30 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo username = $SERVER_USERNAME >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo "password = $SERVER_PASSWORD" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo connections = $SERVER_CONNECTIONS >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo ssl = $SERVER_SSL >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo ssl_verify = 2 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo ssl_ciphers = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo enable = 1 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo required = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo optional = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo retention = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo expire_date = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo quota = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo usage_at_start = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo priority = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
            echo notes = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        done


        echo [categories] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[*]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo "name = *" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = 3 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = None >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[movies]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = movies >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[tv]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = tv >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[audio]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = audio >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[software]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = software >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[sonarr]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = sonarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = sonarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo [[radarr]] >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo name = radarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo order = 0 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo pp = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo script = Default >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo dir = radarr >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo newzbin = "" >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
        echo priority = -100 >> /home/$APP_UID/.sabnzbd/sabnzbd.ini
    fi
    
    sed -i 's/permissions = ""/permissions = 775/' /home/$APP_UID/.sabnzbd/sabnzbd.ini

    systemctl daemon-reload
    service sabnzbdplus restart
    
    SABNZBD_URL="http://$IP_LOCAL:$SABNZBD_PORT"
    echo "SABNZBd Is running: Browse to $SABNZBD_URL for the SABNZBd GUI"
    echo "Installled SABNZBd"
fi

#Deluge
if [ "$INSTALL_DELUGE" == "true" ] ; then
    echo "-----------------------------Installing Deluge-----------------------------"

    #add-apt-repository ppa:deluge-team/stable -y
    #apt update

    apt install deluged deluge-web deluge-console -y

    echo "Creating deluged service file"
    cat <<EOF | tee /etc/systemd/system/deluged.service >/dev/null
    [Unit]
    Description=Deluge Bittorrent Client Daemon
    After=network-online.target

    [Service]
    Type=simple
    User=$APP_UID
    Group=$APP_GUID
    UMask=007
    ExecStart=/usr/bin/deluged -d
    Restart=on-failure

    # Configures the time to wait before service is stopped forcefully.
    TimeoutStopSec=300

    [Install]
    WantedBy=multi-user.target
EOF

    echo "Creating deluge web service file"
    cat <<EOF | tee /etc/systemd/system/deluge-web.service >/dev/null
    [Unit]
    Description=Deluge Bittorrent Client Web Interface
    After=network-online.target

    [Service]
    Type=simple
    User=$APP_UID
    Group=$APP_GUID
    UMask=027
    ExecStart=/usr/bin/deluge-web -d
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl restart deluged

    sleep 2
    systemctl stop deluged
    sleep 1

    echo "Creating deluge config file"
    cat <<EOF | tee /home/$APP_UID/.config/deluge/core.conf >/dev/null
{
    "file": 1,
    "format": 1
}{
    "add_paused": false,
    "allow_remote": false,
    "auto_manage_prefer_seeds": false,
    "auto_managed": true,
    "cache_expiry": 60,
    "cache_size": 512,
    "copy_torrent_file": false,
    "daemon_port": 58846,
    "del_copy_torrent_file": false,
    "dht": true,
    "dont_count_slow_torrents": false,
    "download_location": "/home/$APP_UID/Downloads",
    "download_location_paths_list": [],
    "enabled_plugins": [
        "Label"
    ],
    "enc_in_policy": 1,
    "enc_level": 2,
    "enc_out_policy": 1,
    "geoip_db_location": "/usr/share/GeoIP/GeoIP.dat",
    "ignore_limits_on_local_network": true,
    "info_sent": 0.0,
    "listen_interface": "",
    "listen_ports": [
        6881,
        6891
    ],
    "listen_random_port": 60757,
    "listen_reuse_port": true,
    "listen_use_sys_port": false,
    "lsd": true,
    "max_active_downloading": 8,
    "max_active_limit": 18,
    "max_active_seeding": 5,
    "max_connections_global": 400,
    "max_connections_per_second": 30,
    "max_connections_per_torrent": -1,
    "max_download_speed": -1.0,
    "max_download_speed_per_torrent": -1,
    "max_half_open_connections": 50,
    "max_upload_slots_global": 4,
    "max_upload_slots_per_torrent": -1,
    "max_upload_speed": -1.0,
    "max_upload_speed_per_torrent": -1,
    "move_completed": false,
    "move_completed_path": "/home/$APP_UID/Downloads",
    "move_completed_paths_list": [],
    "natpmp": true,
    "new_release_check": false,
    "outgoing_interface": "",
    "outgoing_ports": [
        0,
        0
    ],
    "path_chooser_accelerator_string": "Tab",
    "path_chooser_auto_complete_enabled": true,
    "path_chooser_max_popup_rows": 20,
    "path_chooser_show_chooser_button_on_localhost": true,
    "path_chooser_show_hidden_files": false,
    "peer_tos": "0x00",
    "plugins_location": "/home/$APP_UID/.config/deluge/plugins",
    "pre_allocate_storage": false,
    "prioritize_first_last_pieces": false,
    "proxy": {
        "anonymous_mode": false,
        "force_proxy": false,
        "hostname": "",
        "password": "",
        "port": 8080,
        "proxy_hostnames": true,
        "proxy_peer_connections": true,
        "proxy_tracker_connections": true,
        "type": 0,
        "username": ""
    },
    "queue_new_to_top": false,
    "random_outgoing_ports": true,
    "random_port": true,
    "rate_limit_ip_overhead": true,
    "remove_seed_at_ratio": false,
    "seed_time_limit": 180,
    "seed_time_ratio_limit": 7.0,
    "send_info": false,
    "sequential_download": false,
    "share_ratio_limit": 2.0,
    "shared": false,
    "stop_seed_at_ratio": false,
    "stop_seed_ratio": 2.0,
    "super_seeding": false,
    "torrentfiles_location": "/home/$APP_UID/Downloads",
    "upnp": true,
    "utpex": true
}
EOF

    systemctl restart deluge-web
    sleep 3
    systemctl stop deluge-web
    sleep 1

    sed -i "s/8112/$DELUGE_PORT/" /home/$APP_UID/.config/deluge/web.conf

    systemctl restart deluged
    systemctl restart deluge-web
    systemctl enable deluged
    systemctl enable deluge-web

    DELUGE_URL="http://$IP_LOCAL:$DELUGE_PORT"
    echo "Deluge Is running: Browse to $DELUGE_URL for the Deluge GUI"
    echo "Installled Deluge"
fi

#Sonarr
if [ "$INSTALL_SONARR" == "true" ] ; then
    echo "-----------------------------Installing Sonarr-----------------------------"
    set -euo pipefail

    app="sonarr"
    app_port=$SONARR_PORT
    app_umask="0002"
    branch="main"
    installdir="/opt"              # {Update me if needed} Install Location
    bindir="${installdir}/${app^}" # Full Path to Install Location
    datadir="/var/lib/$app/"       # {Update me if needed} AppData directory to use
    app_bin=${app^}                # Binary Name of the app
    APP_UID=$(echo "$APP_UID" | tr -d ' ')
    APP_UID=${APP_UID:-$app}
    APP_GUID=$(echo "$APP_GUID" | tr -d ' ')
    APP_GUID=${APP_GUID:-media}

    echo "This will install [${app^}] to [$bindir] and use [$datadir] for the AppData Directory"

    echo "Stoppin the App if running"
    if service --status-all | grep -Fq "$app"; then
        systemctl stop "$app"
        systemctl disable "$app".service
        echo "Stopped existing $app"
    fi

    mkdir -p "$datadir"
    chown -R "$APP_UID":"$APP_GUID" "$datadir"
    chmod 775 "$datadir"
    echo "Directories created"

    echo "Downloading and installing the App"
    ARCH=$(dpkg --print-architecture)
    dlbase="https://services.sonarr.tv/v1/download/$branch/latest?version=4&os=linux"
    case "$ARCH" in
    "amd64") DLURL="${dlbase}&arch=x64" ;;
    "armhf") DLURL="${dlbase}&arch=arm" ;;
    "arm64") DLURL="${dlbase}&arch=arm64" ;;
    *)
        echo "Arch not supported"
        exit 1
        ;;
    esac

    rm -f "${app^}".*.tar.gz
    wget --inet4-only --content-disposition "$DLURL"
    tar -xvzf "${app^}".*.tar.gz
    echo "Installation files downloaded and extracted"

    echo "Removing existing installation"
    rm -rf "$bindir"

    echo "Installing..."
    mv "${app^}" $installdir
    chown "$APP_UID":"$APP_GUID" -R "$bindir"
    chmod 775 "$bindir"
    rm -rf "${app^}.*.tar.gz"
    touch "$datadir"/update_required
    chown "$APP_UID":"$APP_GUID" "$datadir"/update_required
    echo "App Installed"

    echo "Removing old service file"
    rm -rf /etc/systemd/system/"$app".service

    echo "Creating service file"
    cat <<EOF | tee /etc/systemd/system/"$app".service >/dev/null
    [Unit]
    Description=${app^} Daemon
    After=syslog.target network.target
    [Service]
    User=$APP_UID
    Group=$APP_GUID
    UMask=$app_umask
    Type=simple
    ExecStart=$bindir/$app_bin -nobrowser -data=$datadir
    TimeoutStopSec=20
    KillMode=process
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
EOF
    sleep 2

    echo "Service file created. Attempting to start the app"
    systemctl -q daemon-reload
    systemctl enable --now -q "$app"
    sleep 5

    echo "Checking if the service is up and running..."
    while ! systemctl is-active --quiet "$app"; do
        sleep 5
    done

    sed -i "s/>8989</>$app_port</" "$datadir"config.xml
    systemctl restart -q $app

    echo -e "${app^} installation and service start up is complete!"
    echo -e "Attempting to check for a connection at http://$IP_LOCAL:$app_port..."

    sleep 15

    STATUS="$(systemctl is-active "$app")"
    if [ "${STATUS}" = "active" ]; then
        SONARR_APIKEY=$(grep "ApiKey" "$datadir/config.xml" | cut -d '>' -f 2 | cut -d '<' -f 1)
    
        if grep "api_key" "/home/$APP_UID/.sabnzbd/sabnzbd.ini" ; then
            SABNZBD_APIKEY=$(grep "api_key" "/home/$APP_UID/.sabnzbd/sabnzbd.ini" | cut -d "=" -f 2 | xargs)
            
            if [ "$INSTALL_SABNZBD" == "true" ] ; then
                echo "Adding Download Client SABNZBd:"
                curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$SONARR_PORT/api/v3/downloadclient" --data '{"enable":true,"protocol":"usenet","priority":1,"removeCompletedDownloads":true,"removeFailedDownloads":true,"name":"SABnzbd","fields":[{"order":0,"name":"host","label":"Host","value":"localhost","type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":1,"name":"port","label":"Port","value":'"$SABNZBD_PORT"',"type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":2,"name":"useSsl","label":"Use SSL","helpText":"Use secure connection when connection to Sabnzbd","value":false,"type":"checkbox","advanced":false,"privacy":"normal","isFloat":false},{"order":3,"name":"urlBase","label":"URL Base","helpText":"Adds a prefix to the Sabnzbd url, such as http://[host]:[port]/[urlBase]/api","type":"textbox","advanced":true,"privacy":"normal","isFloat":false},{"order":4,"name":"apiKey","label":"API Key","value":"'"$SABNZBD_APIKEY"'","type":"textbox","advanced":false,"privacy":"apiKey","isFloat":false},{"order":5,"name":"username","label":"Username","value":"admin","type":"textbox","advanced":false,"privacy":"userName","isFloat":false},{"order":6,"name":"password","label":"Password","value":"password","type":"password","advanced":false,"privacy":"password","isFloat":false},{"order":7,"name":"tvCategory","label":"Category","helpText":"Adding a category specific to Sonarr avoids conflicts with unrelated non-Sonarr downloads. Using a category is optional, but strongly recommended.","value":"sonarr","type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":8,"name":"recentTvPriority","label":"Recent Priority","helpText":"Priority to use when grabbing episodes that aired within the last 14 days","value":-100,"type":"select","advanced":false,"selectOptions":[{"value":-100,"name":"Default","order":-100},{"value":-2,"name":"Paused","order":-2},{"value":-1,"name":"Low","order":-1},{"value":0,"name":"Normal","order":0},{"value":1,"name":"High","order":1},{"value":2,"name":"Force","order":2}],"privacy":"normal","isFloat":false},{"order":9,"name":"olderTvPriority","label":"Older Priority","helpText":"Priority to use when grabbing episodes that aired over 14 days ago","value":-100,"type":"select","advanced":false,"selectOptions":[{"value":-100,"name":"Default","order":-100},{"value":-2,"name":"Paused","order":-2},{"value":-1,"name":"Low","order":-1},{"value":0,"name":"Normal","order":0},{"value":1,"name":"High","order":1},{"value":2,"name":"Force","order":2}],"privacy":"normal","isFloat":false}],"implementationName":"SABnzbd","implementation":"Sabnzbd","configContract":"SabnzbdSettings","infoLink":"https://wiki.servarr.com/sonarr/supported#sabnzbd","tags":[]}'
            fi
        fi

        if [ "$INSTALL_DELUGE" == "true" ] ; then
            echo "Adding Download Client Deluge:"
            curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$SONARR_PORT/api/v3/downloadclient" --data '{ "enable": true, "protocol": "torrent", "priority": 1, "removeCompletedDownloads": true, "removeFailedDownloads": true, "name": "Deluge", "fields": [ { "order": 0, "name": "host", "label": "Host", "value": "localhost", "type": "textbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 1, "name": "port", "label": "Port", "value": '"$DELUGE_PORT"', "type": "textbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 2, "name": "useSsl", "label": "Use SSL", "helpText": "Use secure connection when connection to Deluge", "value": false, "type": "checkbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 3, "name": "urlBase", "label": "URL Base", "helpText": "Adds a prefix to the deluge json url, see http://[host]:[port]/[urlBase]/json", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false }, { "order": 4, "name": "password", "label": "Password", "value": "'"$DELUGE_PASSWORD"'", "type": "password", "advanced": false, "privacy": "password", "isFloat": false }, { "order": 5, "name": "tvCategory", "label": "Category", "helpText": "Adding a category specific to Sonarr avoids conflicts with unrelated non-Sonarr downloads. Using a category is optional, but strongly recommended.", "value": "sonarr", "type": "textbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 6, "name": "tvImportedCategory", "label": "Post-Import Category", "helpText": "Category for Sonarr to set after it has imported the download. Sonarr will not remove torrents in that category even if seeding finished. Leave blank to keep same category.", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false }, { "order": 7, "name": "recentTvPriority", "label": "Recent Priority", "helpText": "Priority to use when grabbing episodes that aired within the last 14 days", "value": 0, "type": "select", "advanced": false, "selectOptions": [ { "value": 0, "name": "Last", "order": 0 }, { "value": 1, "name": "First", "order": 1 } ], "privacy": "normal", "isFloat": false }, { "order": 8, "name": "olderTvPriority", "label": "Older Priority", "helpText": "Priority to use when grabbing episodes that aired over 14 days ago", "value": 0, "type": "select", "advanced": false, "selectOptions": [ { "value": 0, "name": "Last", "order": 0 }, { "value": 1, "name": "First", "order": 1 } ], "privacy": "normal", "isFloat": false }, { "order": 9, "name": "addPaused", "label": "Add Paused", "value": false, "type": "checkbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 10, "name": "downloadDirectory", "label": "Download Directory", "helpText": "Optional location to put downloads in, leave blank to use the default Deluge location", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false }, { "order": 11, "name": "completedDirectory", "label": "Move When Completed Directory", "helpText": "Optional location to move completed downloads to, leave blank to use the default Deluge location", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false } ], "implementationName": "Deluge", "implementation": "Deluge", "configContract": "DelugeSettings", "infoLink": "https://wiki.servarr.com/sonarr/supported#deluge", "tags": []}'
        fi

        echo "Adding Indexers:"
        NUM_INDEXERS=$(echo "$INDEXERS" | jq length)

        for ((i = 0; i < NUM_INDEXERS; i++)) ; do
            INDEXER_NAME=$(echo $INDEXERS | jq ".[$i].INDEXER_NAME")
            INDEXER_URL=$(echo $INDEXERS | jq ".[$i].INDEXER_URL")		                
            INDEXER_API_PATH=$(echo $INDEXERS | jq ".[$i].INDEXER_API_PATH")							
            INDEXER_APIKEY=$(echo $INDEXERS | jq ".[$i].INDEXER_APIKEY")
            
            curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$SONARR_PORT/api/v3/indexer" --data '{"enableRss":true,"enableAutomaticSearch":true,"enableInteractiveSearch":true,"supportsRss":true,"supportsSearch":true,"protocol":"usenet","priority":25,"seasonSearchMaximumSingleEpisodeAge":0,"downloadClientId":0,"name":'$INDEXER_NAME',"fields":[{"order":0,"name":"baseUrl","label":"URL","value":'$INDEXER_URL',"type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":1,"name":"apiPath","label":"API Path","helpText":"Path to the api, usually /api","value":'$INDEXER_API_PATH',"type":"textbox","advanced":true,"privacy":"normal","isFloat":false},{"order":2,"name":"apiKey","label":"API Key","value":'$INDEXER_APIKEY',"type":"textbox","advanced":false,"privacy":"apiKey","isFloat":false},{"order":3,"name":"categories","label":"Categories","helpText":"Drop down list, leave blank to disable standard/daily shows","value":[5030,5040,5050,5070],"type":"select","advanced":false,"selectOptionsProviderAction":"newznabCategories","privacy":"normal","isFloat":false},{"order":4,"name":"animeCategories","label":"Anime Categories","helpText":"Drop down list, leave blank to disable anime","value":[5030,5040,5070],"type":"select","advanced":false,"selectOptionsProviderAction":"newznabCategories","privacy":"normal","isFloat":false},{"order":5,"name":"animeStandardFormatSearch","label":"Anime Standard Format Search","helpText":"Also search for anime using the standard numbering","value":false,"type":"checkbox","advanced":false,"privacy":"normal","isFloat":false},{"order":6,"name":"additionalParameters","label":"Additional Parameters","helpText":"Please note if you change the category you will have to add required/restricted rules about the subgroups to avoid foreign language releases.","type":"textbox","advanced":true,"privacy":"normal","isFloat":false},{"order":7,"name":"multiLanguages","label":"Multi Languages","helpText":"What languages are normally in a multi release on this indexer?","value":[],"type":"select","advanced":true,"selectOptions":[{"value":-2,"name":"Original","order":0},{"value":26,"name":"Arabic","order":0},{"value":41,"name":"Bosnian","order":0},{"value":28,"name":"Bulgarian","order":0},{"value":38,"name":"Catalan","order":0},{"value":10,"name":"Chinese","order":0},{"value":39,"name":"Croatian","order":0},{"value":25,"name":"Czech","order":0},{"value":6,"name":"Danish","order":0},{"value":7,"name":"Dutch","order":0},{"value":1,"name":"English","order":0},{"value":42,"name":"Estonian","order":0},{"value":16,"name":"Finnish","order":0},{"value":19,"name":"Flemish","order":0},{"value":2,"name":"French","order":0},{"value":4,"name":"German","order":0},{"value":20,"name":"Greek","order":0},{"value":23,"name":"Hebrew","order":0},{"value":27,"name":"Hindi","order":0},{"value":22,"name":"Hungarian","order":0},{"value":9,"name":"Icelandic","order":0},{"value":44,"name":"Indonesian","order":0},{"value":5,"name":"Italian","order":0},{"value":8,"name":"Japanese","order":0},{"value":21,"name":"Korean","order":0},{"value":36,"name":"Latvian","order":0},{"value":24,"name":"Lithuanian","order":0},{"value":45,"name":"Macedonian","order":0},{"value":29,"name":"Malayalam","order":0},{"value":15,"name":"Norwegian","order":0},{"value":37,"name":"Persian","order":0},{"value":12,"name":"Polish","order":0},{"value":18,"name":"Portuguese","order":0},{"value":33,"name":"Portuguese (Brazil)","order":0},{"value":35,"name":"Romanian","order":0},{"value":11,"name":"Russian","order":0},{"value":40,"name":"Serbian","order":0},{"value":31,"name":"Slovak","order":0},{"value":46,"name":"Slovenian","order":0},{"value":3,"name":"Spanish","order":0},{"value":34,"name":"Spanish (Latino)","order":0},{"value":14,"name":"Swedish","order":0},{"value":43,"name":"Tamil","order":0},{"value":32,"name":"Thai","order":0},{"value":17,"name":"Turkish","order":0},{"value":30,"name":"Ukrainian","order":0},{"value":13,"name":"Vietnamese","order":0}],"privacy":"normal","isFloat":false}],"implementationName":"Newznab","implementation":"Newznab","configContract":"NewznabSettings","infoLink":"https://wiki.servarr.com/sonarr/supported#newznab","tags":[]}'
        done

        echo "Adding Root Folders:"
        for FOLDER in ${SONARR_ROOT_FOLDER[@]}; do
            mkdir -p $FOLDER
            chown -R "$APP_UID":"$APP_GUID" $FOLDER
            chmod 775 "$FOLDER"
            
            curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$SONARR_PORT/api/v3/rootfolder" --data '{"path":"'"$FOLDER"'","accessible":true,"freeSpace":0,"unmappedFolders":[]}'
        done
        
        echo "Setting more sensible quality values"
        QUALITIES=$(curl -s -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X GET "http://$IP_LOCAL:$SONARR_PORT/api/v3/qualitydefinition")

        QUALITY_MAP='{"Unknown":{"minSize":1,"maxSize":50,"preferredSize":20},"SDTV":{"minSize":2,"maxSize":50,"preferredSize":20},"WEBRip-480p":{"minSize":2,"maxSize":50,"preferredSize":20},"WEBDL-480p":{"minSize":2,"maxSize":50,"preferredSize":20},"DVD":{"minSize":2,"maxSize":50,"preferredSize":20},"Bluray-480p":{"minSize":2,"maxSize":50,"preferredSize":20},"HDTV-720p":{"minSize":3,"maxSize":50,"preferredSize":20},"HDTV-1080p":{"minSize":4,"maxSize":50,"preferredSize":20},"Raw-HD":{"minSize":4,"maxSize":50,"preferredSize":20},"WEBRip-720p":{"minSize":3,"maxSize":50,"preferredSize":20},"WEBDL-720p":{"minSize":3,"maxSize":50,"preferredSize":20},"Bluray-720p":{"minSize":4,"maxSize":50,"preferredSize":20},"WEBRip-1080p":{"minSize":4,"maxSize":50,"preferredSize":20},"WEBDL-1080p":{"minSize":4,"maxSize":50,"preferredSize":20},"Bluray-1080p":{"minSize":4,"maxSize":50,"preferredSize":20},"Bluray-1080p Remux":{"minSize":0,"maxSize":50,"preferredSize":20},"HDTV-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"WEBRip-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"WEBDL-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"Bluray-2160p":{"minSize":35,"maxSize":50,"preferredSize":35},"Bluray-2160p Remux":{"minSize":35,"maxSize":50,"preferredSize":35}}'
        NUM_QUALITIES=$(echo "$QUALITIES" | jq length)

        for ((i = 0; i < NUM_QUALITIES; i++)) ; do

            QUALITY_NAME=$(echo $QUALITIES | jq ".[$i].title" ) 
            QUALITY=$(echo $QUALITIES | jq ".[$i]" ) 

            MINSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.minSize")  
            MAXSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.maxSize")  
            PREFSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.preferredSize")

            if [ "$MINSIZE" != "null" ] ; then
                QUALITY=$(echo $QUALITY | jq ".minSize=$MINSIZE | .maxSize=$MAXSIZE | .preferredSize=$PREFSIZE")
            fi

            curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$SONARR_PORT/api/v3/qualitydefinition" --data "${QUALITY}"
        done

        echo "Setting Permissions"
        curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$SONARR_PORT/api/v3/config/mediamanagement"  --data '{"autoUnmonitorPreviouslyDownloadedEpisodes":false,"recycleBin":"","recycleBinCleanupDays":7,"downloadPropersAndRepacks":"preferAndUpgrade","createEmptySeriesFolders":false,"deleteEmptyFolders":true,"fileDate":"none","rescanAfterRefresh":"always","setPermissionsLinux":true,"chmodFolder":"755","chownGroup":"'"$APP_GUID"'","episodeTitleRequired":"always","skipFreeSpaceCheckWhenImporting":false,"minimumFreeSpaceWhenImporting":100,"copyUsingHardlinks":true,"useScriptImport":false,"scriptImportPath":"","importExtraFiles":true,"extraFileExtensions":"srt","enableMediaInfo":true,"id":1}'

        echo "Setting Naming Conventions"
        curl -H "Content-Type: application/json" -H "X-Api-Key: $SONARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$SONARR_PORT/api/v3/config/naming"  --data '{"renameEpisodes":true,"replaceIllegalCharacters":true,"colonReplacementFormat":4,"customColonReplacementFormat":"","multiEpisodeStyle":5,"standardEpisodeFormat":"{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}","dailyEpisodeFormat":"{Series Title} - {Air-Date} - {Episode Title} {Quality Full}","animeEpisodeFormat":"{Series Title} - {absolute:000} - {Episode Title} {Quality Full}","seriesFolderFormat":"{Series Title}","seasonFolderFormat":"Season {season}","specialsFolderFormat":"Specials","id":1}'

        SONARR_URL="http://$IP_LOCAL:$app_port"
        echo "Browse to $SONARR_URL for the ${app^} GUI"
    else
        echo "${app^} failed to start"
    fi

    echo "Installled Sonarr"
fi

#Radarr
if [ "$INSTALL_RADARR" == "true" ] ; then
    echo "-----------------------------Installing Radarr-----------------------------"
    set -euo pipefail

    app="radarr"
    app_port=$RADARR_PORT          # Default App Port; Modify config.xml after install if needed
    app_umask="0002"
    branch="master"                # {Update me if needed} branch to install
    installdir="/opt"              # {Update me if needed} Install Location
    bindir="${installdir}/${app^}" # Full Path to Install Location
    datadir="/var/lib/$app/"       # {Update me if needed} AppData directory to use
    app_bin=${app^}                # Binary Name of the app

    echo "This will install [${app^}] to [$bindir] and use [$datadir] for the AppData Directory"

    echo "Stoping the App if running"
    if service --status-all | grep -Fq "$app"; then
        systemctl stop "$app"
        systemctl disable "$app".service
        echo "Stopped existing $app."
    fi

    echo "Create Appdata Directories"
    mkdir -p "$datadir"
    chown -R "$APP_UID":"$APP_GUID" "$datadir"
    chmod 775 "$datadir"
    echo -e "Directories $bindir and $datadir created!"

    echo "Download and install the App"
    ARCH=$(dpkg --print-architecture)
    dlbase="https://$app.servarr.com/v1/update/$branch/updatefile?os=linux&runtime=netcore"
    case "$ARCH" in
    "amd64") DLURL="${dlbase}&arch=x64" ;;
    "armhf") DLURL="${dlbase}&arch=arm" ;;
    "arm64") DLURL="${dlbase}&arch=arm64" ;;
    *)
        echo -e "Your arch is not supported!"
        echo -e "Exiting installer script!"
        exit 1
        ;;
    esac

    echo -e "Removing tarballs..."
    sleep 3
    rm -f "${app^}".*.tar.gz
    echo -e "Downloading required files..."
    wget --inet4-only --content-disposition "$DLURL"
    tar -xvzf "${app^}".*.tar.gz >/dev/null 2>&1
    echo -e "Installation files downloaded and extracted!"

    echo -e "Removing existing installation files from $bindir]"
    rm -rf "$bindir"
    sleep 2
    echo -e "Attempting to install ${app^}..."
    sleep 2
    mv "${app^}" $installdir
    chown "$APP_UID":"$APP_GUID" -R "$bindir"
    chmod 775 "$bindir"
    touch "$datadir"/update_required
    chown "$APP_UID":"$APP_GUID" "$datadir"/update_required
    echo -e "Successfully installed ${app^}!!"
    rm -rf "${app^}.*.tar.gz"
    sleep 2

    echo "Removing old service file..."
    rm -rf /etc/systemd/system/"$app".service
    sleep 2

    echo "Creating new service file..."
    cat <<EOF | tee /etc/systemd/system/"$app".service >/dev/null
    [Unit]
    Description=${app^} Daemon
    After=syslog.target network.target
    [Service]
    User=$APP_UID
    Group=$APP_GUID
    UMask=$app_umask
    Type=simple
    ExecStart=$bindir/$app_bin -nobrowser -data=$datadir
    TimeoutStopSec=20
    KillMode=process
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
EOF
    sleep 2

    echo -e "${app^} is attempting to start, this may take a few seconds..."
    systemctl -q daemon-reload
    systemctl enable --now -q "$app"
    sleep 5

    echo "Checking if the service is up and running..."
    while ! systemctl is-active --quiet "$app"; do
        sleep 5
    done

    sed -i "s/>7878</>$app_port</" "$datadir"config.xml
    systemctl restart -q $app

    echo -e "${app^} installation and service start up is complete!"
    echo -e "Attempting to check for a connection at http://$IP_LOCAL:$app_port..."
    sleep 15

    STATUS="$(systemctl is-active "$app")"
    if [ "${STATUS}" = "active" ]; then
        RADARR_APIKEY=$(grep "ApiKey" "$datadir/config.xml" | cut -d '>' -f 2 | cut -d '<' -f 1)

        if grep "api_key" "/home/$APP_UID/.sabnzbd/sabnzbd.ini" ; then        
            SABNZBD_APIKEY=$(grep "api_key" "/home/$APP_UID/.sabnzbd/sabnzbd.ini" | cut -d "=" -f 2 | xargs)
            
            if [ "$INSTALL_SABNZBD" == "true" ] ; then
                echo "Adding Download Client SABNZBd:"
                curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$RADARR_PORT/api/v3/downloadclient" --data '{"enable":true,"protocol":"usenet","priority":1,"removeCompletedDownloads":true,"removeFailedDownloads":true,"name":"SABnzbd","fields":[{"order":0,"name":"host","label":"Host","value":"localhost","type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":1,"name":"port","label":"Port","value":'"$SABNZBD_PORT"',"type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":2,"name":"useSsl","label":"Use SSL","helpText":"Use secure connection when connection to Sabnzbd","value":false,"type":"checkbox","advanced":false,"privacy":"normal","isFloat":false},{"order":3,"name":"urlBase","label":"URL Base","helpText":"Adds a prefix to the Sabnzbd url, such as http://[host]:[port]/[urlBase]/api","type":"textbox","advanced":true,"privacy":"normal","isFloat":false},{"order":4,"name":"apiKey","label":"API Key","value":"'"$SABNZBD_APIKEY"'","type":"textbox","advanced":false,"privacy":"apiKey","isFloat":false},{"order":5,"name":"username","label":"Username","value":"admin","type":"textbox","advanced":false,"privacy":"userName","isFloat":false},{"order":6,"name":"password","label":"Password","value":"password","type":"password","advanced":false,"privacy":"password","isFloat":false},{"order":7,"name":"tvCategory","label":"Category","helpText":"Adding a category specific to Sonarr avoids conflicts with unrelated non-Sonarr downloads. Using a category is optional, but strongly recommended.","value":"sonarr","type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":8,"name":"recentTvPriority","label":"Recent Priority","helpText":"Priority to use when grabbing episodes that aired within the last 14 days","value":-100,"type":"select","advanced":false,"selectOptions":[{"value":-100,"name":"Default","order":-100},{"value":-2,"name":"Paused","order":-2},{"value":-1,"name":"Low","order":-1},{"value":0,"name":"Normal","order":0},{"value":1,"name":"High","order":1},{"value":2,"name":"Force","order":2}],"privacy":"normal","isFloat":false},{"order":9,"name":"olderTvPriority","label":"Older Priority","helpText":"Priority to use when grabbing episodes that aired over 14 days ago","value":-100,"type":"select","advanced":false,"selectOptions":[{"value":-100,"name":"Default","order":-100},{"value":-2,"name":"Paused","order":-2},{"value":-1,"name":"Low","order":-1},{"value":0,"name":"Normal","order":0},{"value":1,"name":"High","order":1},{"value":2,"name":"Force","order":2}],"privacy":"normal","isFloat":false}],"implementationName":"SABnzbd","implementation":"Sabnzbd","configContract":"SabnzbdSettings","infoLink":"https://wiki.servarr.com/sonarr/supported#sabnzbd","tags":[]}'
            fi
        fi

        if [ "$INSTALL_DELUGE" == "true" ] ; then
            echo "Adding Download Client Deluge:"
            curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$RADARR_PORT/api/v3/downloadclient" --data '{ "enable": true, "protocol": "torrent", "priority": 1, "removeCompletedDownloads": true, "removeFailedDownloads": true, "name": "Deluge", "fields": [ { "order": 0, "name": "host", "label": "Host", "value": "localhost", "type": "textbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 1, "name": "port", "label": "Port", "value": '"$DELUGE_PORT"', "type": "textbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 2, "name": "useSsl", "label": "Use SSL", "helpText": "Use secure connection when connection to Deluge", "value": false, "type": "checkbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 3, "name": "urlBase", "label": "URL Base", "helpText": "Adds a prefix to the deluge json url, see http://[host]:[port]/[urlBase]/json", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false }, { "order": 4, "name": "password", "label": "Password", "value": "'"$DELUGE_PASSWORD"'", "type": "password", "advanced": false, "privacy": "password", "isFloat": false }, { "order": 5, "name": "tvCategory", "label": "Category", "helpText": "Adding a category specific to Sonarr avoids conflicts with unrelated non-Sonarr downloads. Using a category is optional, but strongly recommended.", "value": "sonarr", "type": "textbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 6, "name": "tvImportedCategory", "label": "Post-Import Category", "helpText": "Category for Sonarr to set after it has imported the download. Sonarr will not remove torrents in that category even if seeding finished. Leave blank to keep same category.", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false }, { "order": 7, "name": "recentTvPriority", "label": "Recent Priority", "helpText": "Priority to use when grabbing episodes that aired within the last 14 days", "value": 0, "type": "select", "advanced": false, "selectOptions": [ { "value": 0, "name": "Last", "order": 0 }, { "value": 1, "name": "First", "order": 1 } ], "privacy": "normal", "isFloat": false }, { "order": 8, "name": "olderTvPriority", "label": "Older Priority", "helpText": "Priority to use when grabbing episodes that aired over 14 days ago", "value": 0, "type": "select", "advanced": false, "selectOptions": [ { "value": 0, "name": "Last", "order": 0 }, { "value": 1, "name": "First", "order": 1 } ], "privacy": "normal", "isFloat": false }, { "order": 9, "name": "addPaused", "label": "Add Paused", "value": false, "type": "checkbox", "advanced": false, "privacy": "normal", "isFloat": false }, { "order": 10, "name": "downloadDirectory", "label": "Download Directory", "helpText": "Optional location to put downloads in, leave blank to use the default Deluge location", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false }, { "order": 11, "name": "completedDirectory", "label": "Move When Completed Directory", "helpText": "Optional location to move completed downloads to, leave blank to use the default Deluge location", "type": "textbox", "advanced": true, "privacy": "normal", "isFloat": false } ], "implementationName": "Deluge", "implementation": "Deluge", "configContract": "DelugeSettings", "infoLink": "https://wiki.servarr.com/sonarr/supported#deluge", "tags": []}'
        fi

        echo "Adding Indexers:"
        NUM_INDEXERS=$(echo "$INDEXERS" | jq length)

        for ((i = 0; i < NUM_INDEXERS; i++)) ; do
            INDEXER_NAME=$(echo $INDEXERS | jq ".[$i].INDEXER_NAME")
            INDEXER_URL=$(echo $INDEXERS | jq ".[$i].INDEXER_URL")		                
            INDEXER_API_PATH=$(echo $INDEXERS | jq ".[$i].INDEXER_API_PATH")							
            INDEXER_APIKEY=$(echo $INDEXERS | jq ".[$i].INDEXER_APIKEY")
            curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$RADARR_PORT/api/v3/indexer" --data '{"enableRss":true,"enableAutomaticSearch":true,"enableInteractiveSearch":true,"supportsRss":true,"supportsSearch":true,"protocol":"usenet","priority":25,"seasonSearchMaximumSingleEpisodeAge":0,"downloadClientId":0,"name":'$INDEXER_NAME',"fields":[{"order":0,"name":"baseUrl","label":"URL","value":'$INDEXER_URL',"type":"textbox","advanced":false,"privacy":"normal","isFloat":false},{"order":1,"name":"apiPath","label":"API Path","helpText":"Path to the api, usually /api","value":'$INDEXER_API_PATH',"type":"textbox","advanced":true,"privacy":"normal","isFloat":false},{"order":2,"name":"apiKey","label":"API Key","value":'$INDEXER_APIKEY',"type":"textbox","advanced":false,"privacy":"apiKey","isFloat":false},{"order":3,"name":"categories","label":"Categories","helpText":"Drop down list, leave blank to disable standard/daily shows","value":[2030,2040,2045,2050],"type":"select","advanced":false,"selectOptionsProviderAction":"newznabCategories","privacy":"normal","isFloat":false},{"order":4,"name":"animeCategories","label":"Anime Categories","helpText":"Drop down list, leave blank to disable anime","value":[5030,5040,5070],"type":"select","advanced":false,"selectOptionsProviderAction":"newznabCategories","privacy":"normal","isFloat":false},{"order":5,"name":"animeStandardFormatSearch","label":"Anime Standard Format Search","helpText":"Also search for anime using the standard numbering","value":false,"type":"checkbox","advanced":false,"privacy":"normal","isFloat":false},{"order":6,"name":"additionalParameters","label":"Additional Parameters","helpText":"Please note if you change the category you will have to add required/restricted rules about the subgroups to avoid foreign language releases.","type":"textbox","advanced":true,"privacy":"normal","isFloat":false},{"order":7,"name":"multiLanguages","label":"Multi Languages","helpText":"What languages are normally in a multi release on this indexer?","value":[],"type":"select","advanced":true,"selectOptions":[{"value":-2,"name":"Original","order":0},{"value":26,"name":"Arabic","order":0},{"value":41,"name":"Bosnian","order":0},{"value":28,"name":"Bulgarian","order":0},{"value":38,"name":"Catalan","order":0},{"value":10,"name":"Chinese","order":0},{"value":39,"name":"Croatian","order":0},{"value":25,"name":"Czech","order":0},{"value":6,"name":"Danish","order":0},{"value":7,"name":"Dutch","order":0},{"value":1,"name":"English","order":0},{"value":42,"name":"Estonian","order":0},{"value":16,"name":"Finnish","order":0},{"value":19,"name":"Flemish","order":0},{"value":2,"name":"French","order":0},{"value":4,"name":"German","order":0},{"value":20,"name":"Greek","order":0},{"value":23,"name":"Hebrew","order":0},{"value":27,"name":"Hindi","order":0},{"value":22,"name":"Hungarian","order":0},{"value":9,"name":"Icelandic","order":0},{"value":44,"name":"Indonesian","order":0},{"value":5,"name":"Italian","order":0},{"value":8,"name":"Japanese","order":0},{"value":21,"name":"Korean","order":0},{"value":36,"name":"Latvian","order":0},{"value":24,"name":"Lithuanian","order":0},{"value":45,"name":"Macedonian","order":0},{"value":29,"name":"Malayalam","order":0},{"value":15,"name":"Norwegian","order":0},{"value":37,"name":"Persian","order":0},{"value":12,"name":"Polish","order":0},{"value":18,"name":"Portuguese","order":0},{"value":33,"name":"Portuguese (Brazil)","order":0},{"value":35,"name":"Romanian","order":0},{"value":11,"name":"Russian","order":0},{"value":40,"name":"Serbian","order":0},{"value":31,"name":"Slovak","order":0},{"value":46,"name":"Slovenian","order":0},{"value":3,"name":"Spanish","order":0},{"value":34,"name":"Spanish (Latino)","order":0},{"value":14,"name":"Swedish","order":0},{"value":43,"name":"Tamil","order":0},{"value":32,"name":"Thai","order":0},{"value":17,"name":"Turkish","order":0},{"value":30,"name":"Ukrainian","order":0},{"value":13,"name":"Vietnamese","order":0}],"privacy":"normal","isFloat":false}],"implementationName":"Newznab","implementation":"Newznab","configContract":"NewznabSettings","infoLink":"https://wiki.servarr.com/sonarr/supported#newznab","tags":[]}'
        done

        echo "Adding Root Folders:"
        for FOLDER in ${RADARR_ROOT_FOLDER[@]}; do
            mkdir -p $FOLDER
            chown -R "$APP_UID":"$APP_GUID" $FOLDER
            chmod 775 "$FOLDER"
            
            curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X POST "http://$IP_LOCAL:$RADARR_PORT/api/v3/rootfolder" --data '{"path":"'"$FOLDER"'","accessible":true,"freeSpace":0,"unmappedFolders":[]}'
        done
        
        echo "Setting more sensible quality values"
        QUALITIES=$(curl -s -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X GET "http://$IP_LOCAL:$RADARR_PORT/api/v3/qualitydefinition")

        QUALITY_MAP='{"Unknown":{"minSize":0,"maxSize":25,"preferredSize":20},"WORKPRINT":{"minSize":0,"maxSize":25,"preferredSize":20},"CAM":{"minSize":0,"maxSize":25,"preferredSize":20},"TELESYNC":{"minSize":0,"maxSize":25,"preferredSize":20},"TELECINE":{"minSize":0,"maxSize":25,"preferredSize":20},"REGIONAL":{"minSize":0,"maxSize":25,"preferredSize":20},"DVDSCR":{"minSize":0,"maxSize":25,"preferredSize":20},"SDTV":{"minSize":0,"maxSize":25,"preferredSize":20},"DVD":{"minSize":0,"maxSize":25,"preferredSize":20},"DVD-R":{"minSize":0,"maxSize":25,"preferredSize":20},"WEBDL-480p":{"minSize":0,"maxSize":25,"preferredSize":20},"WEBRip-480p":{"minSize":0,"maxSize":25,"preferredSize":20},"Bluray-480p":{"minSize":0,"maxSize":25,"preferredSize":20},"Bluray-576p":{"minSize":0,"maxSize":25,"preferredSize":20},"HDTV-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBDL-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBRip-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"Bluray-720p":{"minSize":0,"maxSize":50,"preferredSize":20},"HDTV-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBDL-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"WEBRip-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"Bluray-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"Remux-1080p":{"minSize":0,"maxSize":50,"preferredSize":20},"HDTV-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"WEBDL-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"WEBRip-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"Bluray-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"Remux-2160p":{"minSize":0,"maxSize":80,"preferredSize":20},"BR-DISK":{"minSize":0,"maxSize":80,"preferredSize":20},"Raw-HD":{"minSize":0,"maxSize":80,"preferredSize":20}}'
        NUM_QUALITIES=$(echo "$QUALITIES" | jq length)

        for ((i = 0; i < NUM_QUALITIES; i++)) ; do

            QUALITY_NAME=$(echo $QUALITIES | jq ".[$i].title" ) 
            QUALITY=$(echo $QUALITIES | jq ".[$i]" ) 

            MINSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.minSize")  
            MAXSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.maxSize")  
            PREFSIZE=$(echo $QUALITY_MAP | jq ".$QUALITY_NAME.preferredSize")

            if [ "$MINSIZE" != "null" ] ; then
                    QUALITY=$(echo $QUALITY | jq ".minSize=$MINSIZE | .maxSize=$MAXSIZE | .preferredSize=$PREFSIZE")
            fi

            curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$RADARR_PORT/api/v3/qualitydefinition" --data "${QUALITY}"
        done

        echo "Setting permissions settings"
        curl -H "Content-Type: application/json" -H "X-Api-Key: $RADARR_APIKEY" -H "accept: application/json" -X PUT "http://$IP_LOCAL:$RADARR_PORT/api/v3/config/mediamanagement"  --data '{"autoUnmonitorPreviouslyDownloadedMovies":false,"recycleBin":"","recycleBinCleanupDays":7,"downloadPropersAndRepacks":"preferAndUpgrade","createEmptyMovieFolders":false,"deleteEmptyFolders":true,"fileDate":"none","rescanAfterRefresh":"always","autoRenameFolders":true,"pathsDefaultStatic":false,"setPermissionsLinux":true,"chmodFolder":"755","chownGroup":"'"$APP_GUID"'","skipFreeSpaceCheckWhenImporting":false,"minimumFreeSpaceWhenImporting":100,"copyUsingHardlinks":true,"useScriptImport":false,"scriptImportPath":"","importExtraFiles":true,"extraFileExtensions":"srt","enableMediaInfo":true,"id":1}'

        RADARR_URL="http://$IP_LOCAL:$app_port"
        echo "Browse to $RADARR_URL for the ${app^} GUI"
    else
        echo "${app^} failed to start"
    fi
    echo "Installled Radarr"
fi

#Plex Media Server
if [ "$INSTALL_PLEX_SERVER" == "true" ] ; then
    echo "-----------------------------Installing Plex-----------------------------"

    INTEL_GPU=$(lspci -k | grep -EA3 'VGA|3D|Display' | grep "Intel" | xargs)
        
    if [ "$INTEL_GPU" != "" ]; then
        DISTRO=$(lsb_release -i | grep "Distributor" | cut -d ':' -f 2 | xargs | cut -d '.' -f 1)

        if [ "$DISTRO" == "Ubuntu" ]; then
            VERSION=$(lsb_release -r | grep "Release" | cut -d ':' -f 2 | xargs)

            echo Intel GPU detected on $DISTRO $VERSION

            if [ "$VERSION" == "22.04" ]; then
                wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
                echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list
                apt update
                apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-22.04
            elif [ "$VERSION" == "24.04" ]; then
                wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
                echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | tee /etc/apt/sources.list.d/intel-gpu-noble.list
                sudo apt update
                apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-24.04
            fi
        fi
    fi

    curl -s https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
    echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
    apt update
    apt install plexmediaserver -y
    echo "Waiting for Plex to start:"
    
    sleep 10
    echo "Setting Plex permissions:"
    usermod -a -G $APP_GUID plex
    systemctl restart plexmediaserver
    
    PLEX_URL="http://$IP_LOCAL:32400"
    echo "Installled Plex"
fi

#Install Uptime Kuma
if [ "$INSTALL_UPTIME_KUMA" == "true" ] ; then
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

    if [ "$INSTALL_ZEROTIER" == "true" ] || [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.PING, name='Zerotier', hostname=\"192.168.194.1\")" >> init.py
    fi
    if [ "$INSTALL_PIHOLE" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='PiHole UI', url=\"http://localhost/admin\")" >> init.py
        echo "  api.add_monitor(type=MonitorType.DNS, name='PiHole DNS', hostname=\"google.com\")" >> init.py
    fi
    if [ "$INSTALL_HASS" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='Home Assistant', url=\"http://localhost:8123\")" >> init.py
    fi
    if [ "$INSTALL_LIBRE_SPEEDTEST" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='Libre Speed Test', url=\"http://localhost:$LIBREST_PORT\")" >> init.py
    fi
    if [ "$INSTALL_SABNZBD" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='SABNZBd', url=\"http://localhost:$SABNZBD_PORT\")" >> init.py
    fi
    if [ "$INSTALL_DELUGE" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='Deluge', url=\"http://localhost:$DELUGE_PORT\")" >> init.py
    fi
    if [ "$INSTALL_SONARR" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='Sonarr', url=\"http://localhost:$SONARR_PORT\")" >> init.py
    fi
    if [ "$INSTALL_RADARR" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='Radarr', url=\"http://localhost:$RADARR_PORT\")" >> init.py
    fi
    if [ "$INSTALL_PLEX_SERVER" == "true" ] ; then
        echo "  api.add_monitor(type=MonitorType.HTTP, name='Plex', url=\"http://localhost:32400/web\")" >> init.py
    fi

    echo "  api.disconnect()" >> init.py
    echo "except:" >> init.py
    echo "  pass" >> init.py
    
    echo "Configuring Monitors"
    python3 ./init.py
    rm ./init.py

    cd $CUR_DIR
    KUMA_URL="http://$IP_LOCAL:$KUMA_PORT"
    echo "Installed Uptime Kuma"
fi

#Windows Shares
if [ "$INSTALL_SHARES" == "true" ] ; then
    echo "-----------------------------Installing Windows Shares-----------------------------"

    apt install cifs-utils -y

    for SHARE in ${WIN_SHARES[@]}; do
        mkdir -p /mnt/$SHARE

        cat <<EOF | tee /etc/systemd/system/mnt-$SHARE.mount >/dev/null
        [Unit]
        Description=//$WIN_HOST/$SHARE

        [Mount]
        What=//$WIN_HOST/$SHARE
        Where=/mnt/$SHARE
        Type=cifs
        Options=user=$WIN_USER,password=$WIN_PASS,uid=$APP_UID,gid=$APP_GUID

        [Install]
        WantedBy=multi-user.target
EOF

        cat <<EOF | tee /etc/systemd/system/mnt-$SHARE.automount >/dev/null
        [Unit]
        Description=Automount //$WIN_HOST/$SHARE
        Requires=network-online.target

        [Automount]
        Where=/mnt/$SHARE

        [Install]
        WantedBy=multi-user.target
EOF

        systemctl start mnt-$SHARE.mount
        systemctl enable mnt-$SHARE.automount

        ln -s /mnt/$SHARE /home/$SUDO_USER/Desktop
    done

    echo "Installled Windows Shares"
fi

#Shell Extensions
if [ "$INSTALL_SHELL_EXTENSIONS" == "true" ] ; then
    echo "-----------------------------Installing Shell Extensions-----------------------------"
    apt install gnome-menus dbus-x11 -y

    for i in "${EXTENSION_LIST[@]}" ; do
        EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
        SEARCH_ID=$(echo $EXTENSION_ID | cut -d '@' -f 1)
        VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$SEARCH_ID" | jq '.extensions | map(select(.uuid=="'$EXTENSION_ID'")) | .[0].shell_version_map."'$GNOME_VERSION'".pk')

        echo "Installing: $EXTENSION_ID"

        wget --inet4-only -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
        sudo -u $SUDO_USER -H -s gnome-extensions install --force ${EXTENSION_ID}.zip
        sudo -u $SUDO_USER -H -s gnome-extensions enable ${EXTENSION_ID}
        rm ${EXTENSION_ID}.zip
    done

    if [ "$EXTENSION_SETTINGS" == "default" ] ; then
        echo "No extension settings configured"
    else
        echo "Loading extension settings"
        echo $EXTENSION_SETTINGS | base64 -d | gunzip >> /home/$SUDO_USER/extension_settings.conf

        sudo  -i -u $SUDO_USER bash <<-EOF
        cat /home/$SUDO_USER/extension_settings.conf | dconf load /org/gnome/
EOF

        rm /home/$SUDO_USER/extension_settings.conf
    fi

    echo "Installled Shell Extensions"
fi

#Rustdesk Client
if [ "$INSTALL_RUSTDESK_CLIENT" == "true" ] ; then
    echo "-----------------------------Installing Rustdesk Client-----------------------------"
    apt install xserver-xorg-video-all -y

    wget https://github.com/rustdesk/rustdesk/releases/download/1.3.2/rustdesk-1.3.2-x86_64.deb
    apt-get install -fy ./rustdesk-1.3.2-x86_64.deb > null

    # Apply new password to RustDesk
    rustdesk --password $RUSTDESK_PASS &> /dev/null
    rustdesk --config $RUSTDESK_CFG
    systemctl restart rustdesk

    sed -i "s/#WaylandEnable=false/WaylandEnable=false/" "/etc/gdm3/custom.conf"
    echo "Installed Rustdesk Client"
fi

echo "----------------------------------------------------------------------------------"
echo " "
echo "Completed Installing Items"
echo " "
echo "Access Details:"

if [ "$INSTALL_UPTIME_KUMA" == "true" ] ; then
    echo "Uptime Kuma: $KUMA_URL"
fi
if [ "$INSTALL_HASS" == "true" ] ; then
    echo "Home Assistant: http://$IP_LOCAL:8123"
fi
if [ "$INSTALL_LIBRE_SPEEDTEST" == "true" ] ; then
    echo "Libre Speed Test: http://$IP_LOCAL:$LIBREST_PORT"
fi
if [ "$INSTALL_PIHOLE" == "true" ] ; then
    echo "PiHole: http://$IP_LOCAL/admin"
fi
if [ "$INSTALL_SABNZBD" == "true" ] ; then
    echo "SABNZBd: $SABNZBD_URL"
fi
if [ "$INSTALL_DELUGE" == "true" ] ; then
    echo "Deluge: $DELUGE_URL"
fi
if [ "$INSTALL_SONARR" == "true" ] ; then
    echo "Sonarr: $SONARR_URL"
fi
if [ "$INSTALL_RADARR" == "true" ] ; then
    echo "Radarr: $RADARR_URL"
fi
if [ "$INSTALL_PLEX_SERVER" == "true" ] ; then
    echo "Plex: $PLEX_URL/web"
fi
echo ""
if [ "$INSTALL_SHARES" == "true" ] ; then
    echo "SMB: $SMB_URL"
    echo "User: $REMOTE_USER"
    echo "Password": $REMOTE_PASS
fi

echo " "
echo "Next Steps"

if [ "$INSTALL_RADARR" == "true" ] || [ "$INSTALL_SONARR" == "true" ] ; then
    echo "Sonarr/Radarr:"
    echo "  1. You will need to log into Radarr/Sonarr (if installed) and set a user, password, and auth req to 'not required for local'"
    echo "  2. You will need to import existing media into Radarr/Sonarr"
    echo "  3. Start Plex from the apps menu and setup the server (You will need to manually add the libraries)"
    echo "  4. Mount the Shared folder on your windows/linux machine."
    echo " "
fi

if [ "$INSTALL_PIHOLE" == "true" ] ; then
    echo "Pihole:"
    echo "  1. Change default password (Password): sudo pihole -a -p"
    echo "  2. You will now need to log into your router and configure the DHCP settings to use $IP_LOCAL as the primary DNS server"
    echo " "
fi

if [ "$INSTALL_ZEROTIER" == "true" ] ; then
    echo "Local IP: $IP_LOCAL"
    echo "Zerotier IP: $VIA_IP"
fi

if [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
    echo "Zerotier Router - Optional Zerotier Config:"
    echo "  Joining Two Physical Networks (This allows devices without Zerotier to communicate with each other across networks):"
    echo "  You will need a Zerotier router setup on both ends of the network (IE. You will need to run this script on devices on either end)"
    echo "  If you would like local devices to be able to access a remote Zerotier device's network you will need to add a static route to your router with the following settings:"
    echo "        Network Destination: The destination network IP Range (Ex 192.168.0.0 for devices in range 192.168.0.1 to 192.168.0.254)"
    echo "        Default Gateway: $LOCAL_IP"
    echo "        Network Mask: $NET_MASK"
    echo "        Interface: LAN"
    echo "        Description: Zerotier Route"
    echo " "
fi

if [ "$INSTALL_SHELL_EXTENSIONS" == "true" ] ; then
    echo "Shell Extensions: "
    echo "  You will need to reboot for changes to take effect"
fi

if [ "$INSTALL_RUSTDESK_CLIENT" == "true" ] ; then
    echo "Rust Desk: "
    echo "  You will need to reboot before you will be able to connect"
fi