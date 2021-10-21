#!/bin/bash
#
# GLib retrieve & build script
# - installs GLib into $GLIB_DESTDIR
#
set -eu

EXEC_PWD="$PWD"
GLIB_REMOTE="https://gitlab.gnome.org/GNOME/glib.git"
GLIB_VERSION="2.58.3" # Equal to git branch
GLIB_SRC_DIR="$PWD/glib"
GLIB_DESTDIR=${DESTDIR:-"$PWD/destdir"}

if [[ ! -d "$GLIB_SRC_DIR" ]]; then
  git clone --filter=blob:none --single-branch \
    --branch "$GLIB_VERSION" "$GLIB_REMOTE" "$GLIB_SRC_DIR"
fi

GLIB_CHECK_FILE="$GLIB_DESTDIR/lib/pkgconfig/glib-2.0.pc"
if [[ -f "$GLIB_CHECK_FILE" ]]; then
  echo "GLib build skipped, found: $GLIB_CHECK_FILE"
  exit 0
fi

mkdir -p "$GLIB_DESTDIR"

cd "$GLIB_SRC_DIR"
./autogen.sh --prefix="$GLIB_DESTDIR"
cd "$EXEC_PWD"

make -C "$GLIB_SRC_DIR"
make -C "$GLIB_SRC_DIR" install
