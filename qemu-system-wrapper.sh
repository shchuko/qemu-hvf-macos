#!/bin/bash
set -e
# QEMU/HVF macOS boot script example

##################
## SET ENV VARS ##
##################
QEMU_X86_64="qemu-system-x86_64"
RAM=${RAM:-4096M}
SMP=${SMP:-2}
MACADDR=${MACADDR:-""}
OSK=""

DRIVES_OPTIONS=()
NETDEVS_OPTIONS=()
NETCARDS_OPTIONS=()

NETDEVS_IDS=()

DRIVE_COUNTER=0
NETDEV_COUNTER=0
BOOTINDEX_COUNTER=0

while [[ $# -gt 0 ]]; do
  case "$1" in

  -help)
    SEP_1="\t"
    SEP_2="\t\t"

    echo -e "QEMU/HVF macOS boot example script"
    echo -e "usage: ./qemu-system-wrapper.sh [options]"
    echo
    echo -e "options:"
    echo -e "${SEP_1}-help${SEP_2}${SEP_1}Print this help"
    echo -e "${SEP_1}-qemu <PATH>${SEP_2}Path to qemu-system-x86_64. Default is 'qemu-system-x86_64'"
    echo -e "${SEP_1}-osk <OSK>${SEP_2}OSK key for 'isa-applesmc' device. Default is an empty string"
    echo -e "${SEP_1}-drive-qcow2 <FILE>${SEP_1}Attach qcow2 FILE as drive"
    echo -e "${SEP_1}-drive-raw <FILE>${SEP_1}Attach raw image FILE as drive"
    echo -e "${SEP_1}-net-tap <UP> <DOWN>${SEP_1}Attach tap netdev with UP and DOWN as tap-up and tap-down scripts"
    echo -e "${SEP_1}-net-user${SEP_2}Attach user netdev"
    echo -e "${SEP_1}-vmnet-shared${SEP_2}Attach vmnet-shared netdev"
    echo -e "${SEP_1}-vmnet-host${SEP_2}Attach vmnet-host netdev"
    echo -e "${SEP_1}-vmnet-bridged <IFNAME>${SEP_1}Attach vmnet-bridged netdev bridged onto IFNAME"
    echo
    echo -e "notes:"
    echo -e "${SEP_1}* drives' boot order meets this script arguments pass order"
    echo -e "${SEP_1}* netdevs' boot order meets this script arguments pass order"
    echo -e "${SEP_1}* this script requires 'source.sh' created by 'prepare-*.sh'"
    exit 0
    ;;

  -qemu)
    if [[ $# -gt 1 ]]; then
      QEMU_X86_64="$2"
      shift
    else
      echo "Wrong option -qemu: <PATH> is not provided"
      exit 1
    fi
    ;;

  -osk)
    if [[ $# -gt 1 ]]; then
      OSK="$2"
      shift
    else
      echo "Wrong option -osk: <OSK> is not provided"
      exit 1
    fi
    ;;

  -drive-qcow2)
    if [[ $# -gt 1 ]]; then
      QCOW2_PATH="$2"
      shift
    else
      echo "Wrong option -drive-qcow2: <FILE> is not provided"
      exit 1
    fi
    DRIVE_BOOTINDEX="$((BOOTINDEX_COUNTER++))"
    DRIVE_ID="drive$((DRIVE_COUNTER++))"
    DRIVES_OPTIONS+=(
      -drive "id=$DRIVE_ID,if=none,file=$QCOW2_PATH,format=qcow2"
      -device "virtio-blk-pci,drive=$DRIVE_ID,bootindex=$DRIVE_BOOTINDEX"
    )
    ;;

  -drive-raw)
    if [[ $# -gt 1 ]]; then
      IMAGE_PATH="$2"
      shift
    else
      echo "Wrong option -drive-raw: <FILE> is not provided"
      exit 1
    fi
    DRIVE_BOOTINDEX="$((BOOTINDEX_COUNTER++))"
    DRIVE_ID="drive$((DRIVE_COUNTER++))"
    DRIVES_OPTIONS+=(
      -drive "id=$DRIVE_ID,if=none,file=$IMAGE_PATH,format=raw"
      -device "virtio-blk-pci,drive=$DRIVE_ID,bootindex=$DRIVE_BOOTINDEX"
    )
    ;;

  -net-user)
    NETDEV_ID="netdev$((NETDEV_COUNTER++))"
    NETDEVS_IDS+=("$NETDEV_ID")
    NETDEVS_OPTIONS+=(
      -netdev "user,id=$NETDEV_ID"
    )
    ;;

  -net-tap)
    if [[ $# -gt 2 ]]; then
      TAP_UP_SCRIPT="$2"
      shift
      TAP_DOWN_SCRIPT="$2"
      shift
    else
      echo "Wrong option -net-tap: <UP> and <DOWN> are not provided"
      exit 1
    fi

    NETDEV_ID="netdev$((NETDEV_COUNTER++))"
    NETDEVS_IDS+=("$NETDEV_ID")
    NETDEVS_OPTIONS+=(
      -netdev "tap,id=$NETDEV_ID,script=$TAP_UP_SCRIPT,downscript=$TAP_DOWN_SCRIPT"
    )
    ;;

  -vmnet-shared)
    NETDEV_ID="netdev$((NETDEV_COUNTER++))"
    NETDEVS_IDS+=("$NETDEV_ID")
    NETDEVS_OPTIONS+=(
      -netdev "vmnet-shared,id=$NETDEV_ID"
    )
    ;;

  -vmnet-host)
    NETDEV_ID="netdev$((NETDEV_COUNTER++))"
    NETDEVS_IDS+=("$NETDEV_ID")
    NETDEVS_OPTIONS+=(
      -netdev "vmnet-host,id=$NETDEV_ID"
    )
    ;;

  -vmnet-bridged)
    if [[ $# -gt 1 ]]; then
      IFNAME="$2"
      shift
    else
      echo "Wrong option -vmnet-bridged: <IFNAME> is not provided"
      exit 1
    fi

    NETDEV_ID="netdev$((NETDEV_COUNTER++))"
    NETDEVS_IDS+=("$NETDEV_ID")
    NETDEVS_OPTIONS+=(
      -netdev "vmnet-bridged,id=$NETDEV_ID,ifname=$IFNAME"
    )
    ;;

  *)
    shift
    ;;
  esac
  shift
done

function nextMacAddr() {
  MAC="$1"
  MAC_HEX=$(echo "$MAC" | awk '{
    gsub(/:/, "");
    print toupper($0);
  }')

  NEXT_HEX=$(echo "obase=ibase=16;$MAC_HEX+1" | bc)
  NEXT_MAC=$(echo "$NEXT_HEX" | awk '{
    $0=sprintf("%012s", $0);
    gsub(/.{2}/,"&:");
    print substr($0, 0, 17);
  }')
  echo "$NEXT_MAC"
}

for NETDEV_ID in "${NETDEVS_IDS[@]}"; do
  if [[ -n "$MACADDR" ]]; then
    MACADDR_OPTION=",mac=$MACADDR"
    MACADDR=$(nextMacAddr "$MACADDR")
  else
    MACADDR_OPTION=""
  fi

  NETCARD_BOOTINDEX=$((BOOTINDEX_COUNTER++))
  NETCARDS_OPTIONS+=(
    -device "e1000-82545em${MACADDR_OPTION},netdev=$NETDEV_ID,bootindex=$NETCARD_BOOTINDEX"
  )
done

# Create UEFI from templates
if [[ ! -f "source.sh" ]]; then
  echo "Error: source.sh not found"
  exit 1
fi

source source.sh

FIRMWARE_TEMPLATES_DIR="$LOOKUP_PREFIX/share/OVMF_DARWIN"
FIRMWARE_DIR="$PWD/Firmware"
FIRMWARE_CODE="OVMF_DARWIN_CODE.fd"
FIRMWARE_VARS="OVMF_DARWIN_VARS.fd"

mkdir -p "$FIRMWARE_DIR"
if [[ ! -f "$FIRMWARE_DIR/$FIRMWARE_CODE" ]]; then
  install -m0444 "$FIRMWARE_TEMPLATES_DIR/$FIRMWARE_CODE" "$FIRMWARE_DIR/"

fi

if [[ ! -f "$FIRMWARE_DIR/$FIRMWARE_VARS" ]]; then
  install -m0666 "$FIRMWARE_TEMPLATES_DIR/$FIRMWARE_VARS" "$FIRMWARE_DIR/"
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
  -drive "if=pflash,format=raw,readonly=on,file=$FIRMWARE_DIR/$FIRMWARE_CODE"
  -drive "if=pflash,format=raw,readonly=off,file=$FIRMWARE_DIR/$FIRMWARE_VARS"
  -usb
  -device "usb-kbd"
  -device "usb-tablet"
  -device "isa-applesmc,osk=$OSK"
  -vga "virtio"
  "${DRIVES_OPTIONS[@]}"
  "${NETDEVS_OPTIONS[@]}"
  "${NETCARDS_OPTIONS[@]}"
  -nodefaults
)

echo "QEMU cmd: \"$QEMU_X86_64\" \"${QEMU_ARGS[*]}\""
"$QEMU_X86_64" "${QEMU_ARGS[@]}"
