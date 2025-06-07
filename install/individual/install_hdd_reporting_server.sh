#!/bin/bash

#This script is intended to be used with uptime kuma to check for hardrive failures.
SCRIPT_DIR=../utilities/smart_data_collection.sh

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Common Scripts
    source "../common/common_variables.sh"
    SCRIPT_DIR=../../utilities/smart_data_collection.sh
fi

HDD_CHECK_PORT=8092
TARGET_DIR=/opt/smart_monitor  

echo "Installing Nginx"
apt install nginx mysql-server php-curl php-fpm smartmontools -y

rm  /etc/nginx/sites-enabled/hdd-check
rm -rf /etc/nginx/sites-available/hdd-check

echo "Configuring Nginx"

cat <<EOF | tee /etc/nginx/sites-available/hdd-check >/dev/null
server {
    listen $HDD_CHECK_PORT;
    server_name hdd-check www.hdd-check;
    root /var/www/html/hdd-check;

    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/hdd-check /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default

systemctl reload nginx

if [ ! -f "$TARGET_DIR/smart_data_collection.sh" ] ; then
    mkdir -p $TARGET_DIR

    cp "$SCRIPT_DIR" "$TARGET_DIR/smart_data_collection.sh"
    chmod +x "$TARGET_DIR/smart_data_collection.sh"
fi

echo Installing Crontab for long running commands.
crontab -l > root_cron

if grep -F "$TARGET_DIR/smart_data_collection.sh" root_cron ; then
    echo "Existing Cron job found for SMART Monitor"
else
    echo "0 */1 * * * $TARGET_DIR/smart_data_collection.sh >> $TARGET_DIR/log.txt 2>&1" >> root_cron
    echo "@reboot $TARGET_DIR/smart_data_collection.sh >> $TARGET_DIR/log.txt 2>&1" >> root_cron
fi

echo ./$TARGET_DIR/smart_data_collection.sh show

crontab root_cron
rm root_cron

echo Setting up PHP script
rm -rf /var/www/html/hdd-check/
mkdir -p /var/www/html/hdd-check
chown -R $SUDO_USER:$SUDO_USER /var/www/html/hdd-check

echo "www-data ALL=NOPASSWD: /home/$SUDO_USER/hdd_test.sh" >> /etc/sudoers

echo "#!/bin/bash" > /home/$SUDO_USER/hdd_test.sh
echo "ARG=\${1:-"sda"}" >> /home/$SUDO_USER/hdd_test.sh
echo "cat $TARGET_DIR/hdd_\$ARG.status" >> /home/$SUDO_USER/hdd_test.sh

chmod +x /home/$SUDO_USER/hdd_test.sh

cat <<EOF | tee /var/www/html/hdd-check/index.php >/dev/null
<?PHP
    \$ret_val = '{"error":"HDD not found"}';

    if(isset(\$_GET["hdd"])){
        \$blk = shell_exec("lsblk -o NAME");

        if(str_contains(\$blk, \$_GET["hdd"])){
            \$ret_val = shell_exec("sudo /home/$SUDO_USER/hdd_test.sh " . \$_GET["hdd"]);
        }
    }
    else{
        \$ret_val = shell_exec("sudo /home/$SUDO_USER/hdd_test.sh");
    }

    echo json_encode(json_decode(\$ret_val), JSON_PRETTY_PRINT);
?>
EOF
