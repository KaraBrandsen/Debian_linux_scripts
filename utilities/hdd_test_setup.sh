#!/bin/bash

#This script is intended to be used with uptime kuma to check for hardrive failures.

HDD_CHECK_PORT=8092

echo "Installing Nginx"
apt install nginx mysql-server php-curl php-fpm smartmontools -y

rm  /etc/nginx/sites-enabled/hdd-check
rm -rf /etc/nginx/sites-available/hdd-check

echo "Configuring Nginx"
echo "server {" > /etc/nginx/sites-available/hdd-check
echo "    listen $HDD_CHECK_PORT;" >> /etc/nginx/sites-available/hdd-check
echo "    server_name hdd-check www.hdd-check;" >> /etc/nginx/sites-available/hdd-check
echo "    root /var/www/html/hdd-check;" >> /etc/nginx/sites-available/hdd-check
echo "" >> /etc/nginx/sites-available/hdd-check
echo "    index index.html index.htm index.php;" >> /etc/nginx/sites-available/hdd-check
echo "" >> /etc/nginx/sites-available/hdd-check
echo "    location / {" >> /etc/nginx/sites-available/hdd-check
echo '        try_files $uri $uri/ =404;' >> /etc/nginx/sites-available/hdd-check
echo "    }" >> /etc/nginx/sites-available/hdd-check
echo "" >> /etc/nginx/sites-available/hdd-check
echo "    location ~ \.php$ {" >> /etc/nginx/sites-available/hdd-check
echo "        include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/hdd-check
echo "        fastcgi_pass unix:/var/run/php/php-fpm.sock;" >> /etc/nginx/sites-available/hdd-check
echo "    }" >> /etc/nginx/sites-available/hdd-check
echo "" >> /etc/nginx/sites-available/hdd-check
echo "    location ~ /\.ht {" >> /etc/nginx/sites-available/hdd-check
echo "        deny all;" >> /etc/nginx/sites-available/hdd-check
echo "    }" >> /etc/nginx/sites-available/hdd-check
echo "" >> /etc/nginx/sites-available/hdd-check
echo "}" >> /etc/nginx/sites-available/hdd-check

ln -s /etc/nginx/sites-available/hdd-check /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default

systemctl reload nginx

rm -rf /var/www/html/hdd-check/
mkdir -p /var/www/html/hdd-check
chown -R $SUDO_USER:$SUDO_USER /var/www/html/hdd-check

echo "www-data ALL=NOPASSWD: /home/$SUDO_USER/hdd_test.sh" >> /etc/sudoers

echo "#!/bin/bash" > /home/$SUDO_USER/hdd_test.sh
echo "ARG=\${1:-"sda"}" >> /home/$SUDO_USER/hdd_test.sh
echo "smartctl -H -j /dev/\$ARG" >> /home/$SUDO_USER/hdd_test.sh

chmod +x /home/$SUDO_USER/hdd_test.sh

cat <<EOF | tee /var/www/html/hdd-check/index.php >/dev/null
<?PHP
    if(isset(\$_GET["hdd"])){
        \$blk = shell_exec("lsblk -o NAME");

        if(str_contains(\$blk, \$_GET["hdd"])){
            echo shell_exec("sudo /home/$SUDO_USER/hdd_test.sh " . \$_GET["hdd"]);
        }
        else{
            echo '{"error":"HDD not found"}';
        }
    }
    else{
        echo shell_exec("sudo /home/$SUDO_USER/hdd_test.sh");
    }
?>
EOF
