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

    #ConvertX
        CONVERTX_PORT=8100                                      #Port to be used for the ConvertX Web Interface

    #Stirling PDF
        STIRLING_PDF_PORT=8101                                  #Port to be used for the Stirling PDF Web Interface

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
    INSTALL_DOCKER=true                     #Install Docker - set to false to skip
    INSTALL_CONVERTX=false                  #Install ConvertX - set to false to skip
    INSTALL_STIRLING_PDF=false              #Install Stirling PDF - set to false to skip
    INSTALL_GLANCES=true                    #Install Glances - set to false to skip
    INSTALL_CUSTOM_MOTD=true                #Install a custom greeting when logging in via SSH - set to false to skip
    
    source "../fixes/radxa_x4_emmc_nqc_fix.sh"
    source "../fixes/inconsistent_file_system_prompt_fix.sh"

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
    INSTALL_DOCKER=true                     #Install Docker - set to false to skip
    INSTALL_CONVERTX=true                  #Install ConvertX - set to false to skip
    INSTALL_STIRLING_PDF=true              #Install Stirling PDF - set to false to skip
    INSTALL_GLANCES=true                    #Install Glances - set to false to skip
    INSTALL_CUSTOM_MOTD=true                #Install a custom greeting when logging in via SSH - set to false to skip

    source "../fixes/inconsistent_file_system_prompt_fix.sh"
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
    INSTALL_DOCKER=true                     #Install Docker - set to false to skip
    INSTALL_CONVERTX=false                  #Install ConvertX - set to false to skip
    INSTALL_STIRLING_PDF=false              #Install Stirling PDF - set to false to skip
    INSTALL_GLANCES=true                    #Install Glances - set to false to skip
    INSTALL_CUSTOM_MOTD=true                #Install a custom greeting when logging in via SSH - set to false to skip

    if ! command -v gnome-shell 2>&1 >/dev/null ; then
        apt install flatpak piper gir1.2-gtop-2.0 lm-sensors gparted -y
    else
        apt install flatpak gnome-software-plugin-flatpak gnome-shell-extension-manager piper gir1.2-gtop-2.0 lm-sensors gnome-tweaks gparted -y
    fi

    source "../fixes/intel_gpu_hw_transcoding_fix.sh"

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

        flatpak install flathub com.discordapp.Discord org.videolan.VLC com.spotify.Client org.gimp.GIMP org.libreoffice.LibreOffice io.github.mimbrero.WhatsAppDesktop org.signal.Signal org.inkscape.Inkscape com.slack.Slack com.adobe.Reader tv.plex.PlexDesktop cc.arduino.IDE2 org.raspberrypi.rpi-imager com.ultimaker.cura io.github.prateekmedia.appimagepool org.kicad.KiCad org.gnome.meld org.qbittorrent.qBittorrent com.notepadqq.Notepadqq org.wireshark.Wireshark us.zoom.Zoom com.github.tchx84.Flatseal -y
    else
        INSTALL_SHARES=true
        flatpak install flathub org.videolan.VLC com.spotify.Client org.libreoffice.LibreOffice com.adobe.Reader tv.plex.PlexDesktop io.github.prateekmedia.appimagepool org.gnome.meld org.qbittorrent.qBittorrent com.notepadqq.Notepadqq us.zoom.Zoom com.github.tchx84.Flatseal -y
    fi
fi 

if [ "$INSTALL_STIRLING_PDF" == "true" ] || [ "$INSTALL_CONVERTX" == "true" ] || [ "$INSTALL_HASS" == "true" ] || [ "$INSTALL_GLANCES" == "true" ]; then
    INSTALL_DOCKER=true
fi

#Installing Common Items
apt install curl nano jq cron rsyslog whois iputils-ping bsdmainutils nethogs lolcat figlet gnupg2 build-essential openssh-server git python3-pip pipx python3-dev htop btop net-tools bzip2 ntfs-3g bmon software-properties-common apt-transport-https ca-certificates traceroute -y

#Constants
source "./common/common_variables.sh"

#Disabling IPv6
source "./common/disable_ip_v6.sh"

#Zerotier Setup
if [ "$INSTALL_ZEROTIER" == "true" ] || [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
    source "./individual/install_zerotier.sh"
fi

#Zerotier Router Setup
if [ "$INSTALL_ZEROTIER_ROUTER" == "true" ] ; then
    source "./individual/install_zerotier_router.sh"
fi

#Docker
if [ "$INSTALL_DOCKER" == "true" ] ; then
    source "./individual/install_docker.sh"
fi

#PiHole
if [ "$INSTALL_PIHOLE" == "true" ] ; then
    source "./individual/install_pihole.sh"
fi

#Home Assistant
if [ "$INSTALL_HASS" == "true" ] ; then
    source "./individual/install_hass.sh"
fi

#Libre Speed Test
if [ "$INSTALL_LIBRE_SPEEDTEST" == "true" ] ; then
    source "./individual/install_libre_speed_test.sh"
fi

#MergerFS Setup
if [ "$INSTALL_FILE_SERVER" == "true" ] ; then
    source "./individual/install_file_server.sh"
fi

#SABNZBd
if [ "$INSTALL_SABNZBD" == "true" ] ; then
    source "./individual/install_sabnzbd.sh"
fi

#Deluge
if [ "$INSTALL_DELUGE" == "true" ] ; then
    source "./individual/install_deluge.sh"
fi

#Sonarr
if [ "$INSTALL_SONARR" == "true" ] ; then
    source "./individual/install_sonarr.sh"
fi

#Radarr
if [ "$INSTALL_RADARR" == "true" ] ; then
    source "./individual/install_radarr.sh"
fi

#Plex Media Server
if [ "$INSTALL_PLEX_SERVER" == "true" ] ; then
    source "./individual/install_plex.sh"
fi

#Install Uptime Kuma
if [ "$INSTALL_UPTIME_KUMA" == "true" ] ; then
    source "./individual/install_uptime_kuma.sh"
fi

#Samba Shares
if [ "$INSTALL_SHARES" == "true" ] ; then
    source "./individual/install_samba_shares.sh"
fi

#Shell Extensions
if [ "$INSTALL_SHELL_EXTENSIONS" == "true" ] ; then
    source "./individual/install_shell_extensions.sh"
fi

#Rustdesk Client
if [ "$INSTALL_RUSTDESK_CLIENT" == "true" ] ; then
    source "./individual/install_rustdesk_client.sh"
fi

#ConvertX
if [ "$INSTALL_CONVERTX" == "true" ] ; then
    source "./individual/install_convertx.sh"
fi

#Stirling PDF
if [ "$INSTALL_STIRLING_PDF" == "true" ] ; then
    source "./individual/install_stirling_pdf.sh"
fi

#Glances
if [ "$INSTALL_GLANCES" == "true" ] ; then
    source "./individual/install_glances.sh"
fi

#Install MOTD
if [ "$INSTALL_CUSTOM_MOTD" == "true" ] ; then
    source "./individual/install_motd.sh"
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
if [ "$INSTALL_CONVERTX" == "true" ] ; then
    echo "ConvertX: http://$IP_LOCAL:$CONVERTX_PORT"

    if [ "$INSTALL_ZEROTIER" == "true" ] ; then
       echo "          http://$VIA_IP:$CONVERTX_PORT"
    fi
fi
if [ "$INSTALL_STIRLING_PDF" == "true" ] ; then
    echo "Stirling PDF: http://$IP_LOCAL:$STIRLING_PDF_PORT"

    if [ "$INSTALL_ZEROTIER" == "true" ] ; then
       echo "              http://$VIA_IP:$STIRLING_PDF_PORT"
    fi
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