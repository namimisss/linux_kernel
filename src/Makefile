VERSION = 2
PATCHLEVEL = 4
SUBLEVEL = 0
EXTRAVERSION =

KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

ARCH=i386
CONFIG_SHELL=/bin/bash
TOPDIR:= $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)
HPATH=$(TOPDIR)/include
FINDHPATH=$(HPATH)/asm $(HPATH)/linux $(HPATH)/scsi $(HPATH)/net
HOSTCC=gcc
HOSTCFLAGS=-Wall -Wstrict-prototypes -O2 -fomit-frame-pointer
CROSS_COMPILE=

# Include the make variables (CC, etc...)
#

AS		= $(CROSS_COMPILE)as
LD		= $(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE)gcc
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
MAKEFILES	= $(TOPDIR)/.config
GENKSYMS	= /sbin/genksyms
DEPMOD		= /sbin/depmod
MODFLAGS	= -DMODULE
CFLAGS_KERNEL	=
PERL		= perl

export	VERSION PATCHLEVEL SUBLEVEL EXTRAVERSION KERNELRELEASE ARCH \
	CONFIG_SHELL TOPDIR HPATH HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC \
	CPP AR NM STRIP OBJCOPY OBJDUMP MAKE MAKEFILES GENKSYMS MODFLAGS PERL

.PYONY: all image clean
all:	boot

CPPFLAGS := -D__KERNEL__ -I$(HPATH)

CFLAGS := $(CPPFLAGS) -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer -fno-strict-aliasing
AFLAGS := -D__ASSEMBLY__ $(CPPFLAGS)

export SVGA_MODE = -DSVGA_MODE=NORMAL_VGA

# files removed with 'make mrproper'
MRPROPER_FILES = \
	include/linux/autoconf.h include/linux/version.h

include arch/$(ARCH)/Makefile
export	CPPFLAGS CFLAGS AFLAGS
$(info "ld:$(LD)")
$(info "topdir:$(TOPDIR)")
# $(V)dd if=$(OBJDIR)/kern/kernel of=$(OBJDIR)/kern/kernel.img~ seek=1 conv=notrunc 2>/dev/null

$(TOPDIR)/include/linux/version.h: include/linux/version.h
$(TOPDIR)/include/linux/compile.h: include/linux/compile.h

newversion:
	@if [ ! -f .version ]; then \
		echo 1 > .version; \
	else \
		expr 0`cat .version` + 1 > .version; \
	fi

include/linux/compile.h: include/linux/version.h newversion
	@echo -n \#define UTS_VERSION \"\#`cat .version` > .ver
	@if [ -n "$(CONFIG_SMP)" ] ; then echo -n " SMP" >> .ver; fi
	@if [ -f .name ]; then  echo -n \-`cat .name` >> .ver; fi
	@echo ' '`date`'"' >> .ver
	@echo \#define LINUX_COMPILE_TIME \"`date +%T`\" >> .ver
	@echo \#define LINUX_COMPILE_BY \"`whoami`\" >> .ver
	@echo \#define LINUX_COMPILE_HOST \"`hostname`\" >> .ver
	@if [ -x /bin/dnsdomainname ]; then \
	   echo \#define LINUX_COMPILE_DOMAIN \"`dnsdomainname`\"; \
	 elif [ -x /bin/domainname ]; then \
	   echo \#define LINUX_COMPILE_DOMAIN \"`domainname`\"; \
	 else \
	   echo \#define LINUX_COMPILE_DOMAIN ; \
	 fi >> .ver
	@echo \#define LINUX_COMPILER \"`$(CC) $(CFLAGS) -v 2>&1 | tail -1`\" >> .ver
	@mv -f .ver $@

include/linux/version.h: ./Makefile
	@echo \#define UTS_RELEASE \"$(KERNELRELEASE)\" > .ver
	@echo \#define LINUX_VERSION_CODE `expr $(VERSION) \\* 65536 + $(PATCHLEVEL) \\* 256 + $(SUBLEVEL)` >> .ver
	@echo '#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))' >>.ver
	@mv -f .ver $@

boot: include/linux/version.h include/linux/compile.h
	@echo "run boot"
	@$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS_KERNEL)" -C arch/$(ARCH)/boot

include make_lib/make_comm.mk

image: boot
	@echo "run make image"
	@mkdir -p $(TOPDIR)/test
	@dd if=/dev/zero of=$(TOPDIR)/test/qemu_kernel.img.tmp count=10000 2>/dev/null
	$(call make_img,qemu_bochs_kernel.img.tmp,qemu_kernel.img)

qemu-nox-gdb: image
	@echo "run qemu-nox-gdb"
	qemu-system-i386 -nographic -drive file=$(TOPDIR)/test/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -D $(TOPDIR)/test/qemu.log -s -S

gdb: $(TOPDIR)/arch/$(ARCH)/boot/bootsect.elf
	@echo "run make gdb"
	@gdb $(TOPDIR)/arch/$(ARCH)/boot/bootsect.elf

bochs-image: boot
	@echo "make bochs image"
	@mkdir -p $(TOPDIR)/test
	@rm -rf $(TOPDIR)/test/bochs_kernel.img.tmp
	@bximage -q -func=create -hd=16M $(TOPDIR)/test/bochs_kernel.img.tmp
	$(call make_img,bochs_kernel.img.tmp,bochs_kernel.img)
	@cp $(TOPDIR)/tools_file/bochsrc $(TOPDIR)/test/

bochs-image-floppy: boot
	@echo "make bochs image floppy"
	@mkdir -p $(TOPDIR)/test
	@rm -rf $(TOPDIR)/test/bochs_kernel_floppy.img.tmp
	@bximage -q -func=create -fd=1.44M $(TOPDIR)/test/bochs_kernel_floppy.img.tmp
	$(call make_img,bochs_kernel_floppy.img.tmp,bochs_kernel_floppy.img)
	@cp $(TOPDIR)/tools_file/bochsrc $(TOPDIR)/test/

clean:
	@echo "run clean"
	@$(MAKE) -C arch/$(ARCH)/boot clean
	@rm -rf $(TOPDIR)/test
	@rm -rf $(TOPDIR)/.version
	@rm -rf $(TOPDIR)/include/linux/compile.h
	@rm -rf $(TOPDIR)/include/linux/compile.h
