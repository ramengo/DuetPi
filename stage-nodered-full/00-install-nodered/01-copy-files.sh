#!/bin/bash
set -e

echo "Copia file di configurazione Node-RED"

install -d -m 755 "${ROOTFS_DIR}/etc/nodered"
install -m 644 files/flows.json "${ROOTFS_DIR}/etc/nodered/flows.json"
install -m 644 files/additional-nodes.txt "${ROOTFS_DIR}/etc/nodered/additional-nodes.txt"
