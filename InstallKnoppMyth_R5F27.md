![http://atv-bootloader.googlecode.com/svn/branches/web_items/logos/knoppmyth.png](http://atv-bootloader.googlecode.com/svn/branches/web_items/logos/knoppmyth.png)

# Installing [KnoppMyth](http://mysettopbox.tv/) #

There are two ways to install KnoppMyth. The easiest is to use normal formatting and over-write the internal disk. The other method of installing to GPT formatted disks is still being developed and will be updated at a later time.


---

# KnoppMyth R5F27 #
**Over-write the internal disk**

> This method is pretty simple, make a USB flash drive with atv-bootloader, boot the AppleTV, backup the AppleTV, then boot the KnoppMyth CD installer, and install KnoppMyth to the internal PATA disk. Then create a custom "boot\_linux.sh" that atv-bootloader uses to boot the installed KnoppMyth.

> Audio and IR support requires a kernel patch/rebuild as 2.6.18 is too old to accept usbhid kernel module options. In addition, the nvidia driver will need to be updated to a 169.xx version.

> ## NVIDIA ##
```
su root

# stop X11
mv /usr/bin/startx /usr/bin/startx.save
cp /etc/X11/xorg.conf /etc/X11/xorg.original
pkill xinit

cd /usr/src/linux-headers-2.6.18-chw-13/include/linux/ 
mv i2c-id.h i2c-id-org.h
wget http://lm-sensors.org/svn/i2c/trunk/kernel/i2c-id.h 

install-nvidia-debian.sh 169.12 -force

mv /usr/bin/startx.save /usr/bin/startx

Disable the current driver's startup activities: 
update-rc.d -f install-nvidia-debian remove 
update-rc.d -f nvidia-glx remove 
```

> ## Audio/IR ##
```
wget ftp://knoppmyth.net/R5/linux-source-2.6.18-chw-13_2.6.18-chw-13-10.00.Custom_all.deb 
dpkg -i linux-source-2.6.18-chw-13_2.6.18-chw-13-10.00.Custom_all.deb 
cd /usr/src 
tar xjvf linux-source-2.6.18-chw-13.tar.bz2
cp /boot/config-2.6.18-chw-13 linux-source-2.6.18-chw-13/.config 

# get audio and IR patches
sudo wget http://atv-bootloader.googlecode.com/files/atv-realtek-rca-audio-r1-2.6.18.patch
sudo wget http://atv-bootloader.googlecode.com/files/atv-hid-quirks-enable-ir-r1-2.6.18.patch

cd /usr/src/linux-source-2.6.18-chw-13

# test the audio patch (this should complete without errors)
sudo patch --dry-run < ../atv-realtek-rca-audio-r1-2.6.18.patch
# apply the audio patch
sudo patch  < ../atv-realtek-rca-audio-r1-2.6.18.patch

# test the IR patch (this should complete without errors)
sudo patch --dry-run < ../atv-hid-quirks-enable-ir-r1-2.6.18.patch
# apply the IR patch
sudo patch  < ../atv-hid-quirks-enable-ir-r1-2.6.18.patch


# build the kernel package
make-kpkg kernel_image 


# change the main source symlink to point at the sources 
rm /usr/src/linux 
ln -s /usr/src/linux-source-2.6.18-chw-13 /usr/src/linux
ln -s /usr/src/linux-source-2.6.18-chw-13 /usr/src/kernel-source-2.6.18-chw-13
#
# change the modules symlink to point at the sources 
rm /lib/modules/2.6.18-chw-13/build 
ln -s /usr/src/linux-source-2.6.18-chw-13 /lib/modules/2.6.18-chw-13/build 

cd ..
dpkg -i --force-overwrite linux-image-2.6.18-chw-13_2.6.18-chw-13-10.00.Custom_i386.deb
```

> ## LIRC ##
```
apt-get remove lirc
cd /usr/src
wget http://superb-east.dl.sourceforge.net/sourceforge/lirc/lirc-0.8.2.tar.bz2
tar jxvf lirc-0.8.2.tar.bz2
wget http://atv-bootloader.googlecode.com/files/lirc-0.8.2-macmini-repeat.patch
cd lirc-0.8.2
patch --dry-run -p1 < ../lirc-0.8.2-macmini-repeat.patch
patch -p1 < ../lirc-0.8.2-macmini-repeat.patch
./setup.sh
select macmini IR
save and do not run configure
nano configure.sh
add --prefix=/usr \
./configure
make
make install

chown mythtv:mythtv /dev/lircd
```


---

# Remove MythBackEnd #
> Stop and remove mythtv-backend
```
/etc/init.d/mythtv-backend stop
update-rc.d -f mythtv-backend remove
```

> Stop and remove mysql server
```
/etc/init.d/mysql stop
update-rc.d -f mysql remove
apt-get remove mysql-server xmltv
rm -rf /var/lib/mysql/*
rmdir /var/lib/mysql
rm -rf /var/log/mysql/*
rmdir /var/log/mysql
```

> Stop and remove apache
```
/etc/init.d/apache2 stop
update-rc.d -f apache2 remove
```

> Now change the MythTV settings to point at your existing backend database. Edit the file
```
nano /etc/mythtv/mysql.txt
```

> Done

