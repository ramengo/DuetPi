#!/bin/bash
set -e

echo "Configurazione della stampante: printer_B"

# Esempio di configurazione
install -d -m 755 "$ROOTFS_DIR/etc/duetpi"
echo '{"printer":"printer_B"}' > "$ROOTFS_DIR/etc/duetpi/printer-config.json"
