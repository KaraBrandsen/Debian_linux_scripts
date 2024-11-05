#!/bin/bash

EXIT_NODE_CHECK_PORT=8091
EXIT_NODE_TEST_URL="ipinfo.io"

echo "Installing Nginx"
apt install nginx mysql-server php-curl php-fpm -y

rm  /etc/nginx/sites-enabled/exit-node-check
rm -rf /etc/nginx/sites-available/exit-node-check

echo "Configuring Nginx"
echo "server {" > /etc/nginx/sites-available/exit-node-check
echo "    listen $EXIT_NODE_CHECK_PORT;" >> /etc/nginx/sites-available/exit-node-check
echo "    server_name exit-node-check www.exit-node-check;" >> /etc/nginx/sites-available/exit-node-check
echo "    root /var/www/html/exit-node-check;" >> /etc/nginx/sites-available/exit-node-check
echo "" >> /etc/nginx/sites-available/exit-node-check
echo "    index index.html index.htm index.php;" >> /etc/nginx/sites-available/exit-node-check
echo "" >> /etc/nginx/sites-available/exit-node-check
echo "    location / {" >> /etc/nginx/sites-available/exit-node-check
echo '        try_files $uri $uri/ =404;' >> /etc/nginx/sites-available/exit-node-check
echo "    }" >> /etc/nginx/sites-available/exit-node-check
echo "" >> /etc/nginx/sites-available/exit-node-check
echo "    location ~ \.php$ {" >> /etc/nginx/sites-available/exit-node-check
echo "        include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/exit-node-check
echo "        fastcgi_pass unix:/var/run/php/php-fpm.sock;" >> /etc/nginx/sites-available/exit-node-check
echo "    }" >> /etc/nginx/sites-available/exit-node-check
echo "" >> /etc/nginx/sites-available/exit-node-check
echo "    location ~ /\.ht {" >> /etc/nginx/sites-available/exit-node-check
echo "        deny all;" >> /etc/nginx/sites-available/exit-node-check
echo "    }" >> /etc/nginx/sites-available/exit-node-check
echo "" >> /etc/nginx/sites-available/exit-node-check
echo "}" >> /etc/nginx/sites-available/exit-node-check

ln -s /etc/nginx/sites-available/exit-node-check /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default

systemctl reload nginx

rm -rf /var/www/html/exit-node-check/
mkdir -p /var/www/html/exit-node-check
chown -R $SUDO_USER:$SUDO_USER /var/www/html/exit-node-check

cat <<EOF | tee /var/www/html/exit-node-check/index.php >/dev/null
<?PHP
    \$ch = curl_init();

    curl_setopt(\$ch, CURLOPT_URL, "$EXIT_NODE_TEST_URL");
    curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt(\$ch, CURLOPT_CUSTOMREQUEST, "GET");
    \$result = curl_exec(\$ch);

    if (curl_errno(\$ch)) {
        echo 'Error:' . curl_error(\$ch);
    }
    
    \$ip_data = json_decode(\$result);

    if (strcmp(\$ip_data->{"country"}, "NL") == 0)
    {
        http_response_code(200);
    }
    else
    {
        http_response_code(400);
    }

    echo \$result;
    curl_close (\$ch);
?>
EOF
