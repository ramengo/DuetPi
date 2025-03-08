#!/bin/bash -e

on_chroot << 'EEOF'
# Update package lists
apt-get update

# Install packages from 00-packages list
apt-get install -y $(cat packages)

EEOF
