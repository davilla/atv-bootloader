#!/bin/bash
#
# Version 1.2 (May 17, 2008)
#
# Poor mans buildroot. Buildroot via busybox is too complicated
# so we hack our own. Since we have lots of space we don't care
# about uclibc and use libc directly by copying the libs from a
# running system (ubuntu 7.10 here). ldd is our friend as it tells
# us the lib dependencies for any lib/app. We use busybox for most
# common apps and copy and other we need. 
#
# warning, make sure that any apps that are copied do not have 
# equivalent busybox symlinks or they will over-write busybox
# when copied. This can cause very bad things to happen.

# go into rootfs
mkdir -p rootfs
rm -rf rootfs/*
#
cd rootfs

# create default driectory structure
mkdir -p bin dev etc/init.d lib media mnt proc root sbin sys
mkdir -p tmp usr/bin usr/sbin usr/lib usr/share usr/local
mkdir -p usr/share/terminfo
ln -s ../../usr/bin  usr/local/bin 
ln -s ../../usr/sbin usr/local/sbin
ln -s ../../usr/lib  usr/local/lib
mkdir -p var/lib/misc var/lock var/log var/run var/tmp
chmod 1777 tmp
chmod 1777 var/tmp

# minimum device files needed to boot linux
[ -e dev/console ] || mknod dev/console c 5 1
[ -e dev/null ] || mknod dev/null c 1 3
[ -e dev/tty ] || mknod dev/tty c 5 0
[ -e dev/tty1 ] || mknod dev/tty1 c 4 1

# copy busybox install directory contents
cp -arp ../apps/busybox/build/*	./

# copy standard apps
#
cp -a  /bin/bash			bin/
#cp -a  /usr/bin/ldd                     usr/bin/
cp -a  /sbin/ldconfig.real		sbin/ldconfig
#
cp -a  /sbin/dosfsck			sbin/fsck.msdos
ln -s  /sbin/fsck.msdos sbin/fsck.vfat
cp -a  /sbin/mkdosfs			sbin/mkfs.msdos
cp -a  /sbin/mkfs.ext3			sbin/
#cp -a  /sbin/fsck                  sbin/
cp -a  /sbin/fsck.ext3                  sbin/
ln -s  /sbin/fsck.ext3 sbin/fsck.ext2

cp -a  /sbin/fsck.nfs			sbin/
cp -a  /sbin/fsck.xfs			sbin/
cp -a  /sbin/fsck.reiserfs		sbin/

# copy blkid, findfs
cp -a  /sbin/blkid                    sbin/
cp -a  /sbin/findfs                    sbin/

# copy lspci
cp -a  /usr/bin/lspci			usr/bin/

# copy nano, add sybolic link to pico
cp -a  /bin/nano                        bin/
ln -s  /bin/nano bin/pico

# copy our built apps
cp -a  ../apps/kexec/build/kexec        sbin/
cp -a  ../apps/rEFIt/build/gptsync	usr/bin/
cp -a  ../apps/parted/build/parted	usr/sbin/
cp -a  ../apps/parted/build/partprobe	usr/sbin/
cp -a  ../apps/hfs_support/build/fsck.hfsplus sbin/
ln -s  sbin/fsck.hfsplus sbin/fsck.hfs
cp -a  ../apps/hfs_support/build/mkfs.hfsplus sbin/
ln -s  sbin/mkfs.hfsplus sbin/mkfs.hfs
# copy out helper apps/scripts
cp -a  ../apps/boot_linux.sh		usr/sbin/
cp -a  ../apps/boot_parser/boot_parser	usr/sbin/
cp -a  ../apps/find_run_script.sh	usr/sbin/

# copy seed files for startup
cp -a  ../seed_files/init		./
chmod +x ./init
cp -a  ../seed_files/busybox.conf	etc/
cp -a  ../seed_files/mdev.conf		etc/
cp -a  ../seed_files/fstab		etc/
cp -a  ../seed_files/inittab		etc/
cp -a  ../seed_files/rcS  		etc/init.d/
chmod +x etc/init.d/rcS
cp -a  ../seed_files/shutdown		sbin/
chmod +x sbin/shutdown
cp -a  ../seed_files/hosts		etc/
cp -a  ../seed_files/hostname		etc/
cp -a  ../seed_files/udhcpd.conf	etc/
mkdir -p usr/share/udhcpc/
cp -a  ../seed_files/default.script	usr/share/udhcpc/default.script
chmod +x usr/share/udhcpc/default.script
#
cp -a  ../seed_files/passwd		etc/
cp -af ../seed_files/group		etc/
cp -af ../seed_files/shadow		etc/
cp -af ../seed_files/shadow-		etc/
#
cp -aL /usr/share/terminfo/a		usr/share/terminfo/
cp -aL /usr/share/terminfo/l		usr/share/terminfo/
cp -aL /usr/share/terminfo/v		usr/share/terminfo/
cp -aL /usr/share/terminfo/x		usr/share/terminfo/

cd ..
make -f cpy_libs.mk >/dev/null 2>&1
# copy Libs that get missed ??
cp /lib/libnss_dns.so.2			rootfs/lib/
cp /lib/libresolv.so.2			rootfs/lib/

cd rootfs
strip --strip-debug lib/*  >/dev/null 2>&1
strip --strip-debug bin/*  >/dev/null 2>&1
strip --strip-debug sbin/* >/dev/null 2>&1
strip --strip-debug usr/lib/*  >/dev/null 2>&1
strip --strip-debug usr/bin/*  >/dev/null 2>&1
strip --strip-debug usr/sbin/* >/dev/null 2>&1

# Run ldconfig so busybox and other binaries can
#   have access to the libraries that they need
ldconfig -r ./

# create initramfs (initrd)
echo "Create cpio based initrd"
find . | cpio -H newc -o | gzip >../../initrd.gz
#
cd ..
