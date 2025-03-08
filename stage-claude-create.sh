#!/bin/bash -e

# Stage directory structure
STAGEDIR="stage-nodered"

# Create stage directory
mkdir -p "${STAGEDIR}"

# Create necessary subdirectories
mkdir -p "${STAGEDIR}/00-install-prerequisites"
mkdir -p "${STAGEDIR}/01-install-nodered"
mkdir -p "${STAGEDIR}/02-configure-service"

# Create prerun.sh
cat > "${STAGEDIR}/prerun.sh" << 'EOF'
#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
    copy_previous
fi
EOF

# Create 00-install-prerequisites/00-packages
cat > "${STAGEDIR}/00-install-prerequisites/00-packages" << 'EOF'
nodejs
npm
build-essential
git
EOF

# Create 00-install-prerequisites/01-run.sh
cat > "${STAGEDIR}/00-install-prerequisites/01-run.sh" << 'EOF'
#!/bin/bash -e

on_chroot << 'EEOF'
# Update package lists
apt-get update

# Install packages from 00-packages list
apt-get install -y $(cat packages)

# Install n for Node.js version management
npm install -g n

# Install specific Node.js LTS version
n lts

# Update npm to latest version
npm install -g npm@latest
EEOF
EOF

# Create 01-install-nodered/00-run.sh
cat > "${STAGEDIR}/01-install-nodered/00-run.sh" << 'EOF'
#!/bin/bash -e

on_chroot << 'EEOF'
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
EEOF
EOF

# Create 02-configure-service/00-run.sh
cat > "${STAGEDIR}/02-configure-service/00-run.sh" << 'EOF'
#!/bin/bash -e

# Create first-boot configuration script
install -m 755 files/first-boot.sh "${ROOTFS_DIR}/usr/local/sbin/nodered-first-boot.sh"

# Create first-boot service
cat > "${ROOTFS_DIR}/lib/systemd/system/nodered-first-boot.service" << 'EOSERVICE'
[Unit]
Description=Node-RED First boot configuration
After=network.target
ConditionFileNotEmpty=/usr/local/sbin/nodered-first-boot.sh

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/nodered-first-boot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOSERVICE

on_chroot << 'EEOF'
# Enable first-boot service
systemctl enable nodered-first-boot.service
EEOF
EOF

# Create first-boot script
mkdir -p "${STAGEDIR}/02-configure-service/files"
cat > "${STAGEDIR}/02-configure-service/files/first-boot.sh" << 'EOF'
#!/bin/bash

# Start Node-RED
systemctl start nodered.service

# Remove this script and its service after execution
rm /usr/local/sbin/nodered-first-boot.sh
rm /lib/systemd/system/nodered-first-boot.service
systemctl disable nodered-first-boot.service

exit 0
EOF

# Set execution permissions
chmod +x "${STAGEDIR}/prerun.sh"
chmod +x "${STAGEDIR}/00-install-prerequisites/01-run.sh"
chmod +x "${STAGEDIR}/01-install-nodered/00-run.sh"
chmod +x "${STAGEDIR}/02-configure-service/00-run.sh"

echo "Node-RED Pi-gen stage structure created in ${STAGEDIR}"