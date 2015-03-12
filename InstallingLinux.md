# Installing Linux #

The installation of Linux on the AppleTV is pretty easy now but there are a few things to think about before you proceed.

First and formost, the AppleTV does not have a traditional PC BIOS and video bios (VBIOS) is not present in the typical PC RAM location. This means that console mode might or might not function depending on if the Linux distribution supports "vesafb" in their initramfs. ATV-Bootloader was written explicitly to support "vesafb" and in fact tried to force "vesafb" during Linux kernel boot.

Ubuntu/Mythbuntu does not have "vesafb" support but it can be added post install. KnoppMyth does have "vesafb" so no problem there. All is not lost if "vesafb" is not supported as once X11 takes over, "nv" and "nvidia" under X11 do know how to access VBIOS and life is good once X11 comes up. This issue typically effects installation from a LiveCD and once the Linux distribution is installed, one can fix this by adding "vesafb" as the console framebuffer post-install.

The second thing to think about it where you want the Linux install to live. Essentially you have three choices.
  1. Over-write the existing AppleTV internal disk.
  1. Use an external USB disk for Linux.
  1. Coexist on the internal disk and use a USB flash drive to bootstrap.

These choices are sometimes determined by your Linux distribution and how flexible it is with regard to disk partitions. Some distribution expect that the first disk partition is going to be it's root file system (KnoppMyth), others can have any partition order (Ubuntu/Mythbuntu). If the partition structure is rigid, then you cannot have both the AppleTV OS and Linux on the same disk. Other distributions cannot support USB install and boot.

The next issue is that atv-bootloader requires a GPT formatted disk to boot. This done using be the internal PATA or external USB disk. You can install a Linux distribution using normal partitioning and the bootstrap it with a GPT formatted USB flash drive containing atv-bootloader. It can search both normal and GPT formatted disks for a boot configuration and boot Linux. So that adds a little complexity. For example, it you want to over-write the internal PATA disk, you have two additional choices.
  1. Format GPT
  1. Format normal and use a USB flash drive to bootstrap.

So think about your setup and where you want to place your Linux distribution installation. Your Linux distribution needs to be a 32-bit Intel as the AppleTV uses a Pentium-M processor. If you have questions, ask on the [atv-bootloader discussion group](http://groups.google.com/group/atv-bootloader) and either myself or someone else can assist.

Once you have settled on a plan, do the following before starting any install process;
  1. [Extract "boot.efi" from the downloadable AppleTV update](BootEFIExtraction.md).
  1. [Build the atv-bootloader USB flash disk](LinuxUSBPenBoot.md).
  1. [Backup your AppleTV if you plan on over-writing the internal disk](ATVBackup.md).

Then choose your install method and prep the partitions. It can be helpful to review the Linux distribution install method below as some have restrictions that will require a specific disk partitioning.
  1. Over-write the existing AppleTV internal disk
    1. [Format GPT for self boot](PartitioningLinux.md)
    1. [Format normal and use a USB flash drive to bootstrap](BootStrapPATALinuxInstall.md)
  1. [Use an external USB disk for Linux](BootableUSBLinuxInstall.md)
  1. Coexist on the internal disk and use a USB flash drive to bootstrap
    1. [Use replacement internal disk](AlternatePartitioning1.md)
    1. [Use original internal disk and resize "Media" to make space for Linux](AlternatePartitioning2.md).

Armed with these, you can proceed to [booting a LiveCD](BootingLiveCD.md) and installing your Linux distribution. **Warning -- if you are using an LiveCD boot on an existing Windows/Linux system, it is recommended to disconnect or remove power from you existing disks to prevent any possibility of overwriting your existing disks**
  * [Ubuntu Gutsy](InstallUbuntuGutsy.md)
  * [Gentoo](InstallGentooVer1.md)
  * [Mythbuntu (Gutsy/Hardy)](InstallMythBuntu.md)
  * MythDora
  * [KnoppMyth](InstallKnoppMyth_R5F27.md)
  * miniMyth
  * [LiveXBMC](InstallLiveXBMC.md)



