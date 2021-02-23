#!/bin/bash
set -euo pipefail
# QEMU Build script
#
# We need to use custom qemu-system-x86_64 build because required
# patches haven't been merged to qemu/master yet
#

QEMU_DIR="./qemu"
QEMU_BINDIR="$QEMU_DIR/build"
QEMU_SYSTEM_X86_64="$QEMU_BINDIR/qemu-system-x86_64"
QEMU_IMG="$QEMU_BINDIR/qemu-img"

function qemuBinExists() {
  if [[ -f "$QEMU_IMG" ]] && [[ -f "$QEMU_SYSTEM_X86_64" ]]; then
    return 0
  fi
  return 1
}

function onExit() {
  qemuBinExists
  exit $?
}

trap onExit EXIT

if qemuBinExists; then
  exit
fi

if [[ ! -d "$QEMU_DIR" ]]; then
  git clone --filter=blob:none --single-branch \
    --branch "v5.2.0/darwin-support" "https://github.com/shchuko/qemu.git" "$QEMU_DIR"
fi

cd "$QEMU_DIR"
./configure --target-list=x86_64-softmmu
make
cd -
