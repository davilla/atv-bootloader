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

# go into rootfs
mkdir -p rootfs
rm -rf rootfs/*
#
cd rootfs

# create default driectory structure
mkdir -p bin dev etc/init.d lib media mnt proc root sbin sys
mkdir -p tmp usr/bin usr/sbin usr/lib usr/share usr/local
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
cp -af /bin/bash			bin/
cp -af /usr/bin/ldd                     usr/bin/
cp -af /sbin/ldconfig.real		sbin/ldconfig
#cp -af /sbin/findfs                    sbin/
cp -af /sbin/dosfsck			sbin/fsck.msdos
cp -af /sbin/mkdosfs			sbin/mkfs.msdos
cp -af /sbin/mkfs.ext3			sbin/
cp -af /sbin/fsck.ext3                  sbin/
ln -s  /sbin/fsck.ext3 sbin/fsck.ext2
cp -af /sbin/fsck.nfs			sbin/
cp -af /sbin/fsck.xfs			sbin/
cp -af /sbin/fsck.reiserfs		sbin/

# copy lspci
#cp -af /usr/bin/lspci                  usr/bin/

# copy nano, add sybolic link to pico
cp -af /bin/nano                        bin/
ln -s  /bin/nano bin/pico

# copy our built apps
cp -af ../apps/kexec/build/kexec        sbin/
cp -af ../apps/rEFIt/build/gptsync	usr/bin/
cp -af ../apps/parted/build/parted	usr/sbin/
cp -af ../apps/parted/build/partprobe	usr/sbin/
cp -af ../apps/hfs_support/build/fsck.hfs  sbin/
cp -af ../apps/hfs_support/build/fsck.hfsplus sbin/
cp -af ../apps/hfs_support/build/mkfs.hfsplus sbin/

# copy out helper apps/scripts
cp -af ../apps/boot_linux.sh		usr/sbin/
cp -af ../apps/boot_parser/boot_parser	usr/sbin/
cp -af ../apps/find_run_script.sh	usr/sbin/

# copy seed files for startup
cp -af ../seed_files/init		./
chmod +x ./init
cp -af ../seed_files/busybox.conf	etc/
cp -af ../seed_files/mdev.conf		etc/
cp -af ../seed_files/fstab		etc/
cp -af ../seed_files/inittab		etc/
cp -af ../seed_files/rcS  		etc/init.d/
cp -af ../seed_files/rc.reboot		etc/init.d/
cp -af ../seed_files/rc.shutdown	etc/init.d/
chmod +x etc/init.d/rcS
chmod +x etc/init.d/rc.reboot
chmod +x etc/init.d/rc.shutdown
cp -af ../seed_files/hosts		etc/
cp -af ../seed_files/hostname		etc/
cp -af ../seed_files/udhcpd.conf	etc/
mkdir -p usr/share/udhcpc/
cp -af ../seed_files/default.script	usr/share/udhcpc/default.script
chmod +x usr/share/udhcpc/default.script
#
cp -af ../seed_files/passwd		etc/
cp -af ../seed_files/group		etc/
cp -af ../seed_files/shadow		etc/
cp -af ../seed_files/shadow-		etc/

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
#find . | cpio --create --'format=newc' | gzip >../../initrd.gz
find . | cpio -H newc -o | gzip >../../initrd.gz
#
cd ..
