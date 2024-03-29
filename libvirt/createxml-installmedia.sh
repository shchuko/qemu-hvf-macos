#!/bin/bash
set -eo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-$PWD}"
XML_PATH="${XML_PATH:-$OUTPUT_DIR/installmedia.xml}"

INSTALLMEDIA_FORMAT="${INSTALLMEDIA_FORMAT:-raw}"
INSTALLMEDIA_PATH="${INSTALLMEDIA_PATH:-$OUTPUT_DIR/BaseSystem.cdr}"

TEMPLATE_PATH="templates/installmedia-template.xml"

sed "s#%INSTALLMEDIA_PATH%#$INSTALLMEDIA_PATH#g" "$TEMPLATE_PATH" |
  sed "s#%INSTALLMEDIA_FORMAT%#$INSTALLMEDIA_FORMAT#g" >"$XML_PATH"
