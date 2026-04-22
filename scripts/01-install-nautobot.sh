#!/bin/bash
set -euo pipefail

NAUTOBOT_ROOT=/opt/nautobot
NAUTOBOT_VERSION="${NAUTOBOT_VERSION:-}"

# Pin nautobot to a specific release if NAUTOBOT_VERSION is set; otherwise
# install the latest release from PyPI.
if [[ -n "$NAUTOBOT_VERSION" ]]; then
  NAUTOBOT_PIP_SPEC="nautobot==${NAUTOBOT_VERSION}"
else
  NAUTOBOT_PIP_SPEC="nautobot"
fi

echo "==> [01] Creating nautobot system user..."
useradd \
  --system \
  --create-home \
  --home-dir "$NAUTOBOT_ROOT" \
  --shell /bin/bash \
  nautobot

echo "==> [01] Creating directory structure..."
mkdir -p "$NAUTOBOT_ROOT"/{media,static}
mkdir -p /var/log/nautobot
chown -R nautobot:nautobot "$NAUTOBOT_ROOT" /var/log/nautobot

echo "==> [01] Creating Python virtual environment..."
sudo -u nautobot python3 -m venv "$NAUTOBOT_ROOT"

echo "==> [01] Upgrading pip and wheel..."
sudo -u nautobot "$NAUTOBOT_ROOT/bin/pip" install --upgrade pip wheel

echo "==> [01] Installing Nautobot (${NAUTOBOT_PIP_SPEC}) and uWSGI..."
# nautobot pulls in Django, celery, django-redis, and all required deps
sudo -u nautobot "$NAUTOBOT_ROOT/bin/pip" install "$NAUTOBOT_PIP_SPEC" uwsgi

echo "==> [01] Installing Nautobot plugins..."
sudo -u nautobot "$NAUTOBOT_ROOT/bin/pip" install \
  nautobot-bgp-models \
  nautobot-plugin-nornir \
  nautobot-circuit-maintenance

INSTALLED_VERSION=$(sudo -u nautobot "$NAUTOBOT_ROOT/bin/pip" show nautobot 2>/dev/null | awk '/^Version:/{print $2}')
echo "==> [01] Installed Nautobot version: ${INSTALLED_VERSION}"
