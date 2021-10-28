#!/bin/bash
#
# Add $INTERFACE to $BRIDGE members
# (same to `ip link set dev $INTERFACE master $BRIDGE`)
#

INTERFACE="${1:-en0}"
BRIDGE="${2:-bridge0}"

ifconfig "$BRIDGE" addm "$INTERFACE"
