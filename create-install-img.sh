#!/bin/bash
#
# Install media RAW image creation script
# Defaults can be customized by setting:
#  OS_NAME            - destination OS name, default: "Catalina"
#  DESTDIR            - directory the image to be placed, default: "out"
#  TARGET_IMAGE_NAME  - media image name, default: "BaseSystem.cdr"
#
set -xeuo pipefail

OS_NAME="${OS_NAME:-Catalina}"
MEDIA_CREATOR="/Applications/Install macOS $OS_NAME.app/Contents/Resources/createinstallmedia"
DESTDIR="${DESTDIR:-out}"
IMAGE_NAME="$DESTDIR/BaseSystem"
TARGET_IMAGE_NAME="${TARGET_IMAGE_NAME:-$IMAGE_NAME.cdr}"
MOUNTPOINT="/Volumes/install_build_$OS_NAME"
DISK_DEV=""
TTY="$(tty)"

if [[ -f "$TARGET_IMAGE_NAME" ]]; then
  exit 0
fi

case "$OS_NAME" in
"Big Sur")
  IMAGE_SIZE="14G"
  ;;
*)
  IMAGE_SIZE="9G"
  ;;
esac

if [ ! -f "$MEDIA_CREATOR" ]; then
  exit 1
fi

cleanup() {
  if [[ -n "$DISK_DEV" ]]; then
    hdiutil detach -force "$DISK_DEV" || true
  fi

  if [[ -f "$IMAGE_NAME.dmg" ]]; then
    rm "$IMAGE_NAME.dmg"
  fi
}
trap cleanup EXIT INT
cleanup

mkdir -p "$DESTDIR"
# here hdiutil appends ".dmg" suffix to given output name
hdiutil create -o "$IMAGE_NAME" -size "$IMAGE_SIZE" -layout GPTSPUD -fs HFS+J
DISK_DEV=$(hdiutil attach "$IMAGE_NAME.dmg" -noverify -mountpoint "$MOUNTPOINT" | tee "$TTY" | awk 'NR==1 {print $1}')
sudo "$MEDIA_CREATOR" --volume "$MOUNTPOINT" --nointeraction
hdiutil detach "$DISK_DEV" && DISK_DEV=""

# here hdiutil appends ".cdr" suffix to given output name
hdiutil convert "$IMAGE_NAME.dmg" -format UDTO -o "$IMAGE_NAME"
mv "$IMAGE_NAME.cdr" "$TARGET_IMAGE_NAME"
