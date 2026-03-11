#!/usr/bin/env bash
set -euo pipefail

# Ensure currently directory is owned (issue with VM bring up).
sudo chown $(id -u):$(id -g) .

# Set a default git config for VM (so we can cherry pick later).
if [ ! -e ~/.gitconfig ]; then
	echo '[user]
email = you@example.com
name = Your Name' > ~/.gitconfig
fi

sudo sed -i 's/^#\s*deb-src /deb-src /' /etc/apt/sources.list 2>/dev/null || true

sudo apt-get update
sudo apt-get install -y \
  iw iperf3 \
  git curl ca-certificates fakeroot pkg-config \
  libnl-3-dev libnl-genl-3-dev libnl-route-3-dev \
  libusb-1.0-0-dev libudev-dev

sudo apt-get build-dep -y --arch-only linux

echo "Requirements complete."
