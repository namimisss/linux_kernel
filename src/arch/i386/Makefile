LD=$(CROSS_COMPILE)ld -m elf_i386
AS=$(CROSS_COMPILE)as --32
OBJCOPY=$(CROSS_COMPILE)objcopy -O binary -R .note -R .comment -S
LDFLAGS=-e stext
LINKFLAGS =-T $(TOPDIR)/arch/i386/vmlinux.lds $(LDFLAGS)

CFLAGS += -pipe

CFLAGS += -march=i386

HEAD := arch/i386/kernel/head.o arch/i386/kernel/init_task.o

SUBDIRS += arch/i386/kernel arch/i386/mm arch/i386/lib

CORE_FILES := arch/i386/kernel/kernel.o arch/i386/mm/mm.o $(CORE_FILES)
LIBS := $(TOPDIR)/arch/i386/lib/lib.a $(LIBS) $(TOPDIR)/arch/i386/lib/lib.a

MAKEBOOT = $(MAKE) -C arch/$(ARCH)/boot
