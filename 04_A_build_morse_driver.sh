#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_vars.sh"

if [ ! -e morse_driver ]; then
  git clone https://github.com/MorseMicro/morse_driver.git
fi

cd morse_driver
git fetch --all --tags
git checkout "$MORSE_VERSION"
git submodule update --init --recursive

# Remove x86_64 hack for working without patches
git am "$SCRIPT_DIR"/remove-x86_64-chan-ignore.patch

set -x
make -j KERNEL_SRC="../$KERNEL_SRC" \
  CONFIG_WLAN_VENDOR_MORSE=m \
  CONFIG_MORSE_USER_ACCESS=y \
  CONFIG_MORSE_VENDOR_COMMAND=y \
  CONFIG_MORSE_SDIO=y \
  CONFIG_MORSE_SPI=y \
  CONFIG_MORSE_USB=y

echo "Compile complete."
