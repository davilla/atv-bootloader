#!/bin/bash

VERSION="1.18.4"

if [ ! -f busybox-${VERSION}.tar.bz2 ] ; then
	wget http://busybox.net/downloads/busybox-${VERSION}.tar.bz2
fi
#
tar -xjf busybox-${VERSION}.tar.bz2
cp busybox.config busybox-${VERSION}/.config

cd busybox-${VERSION}
make oldconfig
make
make install

cd ..
rm -rf build/*
cp -arp busybox-${VERSION}/_install/* build/

rm -rf busybox-${VERSION}

