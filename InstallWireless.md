![http://atv-bootloader.googlecode.com/svn/branches/web_items/internals/BCM94321MC.jpg](http://atv-bootloader.googlecode.com/svn/branches/web_items/internals/BCM94321MC.jpg)

# Enable 802.11 Wireless Networking #

The AppleTV has built-in Wi-Fi 802.11b, 802.11g, or 802.11n wireless network capability provided by the Broadcom Dual-Band 802.11n BCM94321MC (BCM4328) chipset. This is a PCI-E 1X card in a PCI Express Mini Card form-factor. The Broadcom BCM94321MC is support under Linux by ndiswrapper which provides a Linux kernel module that "wraps" a Windows driver. The reason for this is that Broadcom does not provide Linux drivers and there are not open source replacements (yet). The Windows driver cannot be bundled with ndiswrapper as it is the property of Broadcom.

So to enable 802.11 wireless under Linux, you need to a) install ndiswrapper, b) download and extract a Windows based Broadcom driver and c) load and configure the wireless.

Download and install ndiswrapper.
```
wget http://internap.dl.sourceforge.net/sourceforge/ndiswrapper/ndiswrapper-1.52.tar.gz
tar -zxvf ndiswrapper-1.52.tar.gz 
cd ndiswrapper-1.52
make distclean
make
sudo make install
```

Download and extract a Windows based Broadcom driver.
```
mkdir R140746
wget http://ftp.us.dell.com/network/R140746.EXE
unzip -d R140746 R140746.EXE
#
# this will extract the required bits from the Windows driver
sudo ndiswrapper -i R140746/DRIVER/bcmwl5.inf
```


Load the ndiswrapper kernel module and check dmesg.
```
sudo modprobe -v ndiswrapper
dmesg
```

You should see something like this.
```
ndiswrapper version 1.52 loaded (smp=yes, preempt=yes)
ndiswrapper: driver bcmwl5 (Broadcom,10/12/2006, 4.100.15.5) loaded
PCI: Enabling device 0000:02:00.0 (0000 -> 0002)
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:02:00.0 to 64
ndiswrapper: using IRQ 16
wlan0: ethernet device 00:19:e3:dc:14:88 using NDIS driver: bcmwl5, version: 0x4640f05, NDIS version: 0x501, vendor: 'NDIS Network Adapter', 14E4:4328.5.conf
wlan0: encryption modes supported: WEP; TKIP with WPA, WPA2, WPA2PSK; AES/CCMP with WPA, WPA2, WPA2PSK
usbcore: registered new interface driver ndiswrapper
```


Use "sudo iwconfig" to see that wlan0 exists, you should see something like this
```
lo        no wireless extensions.

eth0      no wireless extensions.

Warning: Driver for device wlan0 has been compiled with version 22
of Wireless Extension, while this program supports up to version 20.
Some things may be broken...

wlan0     IEEE 802.11g  ESSID:off/any  
          Mode:Managed  Frequency:2.462 GHz  Access Point: Not-Associated   
          Bit Rate=130 Mb/s   Tx-Power:32 dBm   
          RTS thr=2347 B   Fragment thr=2346 B   
          Encryption key:off
          Power Management:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0
```

Now, connect to an existing unsecured wireless network ("HomeBase" in my case) with
```
sudo iwconfig wlan0 essid HomeBase
```

Now doing "sudo iwconfig" should give you something like this. Note that "ESSID:", "Access Point:" and various other values are now filled in.
```
lo        no wireless extensions.

eth0      no wireless extensions.

Warning: Driver for device wlan0 has been compiled with version 22
of Wireless Extension, while this program supports up to version 20.
Some things may be broken...

wlan0     IEEE 802.11g  ESSID:"HomeBase"  
          Mode:Managed  Frequency:2.422 GHz  Access Point: 00:19:E3:E2:A6:E5   
          Bit Rate=54 Mb/s   Tx-Power:32 dBm   
          RTS thr=2347 B   Fragment thr=2346 B   
          Encryption key:off
          Power Management:off
          Link Quality:60/100  Signal level:-57 dBm  Noise level:-96 dBm
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0
```


Now that the ndiswrapper kernel module is working and the wlan0 device is created, you can fetch a DHCP address and then the normal "ifconfig" will show the IP assigned to the wireless network.
```
sudo dhclient wlan0
```

To test, use "ping" but tell ping to use the wireless IP as the source of the ping otherwise it will use the wired network as default if that's enabled. "192.168.2.53" is the IP of my AppleTV wireless network side, "192.168.2.200" is my MythTV backend. Change these to reflect your network settings.

```
ping -I 192.168.2.53 192.168.2.200
```

To finish up, the "-m" option on ndiswrapper creates "/etc/modprobe.d/ndiswrapper" and edit "/etc/modules" and add "ndiswrapper" so that it loads at boot time. Setup "/etc/network/interfaces" and you are done.
```
sudo ndiswrapper -m
# add ndiswrapper to "/etc/modules"
```


Example of a DHCP setup for "/etc/network/interfaces"
```
# wireless network interface (DHCP)auto wlan0iface wlan0 inet dhcp
```

Example of a static IP setup for "/etc/network/interfaces" using WEP
```
# wireless network interface (static)auto wlan0iface wlan0 inet staticwireless-essid MY_ESSIDwireless-key MY_WIRELESS_KEYaddress 192.168.1.22netmask 255.255.255.0gateway 192.168.1.1
```

