#!/bin/bash -e
# Install Node.js 20 LTS + Node‑RED on Raspberry Pi OS Buster

#############################################################################
# 0 · Add buster-backports from archive.debian.org (trusted, no Valid‑Until)
#############################################################################
mkdir -p "${ROOTFS_DIR}/etc/apt/sources.list.d"
cat > "${ROOTFS_DIR}/etc/apt/sources.list.d/buster-backports.list" <<'SRC'
deb [trusted=yes] http://archive.debian.org/debian buster-backports main
SRC

mkdir -p "${ROOTFS_DIR}/etc/apt/apt.conf.d"
echo 'Acquire::Check-Valid-Until "false";'         > "${ROOTFS_DIR}/etc/apt/apt.conf.d/99no-check-valid-until"

#############################################################################
# 1 · Do the work inside chroot
#############################################################################
on_chroot <<'EOF'
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

echo "[Node-RED] apt update & libstdc++6 (backports)"
apt-get update
apt-get -t buster-backports install -y libstdc++6

echo "[Node-RED] base packages"
apt-get install -y --no-install-recommends curl git build-essential ca-certificates

echo "[Node-RED] Node.js 20 LTS from NodeSource"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs   # npm included

echo "[Node-RED] global install"
npm install -g --unsafe-perm node-red

echo "[Node-RED] create service user"
useradd -r -s /usr/sbin/nologin -m nodered

echo "[Node-RED] data directory"
install -o nodered -g nodered -d /var/lib/nodered
if [ -f /etc/nodered/flows.json ]; then
    cp /etc/nodered/flows.json /var/lib/nodered/flows.json
    chown nodered:nodered /var/lib/nodered/flows.json
fi

echo "[Node-RED] systemd unit"
cat > /etc/systemd/system/nodered.service <<'SYSTEMD'
[Unit]
Description=Node-RED
After=network.target

[Service]
Type=simple
User=nodered
Group=nodered
WorkingDirectory=/var/lib/nodered
Environment=NODE_ENV=production
ExecStart=/usr/bin/env node-red
Restart=on-failure

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable nodered.service
EOF

echo ">>> Node-RED installed and enabled! <<<"
