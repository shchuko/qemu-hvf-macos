#!/bin/bash
#
# Destroy the $BRIDGE
# (same to `ip link del $BRIDGE`)
#

BRIDGE="${1:-bridge0}"
ifconfig "$BRIDGE" down
ifconfig "$BRIDGE" destroy
