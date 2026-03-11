#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_vars.sh"

if [ ! -e hostap ]; then
  git clone https://github.com/MorseMicro/hostap.git
fi
cd hostap
git fetch --all --tags
git checkout "$MORSE_VERSION"
git am "$SCRIPT_DIR/wpa_passphrase_rename.patch"
cp wpa_supplicant/defconfig wpa_supplicant/.config
echo CONFIG_MESH=y >> wpa_supplicant/.config
cp hostapd/defconfig hostapd/.config

EXTRA_CFLAGS="-Wno-error=sign-compare -Wno-error=deprecated-declarations"
make -j EXTRA_CFLAGS="$EXTRA_CFLAGS" MORSE_VERSION="$MORSE_VERSION" -C wpa_supplicant/
sudo make EXTRA_CFLAGS="$EXTRA_CFLAGS" MORSE_VERSION="$MORSE_VERSION" -C wpa_supplicant/ install
make -j EXTRA_CFLAGS="$EXTRA_CFLAGS" MORSE_VERSION="$MORSE_VERSION" -C hostapd/
sudo make EXTRA_CFLAGS="$EXTRA_CFLAGS" MORSE_VERSION="$MORSE_VERSION" -C hostapd/ install
cd ..

if [ ! -e morse_cli ]; then
  git clone https://github.com/MorseMicro/morse_cli.git
fi
cd morse_cli
git fetch --all --tags
git checkout "$MORSE_VERSION"

CFLAGS="$(pkg-config --cflags libnl-3.0 libnl-genl-3.0) -I/usr/include/libusb-1.0" \
LDFLAGS="$(pkg-config --libs libnl-3.0 libnl-genl-3.0) -lusb-1.0" \
make CONFIG_MORSE_TRANS_NL80211=1
sudo make install_cli

echo "User-space build/install complete."
