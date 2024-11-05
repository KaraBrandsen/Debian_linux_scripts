#!/bin/bash

LIBREST_PORT=8090                                       #Port used by Libre Speed Test


echo "-----------------------------Installing Libre Speed Test-----------------------------"

echo "Installing Nginx"
apt install nginx mysql-server php-fpm php-mysql php-image-text php-gd php-sqlite3 -y

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