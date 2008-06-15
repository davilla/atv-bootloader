# Version 2.0 (May 18, 2008)
# 
# This script builds a patched parted to support apple recovery GUID
# disk partitions. Using the flag "atvrcv" will make selected partions
# into one with an Apple "Recovery" GUID of 
# "5265636F-7665-11AA-AA11-00306543ECAC"
#
# The atv-bootloader must be installed into an Apple "Recovery" 
# partition in order for boot.efi to find and load it. In addition,
# there are several "support" files required". This script only
# creates a patched parted so that Apple "Recovery" partitons
# can be created.
#
# See the following link for gpt and GUID info
# http://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs
#
#

PACKAGE = parted-1.8.8
DOWNLOAD = parted-1.8.8.tar.bz2

.PHONY: parted

parted: build/parted build/partprobe
	sudo apt-get install uuid-dev
	sudo apt-get install libreadline5-dev
	@if [ ! -e $(DOWNLOAD) ]; then \
		wget ftp.gnu.org/gnu/parted/$(DOWNLOAD); \
	fi
	@if [ ! -d $(PACKAGE) ]; then \
		tar -xjf $(DOWNLOAD); \
		cd $(PACKAGE); \
		patch -p1 < ../appletv_parted-1.8.8.patch; \
		./configure CFLAGS="-fgnu89-inline" --enable-static=yes; \
		cd .. ; \
	fi
	cd $(PACKAGE) && $(MAKE)
	cp $(PACKAGE)/parted/.libs/parted build/
	cp $(PACKAGE)/partprobe/.libs/partprobe build/
	cp parted-1.8.8/libparted/.libs/libparted-1.8.so.8 build/

clean:
	rm -rf build/*
	rm -rf $(PACKAGE)
	rm $(DOWNLOAD)

