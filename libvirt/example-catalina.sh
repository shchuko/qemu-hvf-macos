#!/bin/bash

OUTPUT_DIR="$PWD/Catalina"

if [[ -d "$OUTPUT_DIR" ]]; then
  echo "Aborting, already exists: $OUTPUT_DIR"
  exit 1
fi
mkdir -p "$OUTPUT_DIR"

qemu-img create -f qcow2 "$OUTPUT_DIR/drive.qcow2" 50G

OUTPUT_DIR="$OUTPUT_DIR" ./createxml-catalina.sh
OUTPUT_DIR="$OUTPUT_DIR" ./createxml-installmedia.sh

DESTDIR="$OUTPUT_DIR" OS_NAME="Catalina" ../create-install-img.sh
