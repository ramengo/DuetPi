#!/bin/bash
set -e

echo "Configurazione della stampante: printer_C"

# Esempio di configurazione
install -d -m 755 "$ROOTFS_DIR/etc/duetpi"
echo '{"printer":"printer_C"}' > "$ROOTFS_DIR/etc/duetpi/printer-config.json"
