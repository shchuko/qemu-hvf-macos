#!/bin/bash

TAP_NAME="shchuko/qemu-macguest"
brew tap "$TAP_NAME"
brew update
brew install "$TAP_NAME/readosk" "$TAP_NAME/ovmf-darwin" "$TAP_NAME/qemu"

echo "#!/bin/bash
LOOKUP_PREFIX=$(brew config | grep HOMEBREW_PREFIX | awk 'FS=" " {print $2}')
" > source.sh
chmod u+x source.sh
