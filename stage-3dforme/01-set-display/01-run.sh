#!/bin/bash

cp -rp files/splash_3dforme.png "${ROOTFS_DIR}/usr/share/plymouth/themes/pix/splash.png"

install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/3dforme "${ROOTFS_DIR}/boot/"
