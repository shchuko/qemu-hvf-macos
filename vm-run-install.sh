#!/bin/bash
#
# macOS installation script example
#
# For the 1st boot provide '-install' flag
# Set OS version by '-os <OS NAME>' option
# /Applications/Install macOS <OS NAME>.app required!
#

function setVars() {
  # OS name to install
  OS="Catalina"

  # Don't attach install media image by default
  INSTALL_OS_FLAG="False"

  # Creating drive to install macOS onto
  # 50G is enough for Catalina
  MAIN_DRIVE_IMG="drive.qcow2"
  MAIN_DRIVE_IMG_SIZE="50G"

  # Executables
  QEMU_SYSTEM_X86_64="./qemu/build/qemu-system-x86_64"
  QEMU_IMG="./qemu/build/qemu-img"
  READOSK="./readosk/readosk"

  # No external options by default
  OPTIONS=()

  TAP_UP_SCRIPT="./tap-up.sh"
  TAP_DOWN_SCRIPT="./tap-down.sh"
}

function readArgs() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -install)
      INSTALL_OS_FLAG="True"
      ;;

    -os)
      OS="$2"
      shift
      ;;

    -tap-net)
      OPTIONS+=(
      "-tap"
      "-t-up" "$TAP_UP_SCRIPT"
      "-t-down" "$TAP_DOWN_SCRIPT"
      )
      ;;
    *)
      shift
      ;;
    esac
    shift
  done
}

function loadComponents() {
  # QEMU download and build
  if ! ./qemu-build.sh; then
    echo "QEMU build failed"
    return 1
  fi

  # 'readosk' tool build
  ./readosk-build.sh
  if [[ ! -f "$READOSK" ]]; then
    echo "readosk build failed"
    return 1
  fi

  # QEMU Firmware download
  if ! ./get-firmware.sh; then
    echo "QEMU firmware download failed"
    return 1
  fi
}

function createInstallImg() {
  DESTDIR="." OS_NAME="$OS" ./create-install-img.sh
  return $?
}

function createMainDrive() {
  if [[ -f "$MAIN_DRIVE_IMG" ]]; then
    return
  fi

  "$QEMU_IMG" create -f qcow2 "$MAIN_DRIVE_IMG" "$MAIN_DRIVE_IMG_SIZE"
  return $?
}

function startBoot() {
    ./boot.sh -qemu "$QEMU_SYSTEM_X86_64" -osk "$($READOSK)" "${OPTIONS[@]}"
}

setVars
readArgs "$@"

if ! loadComponents; then
  echo "Required components not present!"
  exit 1
fi

if ! createMainDrive; then
  echo "Drive creation failed"
  exit 1
fi

if [[ "$INSTALL_OS_FLAG" == "True" ]]; then
  if ! createInstallImg; then
    echo "Install image creation failed"
    exit 1
  fi

  OPTIONS+=("-install")
fi

startBoot
