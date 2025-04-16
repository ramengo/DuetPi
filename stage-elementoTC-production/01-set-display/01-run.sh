#!/bin/bash
#install -m 644 files/config.g -o 996 -g 996 "${ROOTFS_DIR}/opt/dsf/sd/sys/config.g"

on_chroot << EOF
mkdir /etc/X11/xorg.conf.d
mkdir /etc/X11/xorg.conf.d
wlr-randr --output HDMI-A-1 --transform 270
raspi-config nonint do_boot_splash 1
raspi-config nonint do_wayland W1
EOF

# Install preference for 10.1' display waves
cp -rp files/40-libinput.conf "${ROOTFS_DIR}/etc/X11/xorg.conf.d/40-libinput.conf"
cp -rp files/splash.png "${ROOTFS_DIR}/usr/share/plymouth/themes/pix/splash.png"

install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/TC "${ROOTFS_DIR}/boot/"