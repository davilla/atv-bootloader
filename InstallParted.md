# Build/Install Parted #

Parted is a disk partition application just like fdisk. However it's more advanced than fdisk in that it can create GPT format partitions in addition to normal partitions. All Apple Intel desktop hardware use GPT format for disk partitions and the AppleTV is no exception.

Creating the proper GPT disk format and partitions is critical for booting Linux on the AppleTV. The boot disk is GPT formatted and must have the proper GUID associated with specific partitions or the AppleTV will refuse to boot. GPT format uses unique GUIDs to indicate the partition format (msdos, ext3, hfsplus, efi, etc).

In order to create GPT format partitions, one must use parted.  The AppleTV uses a special GUID to indicate the "Recovery" partition even though the partition is the same has hfsplus. The normal parted does not understand this special GUID so one needs to patch parted to be able to create the "Recovery" partition.

**Warning**
If your file path name has spaces "/home/davilla/atv dev/work", then parted will not build properly. Make sure your file path does not have spaces in it.

**install build tools
```
sudo /usr/bin/apt-get install build-essential patch
```**

**build and install the patched parted.
```
# remove the existing parted 
sudo /usr/bin/apt-get remove parted

# fetch the patched parted
wget http://atv-bootloader.googlecode.com/files/parted-1.8.8-atv.tar.gz
tar -xzf parted-1.8.8-atv.tar.gz

# build and install the patched parted
cd parted
sudo ./install_parted.sh
sudo ln -s /usr/local/sbin/parted /sbin/parted

# verify the install
parted --version
# you should see "parted (GNU parted) 1.8.8"
```**

If you get a failed build on a warning about C99 inline functions not supported, then edit "install\_parted.sh" and change
```
./configure --enable-static=yes
```
to
```
./configure CFLAGS="-fgnu89-inline" --enable-static=yes
```

**If you run the "install\_parted.sh" script and get any errors building, stop and ask for help on the discussion group. Without successfully patching and building parted, you cannot create the proper GPT partitions and the AppleTV EFI firmware will not boot your USB disk.**

Done.