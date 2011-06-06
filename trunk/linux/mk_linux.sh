#!/bin/bash

SCRIPT_DIR=$(dirname `readlink -f "$0"`)
cd "${SCRIPT_DIR}"

VERSION="2.6.39"
CONFIG="linux-${VERSION}.config"

if [ ! -f linux-${VERSION}.tar.bz2 ] ; then
	wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-${VERSION}.tar.bz2
fi
#
#
tar -jxf linux-${VERSION}.tar.bz2

if [ -f "${CONFIG}" ] ; then
	cp "${CONFIG}"  linux-${VERSION}/.config
else
	cp linux.config  linux-${VERSION}/.config
fi
#
cd  linux-${VERSION}
make oldconfig
make

#
cd "${SCRIPT_DIR}"
cp linux-${VERSION}/arch/x86/boot/bzImage ../vmlinuz
