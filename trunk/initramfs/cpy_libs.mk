.PHONY: all


all:
	for FILE in $$( find rootfs/bin rootfs/sbin rootfs/usr/bin rootfs/usr/sbin \
	    -type f -perm -100 ) ; do \
	    LIBS=$$( ldd $$FILE | awk '/=>.*\.so/ { print $$3 }' ) ; \
	    for LIB in $$LIBS ; do \
		LIB_PATH=$$( echo $$LIB | sed -e 's/[^/]*$$//' ) ; \
	    mkdir -p rootfs/$$LIB_PATH ; \
	    cp -aH $$LIB rootfs/$$LIB_PATH ; \
	    done ; \
	done
	LIB=$$( ldd rootfs/bin/busybox | tail -n1 | awk '{ print $$1 }' ) ; \
	LIB_PATH=$$( echo $$LIB | sed -e 's/[^/]*$$//' ) ; \
	mkdir -p rootfs/$$LIB_PATH ; \
	cp -aH $$LIB rootfs/$$LIB_PATH
	#mkdir -p rootfs/usr/share/terminfo
	#cp -aL /usr/share/terminfo/a rootfs/usr/share/terminfo
	#cp -aL /usr/share/terminfo/l rootfs/usr/share/terminfo
	#cp -aL /usr/share/terminfo/v rootfs/usr/share/terminfo
	#cp -aL /usr/share/terminfo/x rootfs/usr/share/terminfo
	touch rootfs/etc/ld.so.conf

