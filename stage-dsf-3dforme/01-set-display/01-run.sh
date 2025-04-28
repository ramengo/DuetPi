#!/bin/bash
#install -m 644 files/config.g -o 996 -g 996 "${ROOTFS_DIR}/opt/dsf/sd/sys/config.g"

#on_chroot << EOF
#mkdir /etc/X11/xorg.conf.d
#EOF

# Install preference for 10.1' display waves
# cp -rp files/40-libinput.conf "${ROOTFS_DIR}/etc/X11/xorg.conf.d/40-libinput.conf"
if [ "${BETA}" = "1" ]; then
    cp -rp files/splash_3dforme_beta.png "${ROOTFS_DIR}/usr/share/plymouth/themes/pix/splash.png"
else
    cp -rp files/splash_3dforme.png "${ROOTFS_DIR}/usr/share/plymouth/themes/pix/splash.png"
fi

install files/config.txt "${ROOTFS_DIR}/boot/"
install files/cmdline.txt "${ROOTFS_DIR}/boot/"
install files/3dforme "${ROOTFS_DIR}/boot/"
install -m 655 files/firstboot.sh -o 1000 -g 1000 "${ROOTFS_DIR}/home/pi/Desktop"
install -m 655 files/010_dsf-nopasswd -o 0 -g 996  "${ROOTFS_DIR}/etc/sudoers.d/"




on_chroot << EOF
chown pi:pi /home/pi/Desktop/firstboot.sh
chmod 555 /home/pi/Desktop/firstboot.sh
EOF