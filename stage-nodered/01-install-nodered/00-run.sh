#!/bin/bash -e

on_chroot << 'EOF'
# Install Node-RED
npm install -g --unsafe-perm node-red

# Create Node-RED system service
cat > /lib/systemd/system/nodered.service << 'EOSERVICE'
[Unit]
Description=Node-RED
After=network.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi
Environment="NODE_OPTIONS=--max_old_space_size=512"
ExecStart=/usr/local/bin/node-red --userDir /home/pi/.node-red
Restart=on-failure
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOSERVICE

# Create Node-RED data directory
mkdir -p /home/pi/.node-red
chown -R pi:pi /home/pi/.node-red

# Enable Node-RED service
systemctl enable nodered.service
EOF
