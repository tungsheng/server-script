#!/bin/bash

cp -r tools/traefik /opt/
cd /opt/traefik
chmod 600 acme.json
docker network create web
docker-compose up -d
