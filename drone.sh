#!/bin/bash

println() {
    echo -ne "\n\n$1"
    echo -ne "\n===========================================\n"
}

println "Pulling drone image..."
docker pull drone/drone:0.8

println "Create folder..."
sudo mkdir /etc/drone

println "Create docker-compose file..."
droneDCF=/etc/drone/docker-compose.yml
[ -f "$droneDCF" ] || sudo touch $droneDCF
sudo cat <<EOT > $droneDCF
version: '3'

services:
  drone-server:
    image: drone/drone:0.8
    ports:
      - 127.0.0.1:8000:8000
    volumes:
      - /var/lib/drone:/var/lib/drone
    restart: always
    env_file:
      - /etc/drone/server.env

  drone-agent:
    image: drone/drone:0.8
    command: agent
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always
    env_file:
      - /etc/drone/agent.env
EOT

println "Creating secrets..."
serverEnv=/etc/drone/server.env
[ -f "$serverEnv" ] || sudo touch $serverEnv
sudo cat <<EOT > $serverEnv
# Service settings
DRONE_SECRET=secret_generated_on_command_line
DRONE_HOST=https://example.com

# Registration settings
DRONE_OPEN=false
DRONE_ADMIN=USER

# GitHub Settings
DRONE_BITBUCKET=true
DRONE_BITBUCKET_CLIENT=CLIENT_ID
DRONE_BITBUCKET_SECRET=SECRET_KEY
EOT

agentEnv=/etc/drone/agent.env
[ -f "$agentEnv" ] || sudo touch $agentEnv
sudo cat <<EOT > $agentEnv
DRONE_SECRET=secret_generated_on_command_line
DRONE_SERVER=wss://example.com/ws/broker
EOT

droneSystemd=/etc/systemd/system/drone.service
[ -f "$droneSystemd" ] || sudo touch $droneSystemd
sudo cat <<EOT > $agentEnv
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

