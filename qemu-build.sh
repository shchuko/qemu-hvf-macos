#!/bin/bash
# QEMU Build script
#
# We need to use custom qemu-systen-x86_64 build because required
# patches haven't been merged to qemu/master yet
#
# returns 'qemu-system-x86_64' executable path
#

QEMU_DIR="./qemu"
QEMU_EXEC="$QEMU_DIR/build/qemu-system-x86_64"

if [[ -f "$QEMU_EXEC" ]]; then
  echo "$QEMU_EXEC"
  exit 0
fi

if [[ ! -d "$QEMU_DIR" ]]; then
  git clone --filter=blob:none --single-branch \
    --branch "v5.2.0/darwin-support" "https://github.com/shchuko/qemu.git" "$QEMU_DIR"
fi

cd "$QEMU_DIR" || exit 1
./configure --target-list=x86_64-softmmu || exit 1
make || exit 1
cd - || exit 1

if [[ -f "$QEMU_EXEC" ]]; then
  echo "$QEMU_EXEC"
  exit 0
else
  exit 1
fi

