.PHONY: inject_kernel
# handy tools to remember under darwin tools
# otool -l mach_kernel 
# size -m mach_kernel
#
#
ARCH	= i386

# uncomment for darwin-cross build on Linux
#P=/opt/darwin-cross/bin/i386-apple-darwin8-
#S=-4.0

# start.o must be 1st in the link order (ld below)
OBJ	= start.o vsprintf.o console.o utils.o elilo_code.o darwin_code.o linux_code.o boot_loader.o

KERN_OBJ= vmlinuz.obj initrd.obj

mach_kernel: $(KERN_OBJ) $(OBJ)
	${P}ld -arch $(ARCH) -o mach_kernel $(OBJ) $(KERN_OBJ) -image_base 0xB000000

%.o:	%.c
	${P}gcc${S} -c -arch $(ARCH) -nostdlib -o $@ -c $<

%.o:	%.s
	${P}gcc${S} -c -arch $(ARCH) -nostdlib -DASSEMBLER -o $@ -c $<

vmlinuz.obj: vmlinuz
	${P}ld -arch $(ARCH) -w -r -o vmlinuz.obj -sectcreate __VMLINUZ __vmlinuz vmlinuz

initrd.obj: initrd.gz
	${P}ld -arch $(ARCH) -w -r -o initrd.obj -sectcreate __INITRD __initrd initrd.gz

clean:
	rm -f *.o $(KERN_OBJ) mach_kernel

