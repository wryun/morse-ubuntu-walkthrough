#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_vars.sh"

KERNEL_RELEASE="$(uname -r)"
MODROOT="/lib/modules/$KERNEL_RELEASE"

echo "Installing modules into $MODROOT"
sudo install -D -m 0644 "$KERNEL_SRC/net/wireless/cfg80211.ko" "$MODROOT/kernel/net/wireless/cfg80211.ko"
sudo install -D -m 0644 "$KERNEL_SRC/net/mac80211/mac80211.ko" "$MODROOT/kernel/net/mac80211/mac80211.ko"
sudo install -D -m 0644 "morse_driver/dot11ah/dot11ah.ko" "$MODROOT/updates/morse/dot11ah.ko"
sudo install -D -m 0644 "morse_driver/morse.ko" "$MODROOT/updates/morse/morse.ko"

echo "Running depmod for $KERNEL_RELEASE"
sudo depmod -a "$KERNEL_RELEASE"

echo "Install complete."
