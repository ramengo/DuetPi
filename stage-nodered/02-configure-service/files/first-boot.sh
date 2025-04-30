#!/bin/bash

# Start Node-RED
systemctl start nodered.service

# Remove this script and its service after execution
rm /usr/local/sbin/nodered-first-boot.sh
rm /lib/systemd/system/nodered-first-boot.service
systemctl disable nodered-first-boot.service

exit 0
