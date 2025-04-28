#!/bin/bash
set -e

echo "Installazione Node-RED e dipendenze"

on_chroot << EOF
apt-get update
apt-get install -y build-essential git curl

# Installa Node.js LTS (usa nvm)
export NVM_DIR="/root/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# Installa Node-RED
npm install -g --unsafe-perm node-red

# Crea directory di configurazione Node-RED e copia un flow di esempio
mkdir -p /root/.node-red
cp /etc/nodered/flows.json /root/.node-red/flows.json

# Abilita Node-RED come servizio
cat << SYSTEMD > /etc/systemd/system/nodered.service
[Unit]
Description=Node-RED
After=network.target

[Service]
ExecStart=/root/.nvm/versions/node/*/bin/node-red
Restart=on-failure
User=root
Group=root
Environment=PATH=/root/.nvm/versions/node/*/bin:/usr/bin:/bin:/usr/sbin:/sbin
Environment=NODE_ENV=production
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl enable nodered.service
EOF
