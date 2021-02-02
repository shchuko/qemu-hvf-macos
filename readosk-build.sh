#!/bin/bash
#
# readosk tool build script
#
# returns 'readosk' executable path
#

READOSK_DIR="./readosk"
READOSK_EXEC="$READOSK_DIR/readosk"

if [[ -f "$READOSK_EXEC" ]]; then
  echo "$READOSK_EXEC"
  exit 0
fi

cd "$READOSK_DIR" || exit 1
./configure
make || exit 1
cd - || exit 1

echo "$READOSK_EXEC"
