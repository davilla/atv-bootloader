![http://atv-bootloader.googlecode.com/svn/branches/web_items/web-icon-r1.png](http://atv-bootloader.googlecode.com/svn/branches/web_items/web-icon-r1.png)

Frustrated creating an AppleTV based linux system. Nervous about voiding the warrantee by opening the AppleTV to get access to the internal hard drive. Tired of following voodoo instructions just to build bootable USB pen patchstick to install sshd? Well, atv-bootloader is for you.

# Notice #
> I've been seeing some downloads of previous versions of "recovery.tar.gz" lately. Make sure you are using the most recent version which is [recovery-0.6.tar.gz](http://atv-bootloader.googlecode.com/files/recovery-0.6.tar.gz)

# AppleTV #
  * [hardware](atvhardware.md)
  * software performance
    * [MPlayer](mplayer.md)
    * [MythTV](mythtv.md)
    * [XBMC](xbmc.md)
  * [video playback](atvdisplay.md)

# Details #
  * History
    * The AppleTV is a really neat device. The normal AppleTV is pretty good but lacks hardware assisted nvidia mepg2 decode capabilities. This means that one it limited to 720p mpeg2. To do 1080i mpeg2 decode one needs to look toward the Linux OS as there are existing drivers for nvidia hardware decode.

  * Other bootloaders
    * First Linux boot was done by Edgar (gimli) Hucek at http://www.mactel-linux.org/wiki/AppleTV. This bootloader was called "mach\_linux\_boot" and required the linux kernel to be compiled into the resulting mach\_kernel. This worked great but was a little limited in updating the Linux kernel was a pain.
    * The second bootloader was "mb\_boot\_tv" done by James McKenzie at http://www.mythic-beasts.com/resources/appletv/ . This bootloader extended mach\_linux\_boot by enabling the bootloader to search over the internal ata bus and find a boot config that would be used to load the Linux kernel. Network boot was also enabled. This was better, now the kernel could be updated without recompiling the mach\_kernel. However, one could netboot using a USB disk but not boot a USB based Linux system. In addition, because mb\_boot\_tv used it's own boot config format, changes made to grubs menu.lst file during updates required manually updating mb\_boot\_tv.conf.

  * ATV-Bootloader
    * atv-bootloader which uses principals from mach\_linux\_boot to boot a compiled-in Linux kernel and then finds and boots another Linux kernel using [kexec](http://www.ibm.com/developerworks/linux/library/l-kexec.html) (a user-land kernel bootloader). In addition, atv-bootloader translates several EFI structures into standard PC bios structures. This allows a standard Linux kernel to be booted without the numerous EFI patches required by both mach\_linux\_boot and mb\_boot\_tv.
    * atv-bootloader can a) search and find an existing grub menu.lst and auto-boot from it, b) search for a "boot\_linux.sh" file and auto-execute it, and c) search for "patchstick.sh" and auto-execute it. The initrd "boot\_linux.sh" script currently search sdb then rest of the disk devices (this will be changed in the future once the real boot device can be recovered from the device tree passed by boot.efi).  This procedure allows atv-bootloader to auto-boot a linux install or be extended for other uses. This is controlled by a "Kernel Flag" string param in com.apple.Boot.plist and has the following definitions
