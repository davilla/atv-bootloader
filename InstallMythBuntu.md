![http://atv-bootloader.googlecode.com/svn/branches/web_items/logos/mythbuntu.png](http://atv-bootloader.googlecode.com/svn/branches/web_items/logos/mythbuntu.png)

# Install [MythBuntu](http://www.mythbuntu.org/) Gutsy/Hardy #

These instructions are for the installation of [Mythbuntu](http://www.mythbuntu.org/) from the LiveCD. This consist of a) install Mythbuntu, b) post install fixes and last c) post boot fixes.

A **warning** here, if you install [Mythbuntu](http://www.mythbuntu.org/) and select mythfrontend only, it will expect an existing [MythTV](http://www.mythtv.org/) backend and request connect info, if this info is not correct, the install will barf and not complete correctly.


---

**Install Mythbuntu**

**This guide assumes a Mythbuntu only install with /dev/sda4 is "/" and /dev/sda5 is "swap". A coexist install to the internal PATA disk will use "dev/sda5" as "/" and "/dev/sda6" as swap. If your disk partitioning is different you will need to adjust this guide to match.**

Click on install "Mythbuntu"

Prepare disk space
```
select "Manual"
```

Prepare Partitions
```
select /dev/sda4 and "edit"
change "use as" to ext3
change mount point to "/" (without quotes)
check the format check box.

select /dev/sda5 and "edit"
change "use as" to swap

if you see any other marked partitions
select them and "edit"
change "use as" to dontuse

Install grub as we need the grub structure (menu.lst) to boot. We will run gptsync to fix up the MBR to one that efi firmware likes
so that the boot to the tux/atv logo drops from 30-60 seconds to 11.
This is done later when the install is running native on the AppleTV.
```

Now follow the normal mythbuntu install but do not reboot yet and remember to
```
select mac mini IR driver
select nvidia-new driver
select and configure the display settings for your monitor
```


---

**Post Install Fixes**

Ubuntu has a strange console framebuffer setup so we need to fix it for the AppleTV. Also add "8139too" to prevent "8139cp" from attempting to load.

If you are installing to a USB disk, unmount any USB disk partitions and then unplug/replug the USB drive to get the partitions re-mounted. The rest assumes the disk is mounted at /media/disk.
```
sudo mount --bind /dev /media/disk/dev
sudo chroot /media/disk
df to make sure you are in the correct root filesystem
"/" should be mounted on /dev/sda4

nano /etc/modprobe.d/blacklist-framebuffer and comment out "blacklist vesafb"
	#blacklist vesafb

nano /etc/initramfs-tools/modules and add 
	fbcon
	vesafb
	8139too

update-initramfs -u

exit
sudo umount /media/disk/dev
```

If this is an over-write install with atv-bootloader installed on the internal PATA disk, just reboot. If this is a coexist install, remember to keep the USB flash drive with atv-bootloader attached in order for atv-bootloader to bootstrap Mythbuntu.

After reboot or AppleTV power-on, you should see the tux/atv logo in 30-60 seconds. Then you will see atv-bootloader booting (tux in the upper left corner). After that your Mythbuntu install should boot. If you are using a USB flash drive (coexist install) you might have to use the IR remote and hold the "menu" and "-" buttons down during power on to force a USB recovery boot.


---

**Post Boot Fixes**

There are a few things to complete the install once you have Mythbuntu running. First open the Update Manager and take all the updates then reboot. If you are trying to match an existing MythTV backend, you might want to check the versions of MythTV and match them (outside the scope of this document).

Several additional items need to be updated/patched for supporting AppleTV hardware. The following are on separate pages as the procedures are similar for other debian based distributions.
  * Mythbuntu Gutsy
    1. [Update the boot disk MBR with gptsync](UpdateMBR.md)
    1. [Update IR driver](UpdateIRDriver.md)
    1. [Update audio driver](UpdateAudioDriver.md)
    1. [Update nvidia driver](UpdateNvidiaDriver.md)
    1. [Install wireless driver](InstallWireless.md)

  * Mythbuntu Hardy
    1. [Update the boot disk MBR with gptsync](UpdateMBR.md)
    1. [nvidia, audio and IR fixes](PostMythbuntuHardy.md)
    1. [Install wireless driver](InstallWireless.md)


Ok, that was not too hard, reboot to pickup the changes.
```
# pickup all the changes
sudo reboot
```


---

**Updating Mythbuntu**

A few things to watch out for. If you take an update that changes the kernel or kernel modules, then you will have to redo the nvidia binary driver install and patch/rebuild the audio driver and IR driver. Because of this, you should disable kernel updates.


