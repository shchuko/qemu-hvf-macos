#!/bin/bash
set -euo pipefail
#
# Firmware retrieval script
#

TAG_NAME="v1.0-edk2-stable202105"
ARCHIVE_NAME="ovmf-darwin-X64-RELEASE-$TAG_NAME.tar.gz"
URL="https://github.com/shchuko/OvmfDarwinPkg/releases/download/$TAG_NAME/$ARCHIVE_NAME"

FIRMWARE_DESTDIR=${DESTDIR:-"$PWD/destdir"}
INSTALL_DIR="$FIRMWARE_DESTDIR/share/OVMF_DARWIN"

WORK_DIR="$PWD"
TEMP_DIR="$(mktemp -d)"
FIRMWARE_CODE="OVMF_DARWIN_CODE.fd"
FIRMWARE_VARS="OVMF_DARWIN_VARS.fd"

cd "$TEMP_DIR"
wget "$URL"
tar -xvf "$ARCHIVE_NAME"

mkdir -p "$INSTALL_DIR"
install -m0444 "$TEMP_DIR/$FIRMWARE_CODE" "$INSTALL_DIR"
install -m0444 "$TEMP_DIR/$FIRMWARE_VARS" "$INSTALL_DIR"

function cleanup() {
    rm -rf "$TEMP_DIR"
    cd "$WORK_DIR"
}

trap cleanup EXIT
