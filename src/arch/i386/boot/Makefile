
BOOT_INCL =	$(TOPDIR)/include/linux/config.h \
		$(TOPDIR)/include/asm/boot.h

.PHONY: all clean
all: zImage

zImage: bootsect setup
	@echo "zImage"

bootsect: bootsect.o
	@$(LD) -Ttext 0x0 -o bootsect.elf $<
	@$(OBJCOPY) -O binary bootsect.elf $@

bootsect.o: bootsect.s
	@$(AS) -o $@ $<

bootsect.s: bootsect.S Makefile $(BOOT_INCL)
	@$(CPP) $(CPPFLAGS) -traditional $(SVGA_MODE) $(RAMDISK) $< -o $@

setup: setup.o
	$(LD) -Ttext 0x0 -e begtext -o setup.elf $<
	@$(OBJCOPY) -O binary setup.elf $@

setup.o: setup.s
	$(AS) -o $@ $<

setup.s: setup.S video.S Makefile $(BOOT_INCL) $(TOPDIR)/include/linux/version.h $(TOPDIR)/include/linux/compile.h
	$(CPP) $(CPPFLAGS) -traditional $(SVGA_MODE) $(RAMDISK) $< -o $@

BOOTSECT_TMP_FILE = bootsect bootsect.elf bootsect.o bootsect.s setup setup.elf setup.o setup.s
clean:
	@echo "clean BOOTSECT_TMP_FILE:$(BOOTSECT_TMP_FILE)"
	@rm -f $(BOOTSECT_TMP_FILE)