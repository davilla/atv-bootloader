#!/bin/bash

if [ ! -f busybox-1.9.1.tar.gz ] ; then
	wget http://busybox.net/downloads/busybox-1.9.1.tar.gz
fi
#
tar -xzf busybox-1.9.1.tar.gz
cp busybox.config busybox-1.9.1/.config

cd busybox-1.9.1
make oldconfig
make
make install

cd ..
rm -rf build/*
cp -arp busybox-1.9.1/_install/* build/

rm -rf busybox-1.9.1

