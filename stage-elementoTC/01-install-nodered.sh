#!/bin/bash
set -e

echo "==> Stage elementotc: installazione Node-RED e dipendenze"

# Verifica architettura
ARCH=$(uname -m)
if [ "$ARCH" != "armv7l" ]; then
    echo "Architettura non supportata: $ARCH" >&2
    exit 1
fi

# Copia config Node-RED
install -d -m 755 "${ROOTFS_DIR}/etc/elementotc"
install -m 644 "files/flows.json" "${ROOTFS_DIR}/etc/elementotc/flows.json"
install -m 644 "files/additional-nodes.txt" "${ROOTFS_DIR}/etc/elementotc/additional-nodes.txt"

on_chroot << 'EOF'
apt-get update
apt-get install -y build-essential git curl
export NVM_DIR="/root/.nvm"
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
npm install -g --unsafe-perm node-red

# Setup initial flow
mkdir -p /root/.node-red
cp /etc/elementotc/flows.json /root/.node-red/flows.json

# Setup systemd service
cat << SERVICE > /etc/systemd/system/nodered.service
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
SERVICE

systemctl enable nodered.service
EOF
