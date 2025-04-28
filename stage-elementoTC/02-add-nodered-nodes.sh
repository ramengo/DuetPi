#!/bin/bash
set -e

echo "==> Stage elementotc: installazione nodi aggiuntivi per Node-RED"

on_chroot << 'EOF'
export NVM_DIR="/root/.nvm"
source "$NVM_DIR/nvm.sh"
nvm use --lts

cd /root/.node-red
if [ -f /etc/elementotc/additional-nodes.txt ]; then
    while read -r node; do
        [ -z "$node" ] && continue
        npm install "$node"
    done < /etc/elementotc/additional-nodes.txt
fi
EOF
