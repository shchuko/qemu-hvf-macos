#!/bin/bash
set -euo pipefail
#
# Firmware retrieval script
#

ARCHIVE_NAME="OvmfDarwinBin.tar.gz"
TAG_NAME="v1.0-edk2-stable202105"
URL="https://github.com/shchuko/OvmfDarwinPkg/releases/download/$TAG_NAME/$ARCHIVE_NAME"

FIRMWARE_DIR="./Firmware"
FIRMWARE_CODE="$FIRMWARE_DIR/OVMF_DARWIN_CODE.fd"
FIRMWARE_VARS="$FIRMWARE_DIR/OVMF_DARWIN_VARS.fd"
FIRMWARE_INFO="$FIRMWARE_DIR/FV_INFO.yaml"

if [[ ! -d "$FIRMWARE_DIR" ]]; then
  mkdir "$FIRMWARE_DIR"
fi

if [[ -f "$FIRMWARE_CODE" ]] && [[ -f "$FIRMWARE_VARS" ]] && [[ -f "$FIRMWARE_INFO" ]]; then
  echo "Firmware retrieval skipped, locally exists: "
  cat "$FIRMWARE_INFO"
  exit 0
fi

wget "$URL"


tar -xf "$ARCHIVE_NAME" -C "$FIRMWARE_DIR"
rm "${ARCHIVE_NAME:?}"

echo "Firmware downloaded: $TAG_NAME"
echo "$(cat $FIRMWARE_INFO)"
