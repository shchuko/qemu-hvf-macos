#!/bin/bash

TAP_NAME="shchuko/qemu-macguest"
brew tap "$TAP_NAME"
brew update
brew install "$TAP_NAME/ovmf-darwin" "$TAP_NAME/qemu" "$TAP_NAME/libvirt"