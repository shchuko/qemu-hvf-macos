#!/bin/sh
#
# Remove $INTERFACE from $BRIDGE members
# (same to `ip link set dev $INTERFACE nomaster`)
#
INTERFACE="${1:-en0}"
BRIDGE="${2:-bridge0}"

ifconfig "$BRIDGE" deletem "$INTERFACE"
