#!/bin/bash
# Version 1.0 (February 24, 2008)
#
# This script is derived from:
#   http://www.shrewdlogic.com/wiki/AppleDMGUnderLinux
#
# The linux kernel contains hfs/hfs_plus support to mount volumes
# but there are no tools to create/repair hfs/hfs_plus file systems.
# This script assume that the apple source for "diskdev_cmds" and
# the patch to enabled building on Linux already exist.
# If not, the get them from here or search on google for them:
# wget http://www.mythic-beasts.com/resources/appletv/mb_boot_tv/diskdev_cmds-332.14.tar.gz
# wget http://www.ecl.udel.edu/~mcgee/diskdev_cmds/diskdev_cmds-332.14.patch.bz2
#
#
#
# Install the openssl source code and headers
sudo apt-get install libssl-dev
#
if [ ! -f diskdev_cmds-332.14.tar.gz ] ; then
	wget http://gentoo.osuosl.org/distfiles/diskdev_cmds-332.14.tar.gz
fi
#
# Unpack the source, patch it, and compile it
tar xzf diskdev_cmds-332.14.tar.gz
bunzip2 -c diskdev_cmds-332.14.patch.bz2 | patch -p0
cd diskdev_cmds-332.14
make -f Makefile.lnx
#
# Copy the newly created executables to the system /sbin directory
echo ""
echo "Copy executables to /build"
sudo cp newfs_hfs.tproj/newfs_hfs ../build/mkfs.hfsplus
sudo cp fsck_hfs.tproj/fsck_hfs ../build/fsck.hfsplus
sudo ln -sf /sbin/mkfs.hfsplus ../build/mkfs.hfs
sudo ln -sf /sbin/fsck.hfsplus ../build/fsck.hfs
#
# Done
cd ..
# 
# Clean up by removing created "diskdev_cmds" directory
echo ""
echo "Clean up"
rm -rf diskdev_cmds-332.14

