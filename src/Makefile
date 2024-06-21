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
boot:
	@echo "run boot"
	@$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS_KERNEL)" -C arch/$(ARCH)/boot
image: boot
	@echo "run make image"
	@mkdir -p $(TOPDIR)/test
	@dd if=/dev/zero of=$(TOPDIR)/test/kernel.img.tmp count=10000 2>/dev/null
	@dd if=$(TOPDIR)/arch/$(ARCH)/boot/bootsect of=$(TOPDIR)/test/kernel.img.tmp conv=notrunc 2>/dev/null
	@mv $(TOPDIR)/test/kernel.img.tmp $(TOPDIR)/test/kernel.img

qemu-nox-gdb: image
	@echo "run qemu-nox-gdb"
	qemu-system-i386 -nographic -drive file=$(TOPDIR)/test/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -D $(TOPDIR)/test/qemu.log -s -S

gdb: $(TOPDIR)/arch/$(ARCH)/boot/bootsect.elf
	@echo "run make gdb"
	@gdb $(TOPDIR)/arch/$(ARCH)/boot/bootsect.elf

clean:
	@echo "run clean"
	@$(MAKE) -C arch/$(ARCH)/boot clean
	@rm -rf $(TOPDIR)/test
