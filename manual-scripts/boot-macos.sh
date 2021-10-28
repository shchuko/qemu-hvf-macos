#!/bin/bash
#
# macOS installation script example
#
#
set -eo pipefail

##################
## SET ENV VARS ##
##################
INSTALL_OS_FLAG="False"
INSTALL_IMAGE="./BaseSystem.cdr"
BOOT_FROM_INSTALL_MEDIA="False"

# Creating drive to install macOS onto
# 50G is enough for Catalina
DEFAULT_DRIVE_IMG=${DRIVE_IMG:-"./drive.qcow2"}
DEFAULT_DRIVE_IMG_SIZE="50G"
DEFAULT_DRIVE_ATTACH_FLAG="True"

# Executables
QEMU_SYSTEM_X86_64="qemu-system-x86_64"
QEMU_IMG="qemu-img"

# Attach only main drive by default
OPTIONS=()
OS_INSTALL_MEDIA_OPTIONS=()
DEFAULT_DRIVE_OPTIONS=(
  "-drive-qcow2" "$DEFAULT_DRIVE_IMG"
)
DYNAMIC_OPTIONS=()

TAP_UP_SCRIPT="./bridge-utils/br-add-member.sh"
TAP_DOWN_SCRIPT="./bridge-utils/br-rm-member.sh"

###########################
## READ SCRIPT ARGUMENTS ##
###########################
while [[ $# -gt 0 ]]; do
  case "$1" in
  -help)
    SEP_1="\t"
    SEP_2="\t\t"

    echo -e "QEMU/HVF macOS boot example script"
    echo -e "usage: ./boot-macos.sh [options]"
    echo
    echo -e "options:"
    echo -e "${SEP_1}-help${SEP_1}${SEP_2}Print this help"
    echo -e "${SEP_1}-no-default-drive${SEP_1}Do not create and attach default drive"
    echo -e "${SEP_1}-install-macos <OSNAME>${SEP_1}Create and attach OSNAME macOS install media for the first boot"
    echo -e "${SEP_1}-drive-qcow2 <FILE>${SEP_1}Attach qcow2 FILE as drive"
    echo -e "${SEP_1}-drive-raw <FILE>${SEP_1}Attach raw image FILE as drive"
    echo -e "${SEP_1}-installmedia-boot${SEP_1}Boot from install media instead of default drive"
    echo -e "${SEP_1}-net-user${SEP_2}Attach user (slirp) netdev"
    echo -e "${SEP_1}-net-tap${SEP_2}Attach tap netdev"
    echo -e "${SEP_1}-vmnet-shared${SEP_2}Attach vmnet-shared netdev"
    echo -e "${SEP_1}-vmnet-host${SEP_2}Attach vmnet-host netdev"
    echo -e "${SEP_1}-vmnet-bridged <IFNAME>${SEP_1}Attach vmnet-bridged netdev bridged onto IFNAME"
    echo
    echo -e "notes:"
    echo -e "${SEP_1}* default drive has the highest boot priority (if '-installmedia-boot' not present)"
    echo -e "${SEP_1}* installation media has the highest boot priority after default drive"
    echo -e "${SEP_1}* drives' boot order meets this script arguments pass order"
    echo -e "${SEP_1}* netdevs' boot order meets this script arguments pass order"
    echo -e "${SEP_1}* drives have higher boot priority than netdevs"
    echo -e "${SEP_1}* this script requires 'source.sh' created by 'prepare-*.sh'"
    exit 0
    ;;
  -install-macos)
    if [[ $# -gt 1 ]]; then
      INSTALL_OS_FLAG="True"
      OS="$2"
      shift
    else
      echo "Wrong option -install-os: OSNAME is not provided"
      exit 1
    fi
    ;;

  -no-default-drive)
    DEFAULT_DRIVE_ATTACH_FLAG="False"
    DEFAULT_DRIVE_OPTIONS=()
    ;;

  -installmedia-boot)
    BOOT_FROM_INSTALL_MEDIA="True"
    ;;

  -drive-qcow2)
    if [[ $# -gt 1 ]]; then
      DRIVE_PATH="$2"
      shift
    else
      echo "Wrong option -drive-qcow2: FILE is not provided"
      exit 1
    fi
    DYNAMIC_OPTIONS+=(
      "-drive-qcow2" "$DRIVE_PATH"
    )
    ;;

  -drive-raw)
    if [[ $# -gt 1 ]]; then
      DRIVE_PATH="$2"
      shift
    else
      echo "Wrong option -drive-raw: FILE is not provided"
      exit 1
    fi
    DYNAMIC_OPTIONS+=(
      "-drive-raw" "$DRIVE_PATH"
    )
    ;;

  -net-user)
    DYNAMIC_OPTIONS+=(
      "-net-user"
    )
    ;;

  -net-tap)
    DYNAMIC_OPTIONS+=(
      "-net-tap" "$TAP_UP_SCRIPT" "$TAP_DOWN_SCRIPT"
    )
    ;;

  -vmnet-shared)
    DYNAMIC_OPTIONS+=(
      "-vmnet-shared"
    )
    ;;

  -vmnet-host)
    DYNAMIC_OPTIONS+=(
      "-vmnet-host"
    )
    ;;

  -vmnet-bridged)
    if [[ $# -gt 1 ]]; then
      VMNET_IFNAME="$2"
      shift
    else
      echo "Wrong option -vmnet-bridged: FILE is not provided"
      exit 1
    fi
    DYNAMIC_OPTIONS+=(
      "-vmnet-bridged" "$VMNET_IFNAME"
    )
    ;;

  *) ;;

  esac
  shift
done

##################
## UPDATE $PATH ##
##################
if [[ ! -f "source.sh" ]]; then
  echo "Error: source.sh not found"
  exit 1
fi

source source.sh

#########################
## CREATE DRIVE IMAGES ##
#########################
if [[ ! -f "$DEFAULT_DRIVE_IMG" && "$DEFAULT_DRIVE_ATTACH_FLAG" == "True" ]]; then
  "$QEMU_IMG" create -f qcow2 "$DEFAULT_DRIVE_IMG" "$DEFAULT_DRIVE_IMG_SIZE"
fi

if [[ "$INSTALL_OS_FLAG" == "True" ]]; then
  DESTDIR="." OS_NAME="$OS" ../create-install-img.sh
  OS_INSTALL_MEDIA_OPTIONS+=("-drive-raw" "$INSTALL_IMAGE")
fi

######################
## SETUP BOOT ORDER ##
######################
if [[ "$BOOT_FROM_INSTALL_MEDIA" == "True" ]]; then
  OPTIONS+=(
    "${OS_INSTALL_MEDIA_OPTIONS[@]}"
    "${DEFAULT_DRIVE_OPTIONS[@]}"
  )
else

  OPTIONS+=(
    "${DEFAULT_DRIVE_OPTIONS[@]}"
    "${OS_INSTALL_MEDIA_OPTIONS[@]}"
  )
fi

#################
## RUN QEMU VM ##
#################
OPTIONS+=("${DYNAMIC_OPTIONS[@]}")

./qemu-system-wrapper.sh -qemu "$QEMU_SYSTEM_X86_64" "${OPTIONS[@]}"
