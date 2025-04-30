#!/bin/bash

cp -rp files/ExecOnMcode-0.6.zip "${ROOTFS_DIR}/home/pi/ExecOnMcode-0.6.zip"
cp -rp files/InputShaping-3.4.7.zip "${ROOTFS_DIR}/home/pi/InputShaping-3.4.7.zip"
cp -rp files/SpyglassWebcamServer-3.5.0.zip "${ROOTFS_DIR}/home/pi/SpyglassWebcamServer-3.5.0.zip"

on_chroot << EOF
echo "here"
EOF