#!/bin/bash

echo -ne "Edit sshd config"
sed -i "/PasswordAuthentication/d" /etc/ssh/sshd_config
cat <<EOT >> /etc/ssh/sshd_config
PasswordAuthentication yes
EOT

echo -ne "Restart sshd"
systemctl restart sshd
