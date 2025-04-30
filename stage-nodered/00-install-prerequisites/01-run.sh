#!/bin/bash -e

on_chroot << 'EOF'
# Update package lists
apt-get update --fix-missing

# Install packages from 00-packages list
apt-get install -y $(cat packages)

EOF
