#!/bin/bash
set -euo pipefail
#
# Firmware retrieval script
#

TAG_NAME="v1.0-edk2-stable202105"
ARCHIVE_NAME="ovmf-darwin-X64-RELEASE-$TAG_NAME.tar.gz"
URL="https://github.com/shchuko/OvmfDarwinPkg/releases/download/$TAG_NAME/$ARCHIVE_NAME"

FIRMWARE_DIR="./Firmware"
FIRMWARE_CODE="$FIRMWARE_DIR/OVMF_DARWIN_CODE.fd"
FIRMWARE_VARS="$FIRMWARE_DIR/OVMF_DARWIN_VARS.fd"

mkdir -p "$FIRMWARE_DIR"

if [[ -f "$FIRMWARE_CODE" ]] && [[ -f "$FIRMWARE_VARS" ]]; then
  echo "Firmware retrieval skipped, locally exists: "
  exit 0
fi

wget "$URL"
tar -xf "$ARCHIVE_NAME" -C "$FIRMWARE_DIR"
rm "${ARCHIVE_NAME:?}"

echo "Firmware downloaded: $TAG_NAME"
