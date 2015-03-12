![http://atv-bootloader.googlecode.com/svn/branches/web_items/logos/gentoo.jpg](http://atv-bootloader.googlecode.com/svn/branches/web_items/logos/gentoo.jpg)

## Introduction ##

Make sure you first [backup](ATVBackup.md) if you intend on changing the original AppleTV internal PATA.

This page describes the process to install Gentoo Linux on an Apple TV device and was contributed by Victor Wodecki.

The aim of this installation is to produce a device that has a good USB support,and that uses as little RAM as possible.  Hence an emphasis has been placed on USB and a lean kernel, and very little on (for example) video and sound.

We use a vanilla kernel rather than a Gentoo-patched one, to make it easier to share configurations (and bugs!) with other distributions on this hardware.

## Caveats ##

These instructions are a work-in-progress.  At the time of writing I'm aware of these issues:
  * Confusion between /dev/hda & /dev/hdb, means difference between grub.conf and fstab.  Not a big problem, but annoying.

## Pre-requisites ##

You'll need:
  * An Apple TV.  In my case I'm using a 160GB version, but that shouldn't make any difference.
  * OPTIONAL: A 2.5" (laptop) IDD hard disk.  I'm using one which is the same model & geometry as the one in my Apple TV, which is a Samsung 160GB HDD, but once again this shouldn't make a difference.  In this guide, I'm assuming that the HDD in its original (virgin) state, with no existing partitions or content
  * A USB/IDE adapter.  I'm using one of those external HDD cases, which has an internal IDE plug and an external USB 2.0 plug, the HDD has been mounted inside this case.
  * A host computer.  In my case, I've used a Fedora 8 system.  You could probably use another distribution, feel free to try, but you'll need to check what is or isn't built into the kernel of the particular distribution (eg HFS+ support, SCSI, etc), as well as default mount points.  Make sure you're set up as a sudo user.
  * A fast network link.
  * Lots of time.

You can either use the HDD that is already in the Apple TV, or you can buy a new one just for this purpose.

## Overview ##

The approach we take is to connect the HDD to the host computer via USB, partition it, format the partitions, install the bootloader, and then install Gentoo.  Most of this is done using the USB interface.  This setup should then provide a hard disk image which can either boot externally via USB or internally via IDE (assuming you change grub and fstab appropriately), but I can only get IDE booting to work.

## Installation Process ##

### boot.efi ###

First, you need to get a copy of boot.efi.  In my case I copied it from my Apple TV using an earlier attempt at a different installation process, but it is probably best to follow the process described at http://code.google.com/p/atv-bootloader/wiki/BootEFIExtraction

On the Fedora host system, you can do this like this.  First, get and install the DMG converter:
```
wget http://atv-bootloader.googlecode.com/files/atv-dmg2img-1.0.tar.gz
tar -xzf atv-dmg2img-1.0.tar.gz
cd dmg2img
sudo ./install_dmg2img.sh
```

Now download the 179MB DMG that we need, and extract the tasty morsel at its center:
```
wget http://mesu.apple.com/data/OS/061-2988.20070620.bHy75/2Z694-5248-45.dmg
dmg2img 2Z694-5248-45.dmg
mkdir atv-update
sudo mount -o loop -t hfsplus 2Z694-5248-45.img atv-update
cp -ap atv-update/System/Library/CoreServices/boot.efi .
sudo umount atv-update
rm atv-dmg2img-1.0.tar.gz 2Z694-5248-45.img
```

We now have boot.efi in our current directory.

### Partitioning ###

Again, we follow the intent of the reference instructions but without the LiveCD things, and we install parted in parallel with the system one as the system one has dependencies on it:
```
wget http://atv-bootloader.googlecode.com/files/parted-1.8.8-atv.tar.gz
tar -xzf parted-1.8.8-atv.tar.gz
cd parted
sudo ./install_parted.sh
#(ignore any errors regarding apt-get, it won't hurt)
```

ldconfig will fail, fix it thus:
```
sudo sh -c "echo /usr/local/lib > /etc/ld.so.conf.d/local.conf"
sudo /sbin/ldconfig

cd ..
rm -rf parted parted-1.8.8.atv.tar.gz
```

At this point, you've got the original Fedora parted utility in
```
/sbin/parted
```

as well as the new and patched one in
```
/usr/local/sbin/parted
```

In the reference instructions we'd now install the HFS utilities from the atv\_bootloader site, but to keep things simple we'll instead use the Fedora equivalents which work fine for our purposes:
```
sudo yum install hfsplus-tools
```

From here on, we have a real potential to screw up your host computer.  Pay extra attention to disk names and paths.  The examples I show work on my system, but your system may well allocate devices differently in which case you need to modify these examples to suit your setup.

We now (finally!) start to use our target hardware.  First insert the target hard disk via USB to the host computer.  Check that the computer detects the hard disk, by:
```
dmesg | tail --lines 15
```

On my hardware, it shows the following:
```
usb-storage: device found at 4
usb-storage: waiting for device to settle before scanning
usb-storage: device scan complete
scsi 6:0:0:0: Direct-Access     SAMSUNG  HM160JC          AP10 PQ: 0 ANSI: 0
sd 6:0:0:0: [sdb] 312581808 512-byte hardware sectors (160042 MB)
sd 6:0:0:0: [sdb] Write Protect is off
sd 6:0:0:0: [sdb] Mode Sense: 03 00 00 00
sd 6:0:0:0: [sdb] Assuming drive cache: write through
sd 6:0:0:0: [sdb] 312581808 512-byte hardware sectors (160042 MB)
sd 6:0:0:0: [sdb] Write Protect is off
sd 6:0:0:0: [sdb] Mode Sense: 03 00 00 00
sd 6:0:0:0: [sdb] Assuming drive cache: write through
sdb: unknown partition table
sd 6:0:0:0: [sdb] Attached SCSI disk
sd 6:0:0:0: Attached scsi generic sg2 type 0
```

The key thing to note is that the kernel has decided that this device is /dev/sdb (make a note of this!), and that it correctly detects the hard disk type.  The device path may be different on your setup, so take care.  Zero the hard disk first (well, at least the first 8GB) and **be sure you get the device path right!**:
```
sudo dd if=/dev/zero of=/dev/sdb bs=4096 count=2M
```

This takes about 5 minutes on my hardware.

Set the partition type, using the new (patched) parted we installed earlier:
```
sudo /usr/local/sbin/parted -s /dev/sdb mklabel gpt
```

Now create the partitions themselves, and their attributes.  Note that this example assumes that the device path is (still) at /dev/sdb, and that the device is 160GB.  Change to suit your environment accordingly:
```
sudo /usr/local/sbin/parted -s /dev/sdb mkpart primary fat32 40s 25M
sudo /usr/local/sbin/parted -s /dev/sdb set 1 boot on
sudo /usr/local/sbin/parted -s /dev/sdb mkpart primary HFS 25M 50M
sudo /usr/local/sbin/parted -s /dev/sdb set 2 atvrecv on
sudo /usr/local/sbin/parted -s /dev/sdb mkpart primary HFS 50M 75M
sudo /usr/local/sbin/parted -s /dev/sdb mkpart primary ext3 75M 158.9GB
sudo /usr/local/sbin/parted -s /dev/sdb mkpart primary linux-swap 158.9GB 160.0GB
```

If you like, you can now check the partitioning:
```
sudo /usr/local/sbin/parted /dev/sdb print
```

Check that the partition sizes look sane, and that the first two partitions have the right flags.  On my system, the output looks like this:
```
Model: SAMSUNG HM160JC (scsi)
Disk /dev/sdb: 160GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Number  Start   End     Size    File system  Name     Flags
 1      20.5kB  25.0MB  25.0MB               primary  boot
 2      25.0MB  50.0MB  25.0MB               primary  atvrecv
 3      50.0MB  75.0MB  25.0MB               primary
 4      75.0MB  159GB   159GB                primary
 5      159GB   160GB   1142MB               primary
```

### Filesystems ###

Now we format each partition appropriately:
```
sudo /sbin/mkfs.msdos -F 32 -n EFI /dev/sdb1
sudo /sbin/mkfs.hfsplus -v Recovery /dev/sdb2
sudo /sbin/mkfs.hfsplus -v OSBoot /dev/sdb3
sudo /sbin/mkfs.ext3 -L gentoo /dev/sdb4
```

Remove the USB connection for the target HDD, and then reinsert it after a short pause.  You should then find that the system has automounted /dev/sdb2 (Recovery) at /media/Recovery, /dev/sdb3 (OSBoot) at /media/OSBoot, and /dev/sdb4 at /media/gentoo.

Now we download and install the bootloader files.
```
wget http://atv-bootloader.googlecode.com/files/recovery-0.6.tar.gz
sudo tar -xzf recovery-0.6.tar.gz
sudo cp -arp recovery/* /media/OSBoot/
sudo cp -arp recovery/* /media/Recovery/
sudo cp -ap boot.efi /media/OSBoot
sudo cp -ap boot.efi /media/Recovery
```

### Gentoo ###

So the disk is initialised, partitioned, file systems created, and the bootloader is installed.  Now we start the Gentoo installation onto the disk.  All subsequent steps assume that you're logged in as root, so do that:
```
su -
```

Download the Gentoo stage 3 tarball and current portage snapshot onto the "new" partition.  Take care to use a local mirror, which will probably be a different one to the one I've used here:
```
cd /media/gentoo
wget ftp://mirror.internode.on.net/pub/gentoo/releases/x86/current/stages/stage3-x86-2007.0.tar.bz2
wget ftp://mirror.internode.on.net/pub/gentoo/snapshots/portage-latest.tar.bz2
#(At the time of writing, 2007.0 was the latest available Gentoo)
```

Untar those to populate our initial Gentoo filesystem:
```
tar -xjf stage3-x86-2007.0.tar.bz2
tar -xjf portage-latest.tar.bz2 -C ./usr/
```

Set up DNS as well as mount points, and then enter our new environment:
```
cp -L /etc/resolv.conf /media/gentoo/etc/resolv.conf
mount -t proc none /media/gentoo/proc
mount -o bind /dev /media/gentoo/dev
chroot /media/gentoo /bin/bash
env-update
source /etc/profile
emerge --sync --quiet
```

Using nano, edit "/etc/make.conf" to look like this, but take note to suit the mirror settings to suit your own situation:
```
CFLAGS="-march=pentium-m -O2 -pipe -fomit-frame-pointer"
CXXFLAGS="${CFLAGS}"
CHOST="i686-pc-linux-gnu"
USE="bluetooth"
GENTOO_MIRRORS="ftp://mirror.internode.on.net/pub/gentoo"
SYNC="rsync://mirror.internode.on.net/gentoo-portage"
```

Edit "/etc/conf.d/clock" to have the correct settings for CLOCK and TIMEZONE.

And then set up a symlink for your timezone:
```
cd /etc
ln -s /usr/share/zoneinfo/YourCountry/YourCity localtime
```

### Kernel ###

With atv\_bootloader (as opposed to (eg) mach\_linux\_boot), we're free to use any recent kernel, which makes our life much easier.  So we first download the current stable kernel.  (Note that you could instead use 'gentoo-sources' if you'd prefer, but you'd need to change the kernel naming in this document to suit):
```
emerge vanilla-sources
cd /usr/src/linux
make mrproper
```

At this point, we need a configuration file for the kernel.  [Copy this one](InstallGentooConfigVer1.md) and save it as .config in /usr/src/linux before continuing.  Once that's done:
```
make menuconfig
make && make modules_install
```

Install the kernel:
```
rm /boot/boot
cp arch/i386/boot/bzImage /boot/kernel-2.6.24.4v01
cp System.map /boot/System.map-2.6.24.4v01
cp .config /boot/config-2.6.24.4v01
cd /boot
ln -s config-2.6.24.4v01 config
ln -s kernel-2.6.24.4v01 kernel
ln -s System.map-2.6.24.4v01 System.map
cd
```

### Update the system ###

At this point, it is recommended that you refer to http://www.gentoo.org/doc/en/change-chost.xml to fix anything that might be confused by the change in CHOST.  In short, this is what I did (note that this take a long time):
```
emerge -v1 binutils gcc glibc
etc-update
env-update && source /etc/profile
```

Then, update the rest of the system, note that we're now building things with the toolchain optimised for our architecture:
```
emerge -v -D --update system
etc-update
emerge -v -D --update world
etc-update
```

### Tweaking ###

Configure some other aspects of the system:
```
passwd
emerge syslog-ng vixie-cron slocate dhcp
rc-update add syslog-ng default
rc-update add vixie-cron default
mkswap /dev/sdb5
swapon /dev/sdb5
```

At this point, you need to decide if you're aiming for a USB HDD system or an IDE HDD system.  I couldn't get USB boot to work, but it should work in theory.  If you're using IDE, the disk will be at /dev/hda and if you're using USB it will be at /dev/sdb.  My examples from here on assume that you're setting up a system for IDE booting.

NOTE: My current kernel configuration causes the IDE HDD to be detected by "my" kernel at /dev/hdb even though the bootstrap kernel finds it at /dev/hda.  Hence the difference between grub.conf and fstab (below).  Yuk.  I hope to resolve this issue soon.
Using nano, edit ```
/etc/fstab``` so that the 'guts' looks like this:
```
/dev/hdb4               /               ext3            noatime         0 1
/dev/hdb5               swap            swap            defaults        0 0
proc                    /proc           proc            defaults        0 0
shm                     /dev/shm        tmpfs           nodev,nosuid,noexec     0 0
```

If you plan to use sound, edit "/etc/modules.autoload.d/kernel-2.6" and add these three lines:
```
snd-hda-intel
snd-mixer-oss
snd-pcm-oss
```

Make sure that networking is enabled on bootup:
```
rc-update add net.eth0 default
```

Install the bootloader (Grub):
```
emerge -v grub
```

Edit "/boot/grub/grub.conf" to look like this:
```
timeout 10
default 0
title Linux 2.6.24.4-v01
root (hd0,3)
kernel /boot/kernel-2.6.24.4v01 video=vesafb root=/dev/hdb4
```

Exit the chroot environment:
```
exit
cd
umount /media/OSBoot
umount /media/Recovery
umount /media/gentoo/proc
umount -l /media/gentoo/dev
umount /media/gentoo
```

### MBR ###

Now we update the boot disk MBR:
```
wget http://atv-bootloader.googlecode.com/files/mbr_fast-1.0.bin
dd if=mbr_fast-1.0.bin of=/dev/sdb bs=512 count=1
```

## Booting ##

Remove the USB connection from the HDD, and then insert the HDD into the IDE bus of the target Apple TV.  Turn on the Apple TV, and it should boot successfully into Gentoo Linux.  (First you'll see the ATV Bootloader graphic, and then the bootloader should load, and then it will load "our" kernel.)

Once the system has booted, you should be able to login to it as normal.

If you like, you can log in as root and do these cleanups:
```
rm /*.bz2
emerge -v -D --newuse world
emerge gentoolkit
emerge -v --depclean
```

## WiFi ##

The WiFi interface doesn't have a proper driver, so we have to use NDISwrapper with all the downsides that entails.
```
emerge -v -D ndiswrapper
```

We need the Windows driver for this hardware, as described by our reference page. So download the driver at http://ftp.us.dell.com/network/R140746.EXE, and then unzip it somewhere temporary on another machine. From the DRIVER subdirectory of that archive, we need bcmwl5.inf and bcmwl5.sys. As root on the AppleTV, copy these two files onto the machine:
```
cd /root
scp dev@192.168.0.188:Archive/AppleTV/wifi/DRIVER/bcmwl5.inf .
scp dev@192.168.0.188:Archive/AppleTV/wifi/DRIVER/bcmwl5.sys .
```

Then we get NDISwrapper to extract what it needs from these files:
```
ndiswrapper -i /root/bcmwl5.inf
```

This will have created a bunch of files in /etc/ndiswrapper/. We now need to update the data for modules for this system:
```
update-modules
```

You should now be able to delete the Windows files:
```
rm /root/bcmwl5.*
```

So now we have the drivers set up, but we still need the userspace tools for WiFi. As we hope to be using WPA2, we'll use WPA Supplicant:
```
emerge -v -D wpa_supplicant
```

Edit "/etc/wpa\_supplicant/wpa\_supplicant.conf" to look like this (assuming a WPA-PSK [TKIP](TKIP.md) or WPA2-PSK [AES](AES.md) wireless AP):
```
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=users
update_config=0
fast_reauth=1
ap_scan=1
network={
     ssid="TargetSSID"
     scan_ssid=1
     key_mgmt=WPA-PSK
     psk="Your Key Here"
}
```

And /etc/conf.d/net to look like this:
```
modules=("dhclient")
modules_wlan0=("wpa_supplicant")
wpa_supplicant_wlan0="-Dwext -iwlan0"
config_wlan0=("dhcp")
dhcpd_wlan0="-t 30 -N"
```

Set up networking scripts so that we can easily start/stop the wireless interface:
```
cd /etc/init.d
ln -s net.lo net.wlan0
```

Things should now work when you start the interface. Reboot to make sure all is correctly configured, you should then have a wlan0 interface with an address assigned by the AP (assuming the AP is configured for DHCP).

## Optimisations ##
This should help with power usage and performance. Add the following to "/etc/conf.d/local.start":
```
echo 2 > /sys/module/processor/parameters/max_cstate
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
```

This should help with WiFi power consumption when it's not being used. Add the following to "/etc/conf.d/net":
```
iwconfig_wlan0="power on"
```
