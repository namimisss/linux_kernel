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

.PYONY: all clean
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
boot:
	@echo "run boot"
	@$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS_KERNEL)" -C arch/$(ARCH)/boot


clean:
	@echo "run clean"
	@$(MAKE) -C arch/$(ARCH)/boot clean
