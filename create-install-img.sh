#!/bin/bash

# Install app can be changed by overriding OS_NAME variable
if [[ -z "$OS_NAME" ]]; then
  OS_NAME="Catalina"
  echo "> Assuming: OS_NAME=Cataina"
fi

INSTALL_APP="/Applications/Install macOS $OS_NAME.app"
CREATE_MEDIA_APP="$INSTALL_APP/Contents/Resources/createinstallmedia"

if [[ -z "$DESTDIR" ]]; then
  DESTDIR="."
fi

IMAGE_NAME="BaseSystem"
IMAGE_NAME_DMG="$DESTDIR/$IMAGE_NAME.dmg"
IMAGE_NAME_RAW="$DESTDIR/$IMAGE_NAME.cdr"

MOUNTPOINT="/Volumes/install_build"

if [ ! -f "$CREATE_MEDIA_APP" ]; then
  echo "'$CREATE_MEDIA_APP' not exists"
  exit 1
fi

echo "> Creating temporary DMG image..."
[[ -f "$IMAGE_NAME_DMG" ]] && rm "$IMAGE_NAME_DMG"
hdiutil create -o "$IMAGE_NAME" -size 9G -layout GPTSPUD -fs HFS+J || exit 1

echo "> Mounting at $MOUNTPOINT..."
hdiutil attach "$IMAGE_NAME_DMG" -noverify -mountpoint "$MOUNTPOINT" || exit 1

echo "> Creating install media..."
sudo "$CREATE_MEDIA_APP" --volume "$MOUNTPOINT" --nointeraction || exit 1

echo "> Detaching install media..."
hdiutil detach "/Volumes/Install macOS $OS_NAME" || exit 1

echo "> Converting $IMAGE_NAME_DMG to RAW.."
hdiutil convert "$IMAGE_NAME_DMG" -format UDTO -o "$IMAGE_NAME" || exit 1

echo "> Cleaning..."
rm "$IMAGE_NAME_DMG"

echo "> Image is written to $IMAGE_NAME_RAW"
