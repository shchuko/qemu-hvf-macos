#!/bin/bash
set -eo pipefail

if [[ -z ${PREFIX+x} ]]; then
  PREFIX=$(brew config | grep HOMEBREW_PREFIX | awk 'FS=" " {print $2}')
fi

NAME="${NAME:-Catalina}"
UUID="${UUID:-A6E2B09D-55FF-43E1-AB05-FB36F14E8106}"
OUTPUT_DIR="${OUTPUT_DIR:-$PWD/Catalina}"

DRIVE_BASENAME="${DRIVE_BASENAME:-drive.qcow2}"
DRIVE_PATH="${DRIVE_PATH:-$OUTPUT_DIR/$DRIVE_BASENAME}"
DRIVE_FMT="${DRIVE_FMT:-qcow2}"

VNC_PORT="${VNC_PORT:-5942}"
VNC_PASSWD="${VNC_PASSWD:-0000}"

UEFI_VARS_PATH="$OUTPUT_DIR/CATALINA_UEFI_VARS.fd"
RESULT_PATH="$OUTPUT_DIR/catalina.xml"

TEMPLATE_PATH="templates/catalina-template.xml"
UEFI_CODE="$PREFIX/share/OVMF_DARWIN/OVMF_DARWIN_CODE.fd"
UEFI_VARS_TEMPLATE="$PREFIX/share/OVMF_DARWIN/OVMF_DARWIN_VARS.fd"
EMULATOR="$(which qemu-system-x86_64)"

sed "s#%NAME%#$NAME#g" "$TEMPLATE_PATH" |
  sed "s#%UUID%#$UUID#g" |
  sed "s#%UEFI_CODE%#$UEFI_CODE#g" |
  sed "s#%UEFI_VARS_TEMPLATE%#$UEFI_VARS_TEMPLATE#g" |
  sed "s#%UEFI_VARS%#$UEFI_VARS_PATH#g" |
  sed "s#%EMULATOR%#$EMULATOR#g" |
  sed "s#%VNC_PORT%#$VNC_PORT#g" |
  sed "s#%VNC_PASSWD%#$VNC_PASSWD#g" |
  sed "s#%DRIVE_FMT%#$DRIVE_FMT#g" |
  sed "s#%DRIVE_PATH%#$DRIVE_PATH#g" >"$RESULT_PATH"
