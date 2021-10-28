#!/bin/bash
set -ex

PREFIX=$(brew config | grep HOMEBREW_PREFIX | awk 'FS=" " {print $2}')

# Set dynamic_ownership=0 into qemu.conf
sed -i '' 's/#dynamic_ownership[[:space:]]*=[[:space:]]*1/dynamic_ownership = 0/g' "$PREFIX/etc/libvirt/qemu.conf"

# Copy launchd.plist configs
sudo cp -fi "$PREFIX/opt/libvirt/libvirtd.service.plist" "/Library/LaunchDaemons/"
sudo cp -fi "$PREFIX/opt/libvirt/virtlogd.service.plist" "/Library/LaunchDaemons/"
# Launch 'libvirtd' and 'virtlogd' daemons
sudo launchctl load "/Library/LaunchDaemons/libvirtd.service.plist"
sudo launchctl load "/Library/LaunchDaemons/virtlogd.service.plist"
