#!/bin/bash

cp -r tools/drone /home/
cd /home/drone
cat <<EOT > .env
DRONE_SERVER_HOST=DOMAIN.com
DRONE_SERVER_PROTO=http
DRONE_GITHUB_CLIENT_ID=xxxx
DRONE_GITHUB_CLIENT_SECRET=xxxx
EOT
docker-compose up -d
