#!/bin/bash

if [ ! -f linux-2.6.24.3.tar.gz ] ; then
	wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.24.3.tar.gz
fi
#
#
tar -xzf linux-2.6.24.3.tar.gz
cp linux.config  linux-2.6.24.3/.config
#
cd  linux-2.6.24.3
make oldconfig
make

#
cd ..
cp linux-2.6.24.3/arch/x86/boot/bzImage ../vmlinuz
