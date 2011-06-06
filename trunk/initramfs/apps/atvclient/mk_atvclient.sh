#!/bin/bash

SCRIPT_DIR=$(dirname `readlink -f "$0"`)

cd "${SCRIPT_DIR}"

tar -xzf atvclient-0.1.tar.gz

#cd busybox-${VERSION}
#make
