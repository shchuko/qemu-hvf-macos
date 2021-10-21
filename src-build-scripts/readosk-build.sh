#!/bin/bash
set -euo pipefail
#
# readosk tool build script
#
# returns 'readosk' executable path
#

READOSK_REMOTE=${READOSK_REMOTE:-"https://github.com/shchuko/readosk.git"}
READOSK_BRANCH=${READOSK_BRANCH:-"v0.0.1"}

READOSK_DIR="$PWD/readosk"
READOSK_DESTDIR=${DESTDIR:-"$PWD/destdir"}

READOSK_EXEC="$READOSK_DESTDIR/bin/readosk"

if [[ ! -d "$READOSK_DIR" ]]; then
  git clone --filter=blob:none --single-branch \
    --branch "$READOSK_BRANCH" "$READOSK_REMOTE" "$READOSK_DIR"
fi

if [[ -f "$READOSK_EXEC" ]]; then
  echo "readosk build skipped, required binary exists"
  exit 0
fi

cd "$READOSK_DIR"
./configure --prefix "$READOSK_DESTDIR"
make install
make clean
cd -
