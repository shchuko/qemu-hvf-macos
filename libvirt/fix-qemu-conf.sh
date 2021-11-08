#!/bin/bash
set -ex

PREFIX=$(brew config | grep HOMEBREW_PREFIX | awk 'FS=" " {print $2}')

# Set dynamic_ownership=0 into qemu.conf
sed -i '' 's/#dynamic_ownership[[:space:]]*=[[:space:]]*1/dynamic_ownership = 0/g' "$PREFIX/etc/libvirt/qemu.conf"
