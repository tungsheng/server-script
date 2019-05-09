#!/bin/bash

# functions
get_host() {
  echo -e "\n\n"
  read -e -p "Enter a host (e.g. web.host.com) " -r wwwhost
  if [[ "${#wwwhost}" -lt 1 ]]; then
    echo " >> Please enter a valid host!"
    get_host
  fi
  echo -e "\n\n"
}

println() {
    echo -ne "\n\n$1"
    echo -ne "\n===========================================\n"
}


println "Installing drone binary..."
curl -L https://github.com/drone/drone-cli/releases/download/v0.8.6/drone_linux_amd64.tar.gz | tar zx
sudo install -t /usr/local/bin drone

println "Pulling drone image..."
docker pull drone/drone:0.8

println "Create folder..."
sudo mkdir /etc/drone

get_host
secret="$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 | head -c 65 && echo)"

println "Create docker-compose file..."
droneDCF=/etc/drone/docker-compose.yml
[ -f "$droneDCF" ] || sudo touch $droneDCF
cat <<EOT > $droneDCF
version: '3'

services:
  drone-server:
    image: drone/drone:0.8
    ports:
      - 8000:8000
      - 9000:9000
    volumes:
      - ./:/var/lib/drone
    restart: always
    environment:
      - DRONE_SECRET=$secret
      - DRONE_HOST=https://$wwwhost
      - DRONE_OPEN=false
      - DRONE_ADMIN=USER
      - DRONE_BITBUCKET=true
      - DRONE_BITBUCKET_CLIENT=CLIENT_ID
      - DRONE_BITBUCKET_SECRET=SECRET_KEY

  drone-agent:
    image: drone/agent:0.8
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SECRET=$secret
      - DRONE_SERVER=drone-server:9000
      - DRONE_MAX_PROCS=3
EOT

droneService=/lib/systemd/system/drone.service
[ -f "$droneService" ] || sudo touch $droneService
cat <<EOT > $droneService
[Unit]
Description=Drone server
After=docker.service nginx.service

[Service]
Restart=always
ExecStart=/usr/local/bin/docker-compose -f /etc/drone/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /etc/drone/docker-compose.yml stop

[Install]
WantedBy=multi-user.target
EOT

# get host for drone
availableDIR="/etc/nginx/sites-available"
enabledDIR="/etc/nginx/sites-enabled"
availableBlock="$availableDIR/$wwwhost"
enabledBlock="$enabledDIR/$wwwhost"
[ -f "$availableBlock" ] || sudo touch $availableBlock
[ -L "$enabledBlock" ] || sudo ln -s $availableBlock $enabledBlock

cat <<EOT > $availableBlock
server {
  listen 80;
  listen [::]:80;

  server_name $wwwhost;

  location / {
    proxy_set_header X-Forwarded-For \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Host \$http_host;

    proxy_pass http://127.0.0.1:8000;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_buffering off;

    chunked_transfer_encoding off;
  }
}
EOT
