#!/bin/bash
#install -m 644 files/config.g -o 996 -g 996 "${ROOTFS_DIR}/opt/dsf/sd/sys/config.g"

install -m 644 files/splash.png "${ROOTFS_DIR}/usr/share/wallpapers/duet3d.png"
cp -rp files/splash.png "${ROOTFS_DIR}/usr/share/plymouth/themes/pix/splash.png"

on_chroot << EOF
mkdir /etc/X11/xorg.conf.d
EOF

#cp -rp files/wayfire.ini "${ROOTFS_DIR}/home/pi/.config/wayfire.ini"
# Install preference for 10.1' display waves
cp -rp files/40-libinput.conf "${ROOTFS_DIR}/etc/X11/xorg.conf.d/40-libinput.conf"

install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/TC "${ROOTFS_DIR}/boot/"
install -m 644 files/ssh "${ROOTFS_DIR}/boot/"

