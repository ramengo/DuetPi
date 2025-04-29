#!/bin/bash
set -e

# 1. Assicurati che "en_US.UTF-8" sia decommentata in /etc/locale.gen
sed -i 's/^# *\(en_US\.UTF-8 UTF-8\)/\1/' "${ROOTFS_DIR}/etc/locale.gen"

# 2. Genera le locale dentro al chroot
on_chroot << EOF
locale-gen
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
EOF