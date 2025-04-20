#!/bin/bash
set -e

BOOT_CONFIG="/boot/tailscale.conf"
TAILSCALE_REPO="https://pkgs.tailscale.com/stable/debian"

echo "[INFO] Installazione Tailscale per Raspberry Pi"

# Importa chiave GPG del repository Tailscale
curl -fsSL "${TAILSCALE_REPO}/bookworm.noarmor.gpg" \
  | gpg --dearmor -o /usr/share/keyrings/tailscale-archive-keyring.gpg

# Aggiunge il repository al sistema
echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] ${TAILSCALE_REPO} bookworm main" > /etc/apt/sources.list.d/tailscale.list

# Aggiorna repository e installa Tailscale
apt-get update
apt-get install -y tailscale

# Abilita il servizio
systemctl enable tailscaled

# Se esiste la configurazione in /boot, abilita login automatico
if [ -f "$BOOT_CONFIG" ]; then
    echo "[INFO] Carico configurazione da $BOOT_CONFIG"
    source "$BOOT_CONFIG"

    # Crea systemd unit per login automatico
    cat <<EOF > /etc/systemd/system/tailscale-autologin.service
[Unit]
Description=Tailscale automatic login
After=network-online.target
Wants=network-online.target
Requires=tailscaled.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/tailscale up --authkey $TS_AUTHKEY --hostname $TS_HOSTNAME --accept-routes --reset
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable tailscale-autologin

    echo "[INFO] Login automatico Tailscale configurato."
else
    echo "[INFO] File /boot/tailscale.conf non trovato. Login automatico disabilitato."
    echo "[INFO] Tailscale sarà installato ma non configurato per il login automatico."
fi
