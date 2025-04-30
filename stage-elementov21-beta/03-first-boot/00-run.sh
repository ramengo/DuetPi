#!/bin/bash

cp -rp files/first_boot.sh "${ROOTFS_DIR}/usr/local/bin/first_boot.sh"
cp -rp files/firstboot.service "${ROOTFS_DIR}/etc/systemd/system/firstboot.service"

on_chroot << EOF
chmod +x /usr/local/bin/first_boot.sh
systemctl enable firstboot.service
EOF