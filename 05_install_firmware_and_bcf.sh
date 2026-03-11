#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_vars.sh"

sudo mkdir -p "/lib/firmware/morse"

if [ ! -e morse-firmware ]; then
  git clone https://github.com/MorseMicro/morse-firmware.git
fi

cd morse-firmware
git fetch --all --tags
git checkout "$MORSE_MAJOR_VERSION"

sudo mkdir -p /lib/firmware/morse
find . -name '*.bin' -exec sudo cp -f {} "/lib/firmware/morse" \;

echo "Firmware/BCF copied from morse-firmware (all .bin files copied)."
