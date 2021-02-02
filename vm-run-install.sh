#!/bin/bash
#
# macOS installation script example
#
# For the 1st boot provide '-install' flag
# Set OS version by '-os <OS NAME>' option
# /Applications/Install macOS <OS NAME>.app required!
#

# OS name to install
OS_NAME="Catalina"

# Install media image
INSTALL_IMG="BaseSystem.cdr"

# Creating drive to install macOS onto
# 50G is enough for Catalina
DRIVE_IMG="drive.qcow2"
DRIVE_IMG_SIZE="50G"


INSTALL_OS_FLAG="False"

# building QEMU
./qemu-build.sh
QEMU_EXEC="./qemu/build/qemu-system-x86_64"
if [[ -f "$QEMU_EXEC" ]]; then
  echo "QEMU Executable: $QEMU_EXEC"
else
  echo "QEMU Executable not found"
  exit 1
fi

# building readosk
./readosk-build.sh
READOSK_EXEC="./readosk/readosk"
echo "readosk Executable: $READOSK_EXEC"
if [[ -f "$READOSK_EXEC" ]]; then
  echo "readosk Executable: $QEMU_EXEC"
else
  echo "readosk Executable not found"
  exit 1
fi

if ! ./get-firmware.sh; then
  echo "Firmware retrieval error occured"
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
  -install)
    INSTALL_OS_FLAG="True"
    ;;

  -os)
    OS_NAME="$2"
    shift
    ;;

  *)
    shift
    ;;
  esac
  shift
done

# Creating install image
if [[ "$INSTALL_OS_FLAG" == "True" ]]; then
  if [[ ! -f "$INSTALL_IMG" ]]; then
    export OS_NAME
    if ! ./create-install-img.sh; then
      echo "Creating install image failed"
      exit 1
    fi
  fi
  # Creating drive to install macOS onto
  [[ ! -f "$DRIVE_IMG_NAME" ]] && qemu-img create -f qcow2 "$DRIVE_IMG" "$DRIVE_IMG_SIZE"

  echo "Starting installation"
  # Booting guest with install media attached
  ./boot.sh -install -qemu "$QEMU_EXEC" -osk "$($READOSK_EXEC)"
else
  echo "Booting...."
  # Booting guest without install media
  ./boot.sh -qemu "$QEMU_EXEC" -osk "$($READOSK_EXEC)"
fi
