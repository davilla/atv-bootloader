#!/bin/bash
# Version 1.0 (February 24, 2008)
# 
# This script builds a patched parted to support apple recovery GUID
# disk partitions. Using the flag "atvrcv" will make selected partions
# into one with an Apple "Recovery" GUID of 
# "5265636F-7665-11AA-AA11-00306543ECAC"
#
# The atv-bootloader must be installed into an Apple "Recovery" 
# partition in order for boot.efi to find and load it. In addition,
# there are several "support" files required". This script only
# creates a patched parted so that Apple "Recovery" partitons
# can be created.
#
# See the following link for gpt and GUID info
# http://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs
#
#
echo "Installing required build libs"
sudo apt-get install uuid-dev
sudo apt-get install libreadline5-dev
#
#
if [ ! -f "parted-1.8.8.tar.bz2" ] ; then
        echo "Downloading parted source"
        wget ftp.gnu.org/gnu/parted/parted-1.8.8.tar.bz2
fi
#
echo "Extracting parted source and patching"
tar -xjf parted-1.8.8.tar.bz2
cd parted-1.8.8
patch -p1 < ../appletv_parted-1.8.8.patch
#
#
echo "Building parted"
./configure --enable-static
make
cp parted/.libs/parted ../build
cp partprobe/.libs/partprobe ../build
cp libparted/.libs/libparted-1.8.so.8 ../build
cd ..
sudo rm -rf parted-1.8.8
