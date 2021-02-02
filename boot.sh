#!/bin/bash

# QEMU/HVF macOS boot script example

loadDefaults() {
  QEMU_X86_64="qemu-system-x86_64"

  ATTACH_INSTALL_MEDIA="False"
  INSTALL_MEDIA="BaseSystem.cdr"
  INSTALL_MEDIA_FMT="raw"
  INSTALLMEDIA_ARGS=()

  DRIVE="drive.qcow2"
  DRIVE_FMT="qcow2"

  RAM=2048
  SMP=2
  OSK=""

  FIRMWARE_DIR="Firmware"
  FIRMWARE_CODE="$FIRMWARE_DIR/OVMF_DARWIN_CODE.fd"
  FIRMWARE_VARS="$FIRMWARE_DIR/OVMF_DARWIN_VARS.fd"
}

printHelp() {
  echo -e "QEMU/HVF macOS boot example script"
  echo -e "usage: ./builduefi.sh [options]"
  echo
  echo -e "options:"
  echo -e "\t-help\t\tPrint this help"
  echo -e "\t-qemu\tPATH\tPath to qemu-system-x86_64. Default is 'qemu-system-x86_64'"
  echo -e "\t-osk\tOSK\tOSK key for 'isa-applesmc' device. Default is empty string"
  echo -e "\t-install\tAttach install media for the first boot"
}

readArgs() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -qemu)
      QEMU_X86_64="$2"
      shift
      ;;

    -osk)
      OSK="$2"
      shift
      ;;

    -install)
      ATTACH_INSTALL_MEDIA="True"
      ;;

    -help)
      printHelp
      exit 0
      ;;

    *)
      shift
      ;;
    esac
    shift
  done
}

boot() {
  if [[ "$ATTACH_INSTALL_MEDIA" == "True" ]]; then
    INSTALLMEDIA_ARGS=(
      -drive "id=InstallMedia,if=none,file=$INSTALL_MEDIA,format=$INSTALL_MEDIA_FMT"
      -device "ide-hd,bus=sata.3,drive=InstallMedia"
    )
  fi

  QEMU_ARGS=(
    # Using host CPU may produce kernel panics, switch to Penryn if needed
    #-cpu "Penryn,vmware-cpuid-freq=on"
    -cpu "host,vmware-cpuid-freq=on"
    -machine "q35"
    -m "$RAM"
    -smp "$SMP"
    -accel "hvf"
    -smbios "type=2"
    -drive "id=Drive,if=none,file=$DRIVE,format=$DRIVE_FMT"
    -drive "if=pflash,format=raw,readonly,file=$FIRMWARE_CODE"
    -drive "if=pflash,format=raw,file=$FIRMWARE_VARS"
    -usb
    -device "usb-kbd"
    -device "usb-tablet"
    -device "isa-applesmc,osk=$OSK"
    -device "ich9-ahci,id=sata"
    -device "ide-hd,bus=sata.2,drive=Drive"
    "${INSTALLMEDIA_ARGS[@]}"
    -vga "std"
    -nic "user,model=vmxnet3"
    -boot c
  )

  "$QEMU_X86_64" "${QEMU_ARGS[@]}"
}

loadDefaults
readArgs "$@"
boot
