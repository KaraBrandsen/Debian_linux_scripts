#!/bin/bash

DELUGE_PORT=8112
APP_UID=$SUDO_USER
APP_GUID=users

HOST=$(hostname -I)
IP_LOCAL=$(grep -oP '^\S*' <<<"$HOST")

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