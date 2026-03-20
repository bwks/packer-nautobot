#!/bin/bash
set -euo pipefail

echo "==> [03] Removing build dependencies and package cache..."
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

echo "==> [03] Clearing pip caches..."
pip3 cache purge 2>/dev/null || true
sudo -u nautobot /opt/nautobot/bin/pip cache purge 2>/dev/null || true

echo "==> [03] Truncating log files..."
find /var/log -type f \( -name "*.log" -o -name "*.log.*" \) -exec truncate -s 0 {} \; 2>/dev/null || true
find /var/log/nautobot -type f -exec truncate -s 0 {} \; 2>/dev/null || true

echo "==> [03] Clearing shell history..."
history -c
rm -f /root/.bash_history /home/ubuntu/.bash_history /opt/nautobot/.bash_history

echo "==> [03] Resetting cloud-init (will run on first boot with user data)..."
cloud-init clean --logs --seed

echo "==> [03] Removing SSH host keys (regenerated on first boot)..."
rm -f /etc/ssh/ssh_host_*

echo "==> [03] Resetting machine-id (regenerated on first boot)..."
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

echo "==> [03] Sending TRIM to reclaim unused blocks (keeps qcow2 sparse)..."
fstrim -v / 2>/dev/null || true

echo "==> [03] Syncing filesystem..."
sync

echo "==> [03] Cleanup complete."
