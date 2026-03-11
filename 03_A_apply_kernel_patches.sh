#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_vars.sh"

MORSE_KERNEL_BRANCH="mm/linux-5.15.61/1.15.x"
MORSE_BASE_TAG="v5.15.61"

apt source linux
cd "$KERNEL_SRC"

# Making it a git repository makes it easier to patch.
git init
git add -A
git commit -m "Ubuntu linux source baseline before Morse patches"

git remote add mmlinux https://github.com/MorseMicro/linux.git 2>/dev/null || true
git fetch --depth=1 mmlinux "refs/tags/$MORSE_BASE_TAG:refs/tags/$MORSE_BASE_TAG"
git fetch --depth=20 mmlinux "$MORSE_KERNEL_BRANCH"

if ! git cherry-pick "$MORSE_BASE_TAG..refs/remotes/mmlinux/$MORSE_KERNEL_BRANCH"; then
	echo "WARNING: change into $KERNEL_SRC and manually complete cherry-picking."
else
	echo "Kernel patching complete."
fi
