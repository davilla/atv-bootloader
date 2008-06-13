#!/bin/bash

if [ ! -f kexec-tools-testing-20080324.tar.gz ] ; then
	wget http://www.kernel.org/pub/linux/kernel/people/horms/kexec-tools/kexec-tools-testing-20080324.tar.gz
fi
#
#
tar -xzf kexec-tools-testing-20080324.tar.gz
cd kexec-tools-testing-20080324
#
#
./configure
make

cp -f build/sbin/kexec ../build
#
cd ..
rm -rf kexec-tools-testing-20080324

