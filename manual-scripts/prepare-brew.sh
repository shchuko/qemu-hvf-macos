#!/bin/bash

TAP_NAME="shchuko/qemu-macguest"
brew tap "$TAP_NAME"
brew update
brew install "$TAP_NAME/ovmf-darwin" "$TAP_NAME/qemu"

if [[ -f "env_override.sh" ]]; then
  rm "env_override.sh"
fi