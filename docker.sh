#!/bin/bash

set -e

println() {
    echo -ne "\n\n$1"
    echo -ne "\n===========================================\n"
}

# install docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce

# install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# show docker compose version
println "Show docker-compose version"
docker-compose --version

# add user to docker group
println "Add user to docker group"
usermod -aG docker deploy

println "docker successfully installed!!"
