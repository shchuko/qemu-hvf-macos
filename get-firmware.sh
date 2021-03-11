#!/bin/bash
set -euo pipefail
#
# Firmware retrieval script
#

ZIP_NAME="OvmfDarwinBin.zip"
TAG_NAME="v0.1"
URL="https://github.com/shchuko/OvmfDarwinPkg/releases/download/$TAG_NAME/$ZIP_NAME"

FIRMWARE_DIR="./Firmware"
FIRMWARE_CODE="$FIRMWARE_DIR/OVMF_DARWIN_CODE.fd"
FIRMWARE_VARS="$FIRMWARE_DIR/OVMF_DARWIN_VARS.fd"
FIRMWARE_INFO="$FIRMWARE_DIR/FV_INFO.CONF"

[[ ! -d "$FIRMWARE_DIR" ]] && mkdir -p "$FIRMWARE_DIR"

if [[ -f "$FIRMWARE_CODE" ]] && [[ -f "$FIRMWARE_VARS" ]]; then
  echo "Firmware retrieval skipped, locally exists at: "
  find "$FIRMWARE_DIR" -type f
  exit 0
fi

wget "$URL"
yes | unzip "$ZIP_NAME" -d "$FIRMWARE_DIR"
rm "${ZIP_NAME:?}"

echo "Firmware downloaded: $TAG_NAME"
cat "$FIRMWARE_INFO"
