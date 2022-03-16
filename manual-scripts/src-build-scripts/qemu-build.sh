#!/bin/bash
set -euo pipefail
#
# QEMU Build script#
#  retrieve and build recent qemu v6.1.0 which includes patches:
#  - rdmsr 35H: https://github.com/qemu/qemu/commit/027ac0cb516cca4ce8a88dcca2f759c77e0e374b
#  - vmware-cpuid-freq: https://github.com/qemu/qemu/commit/3b502b0e470867369ba6e0a94e9ba6d91bb176c2
#  - vmnet-* netdevs https://patchew.org/QEMU/20220315230741.21578-1-Vladislav.Yaroshchuk@jetbrains.com/
#  - isa-applesmc hostosk extension https://patchew.org/QEMU/20220113152836.60398-1-yaroshchuk2000@gmail.com/
#

QEMU_GIT=${QEMU_GIT:-"https://github.com/shchuko/qemu.git"}
# Use branch with vmnet netdevs and isa-applesmc.hostosk features
# not reached upstream yet.
QEMU_BRANCH=${QEMU_BRANCH:-"v6.2.0-vmnet-v20-hostosk-v8"}
QEMU_DIR="$PWD/qemu"

QEMU_DESTDIR=${DESTDIR:-"$PWD/destdir"}
QEMU_SYSTEM_X86_64="$QEMU_DESTDIR/bin/qemu-system-x86_64"
QEMU_IMG="$QEMU_DESTDIR/bin/qemu-img"
GLIB_DESTDIR=${DESTDIR:-"$PWD/destdir"}
CUSTOM_PKG_CONFIG_PATH="$GLIB_DESTDIR/lib/pkgconfig"
PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-""}

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
  echo "QEMU building skipped, required binaries exist"
  exit
fi

if [[ ! -d "$QEMU_DIR" ]]; then
  git clone --filter=blob:none --single-branch --branch "$QEMU_BRANCH" "$QEMU_GIT" "$QEMU_DIR"
fi

cd "$QEMU_DIR"
PKG_CONFIG_PATH="$CUSTOM_PKG_CONFIG_PATH:$PKG_CONFIG_PATH" ./configure \
  --target-list=x86_64-softmmu --prefix="$QEMU_DESTDIR"
make qemu-system-x86_64
make install
cd -
