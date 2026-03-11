#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_vars.sh"

cd "$KERNEL_SRC"
chmod +x scripts/pahole*.sh
cp "/boot/config-$(uname -r)" .config

# Ubuntu cloud kernels define ANDROID, which causes a different
# firmware location (which will confuse things when using morse_cli).
# Note that we really should be building a new kernel here since
# we patched the headers in the previous step (which means we can't
# easily use Ubuntu's existing build dir), but for speed...
sed -i 's/CONFIG_ANDROID=y/CONFIG_ANDROID=n/' .config

make olddefconfig
make modules_prepare
make -j M=net/wireless modules
make -j M=net/mac80211 modules

echo "Compile complete."
