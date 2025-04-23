#!/bin/bash -e
install -m 755 files/mjpg_streamer "${ROOTFS_DIR}/usr/local/bin/mjpg_streamer"
install -m 755 files/livestream.sh "${ROOTFS_DIR}/etc/init.d/livestream.sh"

on_chroot << EOF
	chown pi:pi /etc/init.d/livestream.sh
	chmod 755 /etc/init.d/livestream.sh
	update-rc.d livestream.sh defaults
EOF