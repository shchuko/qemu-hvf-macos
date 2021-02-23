#!/bin/bash
set -euo pipefail

# Install app can be changed by overriding OS_NAME variable
OS_NAME="${OS_NAME:-Catalina}"
MEDIA_CREATOR="/Applications/Install macOS $OS_NAME.app/Contents/Resources/createinstallmedia"

# destination dir can be changed
DESTDIR="${DESTDIR:-out}"
IMAGE_NAME="$DESTDIR/BaseSystem"
IMAGE_NAME_DMG="$IMAGE_NAME.dmg"
IMAGE_NAME_RAW="$IMAGE_NAME.cdr"

MOUNTPOINT="/Volumes/install_build_$OS_NAME"
DISK_DEV=""

if [[ -f "$IMAGE_NAME_RAW" ]]; then
  echo "$IMAGE_NAME_RAW already exists!"
  exit 0
fi

case "$OS_NAME" in
"Big Sur")
  IMAGE_SIZE="12G"
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

  if [[ -f "$IMAGE_NAME_DMG" ]]; then
    rm "$IMAGE_NAME_DMG"
  fi
}
trap cleanup EXIT
trap cleanup INT
cleanup

mkdir -p "$DESTDIR"
# here hdiutil appends ".dmg" suffix to given output name
hdiutil create -o "$IMAGE_NAME" -size "$IMAGE_SIZE" -layout GPTSPUD -fs HFS+J
DISK_DEV=$(hdiutil attach "$IMAGE_NAME_DMG" -noverify -mountpoint "$MOUNTPOINT" | awk 'NR==1 {print $1}')
sudo "$MEDIA_CREATOR" --volume "$MOUNTPOINT" --nointeraction
hdiutil detach "$DISK_DEV"

# here hdiutil appends ".cdr" suffix to given output name
hdiutil convert "$IMAGE_NAME_DMG" -format UDTO -o "$IMAGE_NAME"
mv "$IMAGE_NAME.cdr" "$IMAGE_NAME_RAW"
