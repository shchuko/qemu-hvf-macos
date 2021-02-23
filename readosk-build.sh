#!/bin/bash
set -euo pipefail
#
# readosk tool build script
#
# returns 'readosk' executable path
#

READOSK_DIR="./readosk"
READOSK_EXEC="$READOSK_DIR/readosk"

if [[ -f "$READOSK_EXEC" ]]; then
  exit 0
fi

cd "$READOSK_DIR"
./configure
make
cd -
