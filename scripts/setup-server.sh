#!/usr/bin/env bash
# One-time setup for the deployment server (Ubuntu 22.04/24.04).
# Run ON THE SERVER:   bash setup-server.sh
set -euo pipefail

echo ">>> Installing Docker"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo systemctl enable --now docker

echo ">>> Letting user '$USER' run docker without sudo"
sudo usermod -aG docker "$USER"

echo ">>> Ensuring curl is installed"
command -v curl >/dev/null 2>&1 || sudo apt-get install -y curl

echo ">>> Opening port 80 in the local firewall (if ufw is active)"
if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
  sudo ufw allow 22/tcp
  sudo ufw allow 80/tcp
fi

echo
echo "DONE. Now:"
echo "  1. Log out and log back in (so the docker group applies)."
echo "  2. Test:  docker run --rm hello-world"
echo "  3. In your CLOUD PORTAL also allow inbound TCP 80 (and 22) on this VM's network/security group."
