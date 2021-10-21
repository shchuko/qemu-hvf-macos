#!/bin/bash
set -e
DESTDIR="$PWD/src-build-scripts/destdir"

cd src-build-scripts
./glib-build.sh
./qemu-build.sh
./readosk-build.sh
./retrive-firmware.sh
cd -

echo "#!/bin/bash
PATH=$DESTDIR/bin:$PATH
LOOKUP_PREFIX=$DESTDIR
" > source.sh
chmod u+x source.sh
