#!/bin/bash
set -ex

PREFIX=$(brew config | grep HOMEBREW_PREFIX | awk 'FS=" " {print $2}')

# Set dynamic_ownership=0 into qemu.conf
sed -i '' 's/#dynamic_ownership[[:space:]]*=[[:space:]]*1/dynamic_ownership = 0/g' "$PREFIX/etc/libvirt/qemu.conf"



LIBVIRTDFILE="$PREFIX/etc/libvirt/libvirtd.conf"
LBDACKUPFILEBACKUPFILE="$LIBVIRTDFILE."$(date +%s)
cp "$LIBVIRTDFILE" "$LBDACKUPFILEBACKUPFILE"
# set  unix_sock_ro_perms = "0777"
sed -i '' 's/#unix_sock_ro_perms/unix_sock_ro_perms/' "$LIBVIRTDFILE"
# set  unix_sock_rw_perms = "0777"
sed -i ''  's/#unix_sock_rw_perms/unix_sock_rw_perms/' "$LIBVIRTDFILE"

LIBVIRTFILE="$PREFIX/etc/libvirt/libvirt.conf"
LBACKUPFILEBACKUPFILE="$LIBVIRTFILE."$(date +%s)
cp "$LIBVIRTFILE" "$LBACKUPFILEBACKUPFILE"
# set
sed -i ''  's/#uri_default/uri_default/' "$LIBVIRTFILE"

