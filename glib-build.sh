#!/bin/bash
#
# GLib build script
# - build & install GLib into $GLIB_DESTDIR
#
set -eu

EXEC_PWD="$PWD"
GLIB_SRC="$PWD/glib-2.58.3"
GLIB_DESTDIR=${GLIB_DESTDIR:-"$PWD/glib-destdir"}

GLIB_CHECK_FILE="$GLIB_DESTDIR/lib/pkgconfig/glib-2.0.pc"
if [[ -f "$GLIB_CHECK_FILE" ]]; then
  echo "GLib build skipped, found: $GLIB_CHECK_FILE"
  exit 0
fi

mkdir -p "$GLIB_DESTDIR"

cd "$GLIB_SRC"
./autogen.sh --prefix="$GLIB_DESTDIR"
cd "$EXEC_PWD"

make -C "$GLIB_SRC"
make -C "$GLIB_SRC" install

