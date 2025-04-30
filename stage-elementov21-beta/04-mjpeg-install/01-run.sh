#!/bin/bash -e

on_chroot << EOF
	mkdir ~/mjpg-streamer
	cd ~/mjpg-streamer
	git clone https://github.com/jacksonliam/mjpg-streamer.git
	cd mjpg-streamer/mjpg-streamer-experimental
	make
	make install
EOF

install -m 755 files/livestream.sh "${ROOTFS_DIR}/etc/init.d/livestream.sh"

on_chroot << EOF
	chown root:root /etc/init.d/livestream.sh
	chmod 755 /etc/init.d/livestream.sh
	update-rc.d livestream.sh defaults
EOF