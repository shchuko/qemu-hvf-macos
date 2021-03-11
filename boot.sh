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

  RAM=4096M
  SMP=2
  OSK=""

  FIRMWARE_DIR="Firmware"
  FIRMWARE_CODE="$FIRMWARE_DIR/OVMF_DARWIN_CODE.fd"
  FIRMWARE_VARS="$FIRMWARE_DIR/OVMF_DARWIN_VARS.fd"

  NET_MACADDR="52:55:00:d1:55:01"

  USE_TAPPED_NET="False"
  TAP_UP_SCRIPT="no"
  TAP_DOWN_SCRIPT="no"
}

printHelp() {
  SEP_1="\t"
  SEP_2="\t\t"

  echo -e "QEMU/HVF macOS boot example script"
  echo -e "usage: ./builduefi.sh [options]"
  echo
  echo -e "options:"
  echo -e "${SEP_1}-help${SEP_2}Print this help"
  echo -e "${SEP_1}-install${SEP_1}Attach install media for the first boot"
  echo -e "${SEP_1}-qemu${SEP_1}PATH${SEP_1}Path to qemu-system-x86_64. Default is 'qemu-system-x86_64'"
  echo -e "${SEP_1}-osk${SEP_1}OSK${SEP_1}OSK key for 'isa-applesmc' device. Default is empty string"
  echo -e "${SEP_1}-mac${SEP_1}MACADDR\tSet custom netdev MAC Address"
  echo -e "${SEP_1}-tap${SEP_2}Use '-netdev tap' instead of '-nic user'"
  echo -e "${SEP_1}-t-up${SEP_1}FILE${SEP_1}Set '-netdev tap,script=FILE'"
  echo -e "${SEP_1}-t-down${SEP_1}DFILE${SEP_1}Set '-netdev tap,downscript=DFILE'"
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
    -mac)
      NET_MACADDR="$2"
      shift
      ;;
    -tap)
      USE_TAPPED_NET="True"
      ;;
    -t-up)
      TAP_UP_SCRIPT="$2"
      shift
      ;;
    -t-down)
      TAP_DOWN_SCRIPT="$2"
      shift
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
      -drive "id=InstallMedia,if=virtio,file=$INSTALL_MEDIA,format=$INSTALL_MEDIA_FMT"
      #-drive "id=InstallMedia,if=none,file=$INSTALL_MEDIA,format=$INSTALL_MEDIA_FMT"
      #-device "ide-hd,bus=sata.3,drive=InstallMedia"
    )
  fi

  if [[ "$USE_TAPPED_NET" == "True" ]]; then
    NET=(
      -netdev "tap,id=tapnet0,script=$TAP_UP_SCRIPT,downscript=$TAP_DOWN_SCRIPT"
      -device "e1000-82545em,netdev=tapnet0,mac=$NET_MACADDR"
    )
  else
    NET=(
      -nic "user,model=e1000-82545em,mac=$NET_MACADDR"
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
    -drive "id=Drive,if=virtio,file=$DRIVE,format=$DRIVE_FMT"
    #-drive "id=Drive,if=none,file=$DRIVE,format=$DRIVE_FMT"
    -drive "if=pflash,format=raw,readonly,file=$FIRMWARE_CODE"
    -drive "if=pflash,format=raw,file=$FIRMWARE_VARS"
    -usb
    -device "usb-kbd"
    -device "usb-tablet"
    -device "isa-applesmc,osk=$OSK"
    #-device "ich9-ahci,id=sata"
    #-device "ide-hd,bus=sata.2,drive=Drive"
    "${INSTALLMEDIA_ARGS[@]}"
    -vga "virtio"
    "${NET[@]}"
    -nodefaults
  )

  "$QEMU_X86_64" "${QEMU_ARGS[@]}"
}

loadDefaults
readArgs "$@"
echo "VM boot started.."
boot
