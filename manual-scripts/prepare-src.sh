#!/bin/bash
set -e
DESTDIR="$PWD/src-build-scripts/destdir"

cd src-build-scripts
./glib-build.sh
./qemu-build.sh
./retrive-firmware.sh
cd -

echo "#!/bin/bash
export PATH=$DESTDIR/bin:$PATH
export LOOKUP_PREFIX=$DESTDIR
" > env_override.sh
