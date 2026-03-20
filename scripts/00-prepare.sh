#!/bin/bash
set -euo pipefail

echo "==> [00] Waiting for cloud-init to complete..."
cloud-init status --wait 2>/dev/null || true

# Kill any lingering apt/dpkg processes from cloud-init
systemctl stop unattended-upgrades.service 2>/dev/null || true
systemctl kill --kill-who=all apt-daily.service apt-daily-upgrade.service 2>/dev/null || true
sleep 2

echo "==> [00] Updating package lists..."
apt-get update -y

echo "==> [00] Upgrading installed packages..."
apt-get upgrade -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold"

echo "==> [00] Installing system dependencies..."
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  build-essential \
  libssl-dev \
  libffi-dev \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev \
  postgresql \
  postgresql-contrib \
  redis-server \
  nginx \
  git \
  curl \
  wget \
  acl

echo "==> [00] Enabling core services..."
systemctl enable postgresql redis-server nginx
systemctl start postgresql redis-server

echo "==> [00] System preparation complete."
