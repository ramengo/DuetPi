#!/bin/bash
#install -m 644 files/config.g -o 996 -g 996 "${ROOTFS_DIR}/opt/dsf/sd/sys/config.g"

# Install preset files for UMDuet2
cp -rp files/dsf/sd/* "${ROOTFS_DIR}/opt/dsf/sd"
#cp -rp files/dsf/conf/plugins.txt "${ROOTFS_DIR}/opt/dsf/conf/plugins.txt"
cp files/wpa_supplicant.conf "${ROOTFS_DIR}/boot/"

install -m 644 files/3dforme.png "${ROOTFS_DIR}/usr/share/wallpapers/duet3d.png"

cp files/ExecOnMcode-0.6.zip "${ROOTFS_DIR}/home/pi/Desktop"

#chown -R dsf:dsf /opt/dsf/*
#chown pi:pi /opt/dsf/bin/
#chown -R dsf:dsf /opt/dsf/*
#chown -R dsf:dsf /opt/dsf/ExecOnMcode-0.6.zip



on_chroot << EOF

chown -R pi:pi /boot
chown -R pi:pi /opt/dsf/bin
chown -R dsf:dsf /opt/dsf/sd
chown -R dsf:dsf /opt/dsf/dwc
chown -R dsf:dsf /opt/dsf/plugins
chown -R dsf:dsf /opt/dsf/conf

chown -R pi:dsf /home/pi/Desktop/ExecOnMcode-0.6.zip   

systemctl enable bluetooth 
update-alternatives --install /usr/share/desktop-base/duet3d.png desktop-background /usr/share/wallpapers/duet3d.png 80
update-alternatives --set desktop-background /usr/share/wallpapers/duet3d.png

EOF