#!/bin/bash
set -e

echo "==> Stage elementotc: configurazione stampanti custom"

# Controllo OS
if ! grep -q "buster" "${ROOTFS_DIR}/etc/os-release"; then
    echo "Warning: sistema non Buster" >&2
fi

# Create target dirs
install -d -m 755 "${ROOTFS_DIR}/etc/duetpi/print-configs"

TARGET="${TARGET_PRINTER:-none}"

case "$TARGET" in
    elementotc|3dforme|beta)
        install -m 644 "files/printers/$TARGET/udev-$TARGET.rules" "${ROOTFS_DIR}/etc/udev/rules.d/99-$TARGET.rules"
        install -d -m 755 "${ROOTFS_DIR}/etc/duetpi/print-configs/$TARGET"
        install -m 644 "files/printers/$TARGET/$TARGET-config.json" "${ROOTFS_DIR}/etc/duetpi/print-configs/$TARGET/config.json"
        echo "Stampante '$TARGET' configurata"
        ;;
    *)
        echo "Nessuna stampante configurata. Imposta TARGET_PRINTER a elementotc, 3dforme o beta" >&2
        ;;
esac
