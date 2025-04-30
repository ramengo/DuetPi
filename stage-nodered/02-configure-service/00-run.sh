#!/bin/bash -e

# Create first-boot configuration script
install -m 755 files/first-boot.sh "${ROOTFS_DIR}/usr/local/sbin/nodered-first-boot.sh"

# Create first-boot service
cat > "${ROOTFS_DIR}/lib/systemd/system/nodered-first-boot.service" << 'EOSERVICE'
[Unit]
Description=Node-RED First boot configuration
After=network.target
ConditionFileNotEmpty=/usr/local/sbin/nodered-first-boot.sh

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/nodered-first-boot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOSERVICE

on_chroot << 'EOF'
# Enable first-boot service
systemctl enable nodered-first-boot.service
EOF
