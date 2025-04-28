#!/bin/bash
set -e

echo "Installazione nodi aggiuntivi Node-RED"

on_chroot << EOF
export NVM_DIR="/root/.nvm"
source "$NVM_DIR/nvm.sh"
nvm use --lts

cd /root/.node-red

# Se esiste un file con l'elenco dei nodi, installali
if [ -f /etc/nodered/additional-nodes.txt ]; then
    while read -r node; do
        if [ ! -z "$node" ]; then
            npm install "$node"
        fi
    done < /etc/nodered/additional-nodes.txt
fi
EOF