```
#search for mb_boot_tv, grub and syslinux/ioslinux config --auto boot default
"atv-boot=auto"

#search for a "boot_linux.sh" file and execute it.
"atv_boot=manual"

#search for a "patchstick.sh" file and execute it.
"atv_boot=patchstick"

#default is to drop to a login prompt (user=root, password=root)

```
> > atv-bootloader is located [here](http://atv-bootloader.googlecode.com/files/recovery-0.6.tar.gz) and the source is in [svn](http://code.google.com/p/atv-bootloader/source/browse). **Warning SVN trunk is the development branch** You will not find any files named atv-bootloader as atv-bootloader is the concepts contained within the downloaded package. This package contains a prebuilt "fake" mach kernel with embedded Linux kernel/initramfs along with the required support files. The only thing required is boot.efi which cannot be distributed.

  * [Understanding AppleTV partitions](ATVBootInfo.md)

  * [Understanding kexec](Understandingkexec.md)

  * Software tools
    * The AppleTV needs a specific version of "boot.efi" in order to boot properly. This version can be extracted from the downloadable AppleTV update and [this version of dmg2img](http://atv-bootloader.googlecode.com/files/atv-dmg2img-1.0.tar.gz) is used to convert from "dmg" to "img" formats. See [the guide on extracting "boot.efi" for information](BootEFIExtraction.md).
    * The AppleTV requires GPT formatted partitions. "parted" can do this but is missing a required GUID format. So you need a patched parted. See the [installing parted guide for information](InstallParted.md).
    * The AppleTV uses two HFS formatted partitions, while the standard Linux distro can mount HFS disk, the ability to format HSF is missing. See the [installing HFS tools guide for information](InstallHFSTools.md).

  * [Create a bootable USB flash disk](LinuxUSBPenBoot.md)

> The basic atv-bootloader using a USB flash disk.

  * [Backup and Restore](ATVBackup.md)
> If you are installing to the original AppleTV internal drive, you should backup the original hard drive. This section contains a guide for the backup and restore of the internal PATA disk.

  * [Installing Linux](InstallingLinux.md)
> Install Linux to the internal hard disk or to a external USB hard drive and leave the original AppleTV hardware drive unaltered. Either method is acceptable and will result in a working Linux install.

  * [Booting a Linux LiveCD](BootingLiveCD.md)
> You CAN boot a LiveCD on the AppleTV using a USB cdrom. This guide contains information on how to boot the Ubuntu 7.10 Gutsy LiveCD and information for booting other Linux LiveCDs or CD installers.

  * [Build a basic patchstick](BuildingPatchstick.md)
> Build a basic patchstick that can install and enable ssh access into the AppleTV OS.

  * Extending patchstick

  * WinXP and friends
    * Trying to do anything involving the AppleTV under Windows is not recommended. Windows does lots of hidden things like touching partitions that is has no business touching. Boot a Linux LiveCD instead and do everything from that environment.

# [Support](Support.md) #
Unfortunately, I do not have the time to teach how to use Linux or MythTV but if you have a question or problem with atv-bootloader, getting a Linux distribution installed or tweaks to get the best performance, post it to http://groups.google.com/group/atv-bootloader .

It helps to indicate the distro and kernel version if you are having run-time problems. Also if you are having problems building a bootable atv-bootloader, include the full output of "sudo parted -s /dev/sdX unit s print" where sdX is the disk device. And completely describe your problem and setup, for example "I'm having problems booting from a USB disk" is just not enough information, Thanks.

# [Feedback](Comments.md) #
You can use this page to post feedback on your experences building and using atv-bootloader.

# How can You Contribute #
If you want to help, the most pressing item is a deb/rpm that contains dmg2img, patched parted, hfs tools, gptsync. This would eliminate the patch/build steps. Another deb/rpm with pre-compiled usbhid.ko and snd-hda-intel.ko  kernel modules for the various distros would be nice. I'm not experienced in proper deb/rpm creation so if someone could give me a good example, I can take it from there.

Another task for the more experienced person would be to figure out how [osputil](http://wiki.awkwardtv.org/wiki/Osputil) works and the USB protocol that it uses to talk to the IR USB controller. Once this is known, then I can create a similar Linux command-line app that does the same thing. Then we can control the internal fan and most important, control the white/amber LED on the front of the AppleTV and STOP it from blinking amber all the time.

# [Development Blog](atv_blog.md) #
This is where you can see what I'm working on, sometimes in real-time as I use it for keeping notes as I develop.

[m](ATVBootloader_Main.md)
[m](ATVBootloader_Main2.md)