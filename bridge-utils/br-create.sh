#!/bin/bash
#
# Create a new $BRIDGE
# (same to `ip link add name $BRIDGE type bridge`)
#
# Notice that bridge name should meet the `bridgeX` pattern (bridge0, bridge12, etc.)
#

BRIDGE="${1:-bridge0}"
ifconfig "$BRIDGE" create
ifconfig "$BRIDGE" up
