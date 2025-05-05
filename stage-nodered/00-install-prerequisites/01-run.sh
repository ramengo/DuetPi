#!/bin/bash 

on_chroot << 'EOF'
# Update package lists
apt-get update --fix-missing
EOF
