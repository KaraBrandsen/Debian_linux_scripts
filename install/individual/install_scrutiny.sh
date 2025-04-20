SCRUTINY_HOST=http://192.168.194.205
SCRUTINY_PORT=8060

echo "-----------------------------Installing Scrutiny-----------------------------"

# Add the InfluxData key to verify downloads and add the repository
curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key
echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum --check - && cat influxdata-archive.key \
| gpg --dearmor \
| tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| tee /etc/apt/sources.list.d/influxdata.list
# Install influxdb
apt-get update && apt-get install influxdb2

service influxdb stop
echo 'http-bind-address = ":7076"' >> /etc/influxdb/config.toml
service influxdb start

mkdir -p /opt/scrutiny/config
mkdir -p /opt/scrutiny/web
mkdir -p /opt/scrutiny/bin

wget https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-linux-amd64 -O /opt/scrutiny/bin/scrutiny-web-linux-amd64
wget https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-frontend.tar.gz

tar xvzf scrutiny-web-frontend.tar.gz --strip-components 1 -C /opt/scrutiny/web
rm -rf scrutiny-web-frontend.tar.gz

chmod +x /opt/scrutiny/bin/scrutiny-web-linux-amd64

cat <<EOF | tee /opt/scrutiny/config/scrutiny.yaml >/dev/null
version: 1

web:
  listen:
    port: 8060
    host: 0.0.0.0
  database:
    # The Scrutiny webapp will create a database for you, however the parent directory must exist.
    location: /opt/scrutiny/config/scrutiny.db
  src:
    frontend:
      # The path to the Scrutiny frontend files (js, css, images) must be specified.
      # We'll populate it with files in the next section
      path: /opt/scrutiny/web
  
  # if you're running influxdb on a different host (or using a cloud-provider) you'll need to update the host & port below. 
  # token, org, bucket are unnecessary for a new InfluxDB installation, as Scrutiny will automatically run the InfluxDB setup, 
  # and store the information in the config file. If you 're re-using an existing influxdb installation, you'll need to provide
  # the `token`
  influxdb:
    host: localhost
    port: 7076
#    token: 'my-token'
#    org: 'my-org'
#    bucket: 'bucket'
EOF

echo "Creating new service file..."
cat <<EOF | tee /etc/systemd/system/scrutiny.service >/dev/null
[Unit]
Description=Scrutiny Daemon
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/opt/scrutiny/bin/scrutiny-web-linux-amd64 start --config /opt/scrutiny/config/scrutiny.yaml
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

sleep 2

echo -e "Scrutiny is attempting to start, this may take a few seconds..."
systemctl -q daemon-reload
systemctl enable --now -q "scrutiny"
systemctl start scrutiny

echo "-------------------Installing Collector-------------------"

mkdir -p /opt/scrutiny/bin
wget https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-collector-metrics-linux-amd64 -O /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64

chmod +x /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64
/opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --api-endpoint "$SCRUTINY_HOST:$SCRUTINY_PORT"

crontab -l > tempCron
#echo new cron into cron file
echo '*/15 * * * * . /etc/profile; /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --api-endpoint "'$SCRUTINY_HOST':'$SCRUTINY_PORT'"' >> tempCron
#install new cron file
crontab tempCron
rm tempCron