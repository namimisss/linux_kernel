
BOOT_INCL =	$(TOPDIR)/include/linux/config.h \
		$(TOPDIR)/include/asm/boot.h

.PHONY: all clean
all: zImage

zImage: bootsect
	@echo "zImage"

bootsect: bootsect.o
	@$(LD) -Ttext 0x0 -o bootsect.elf $<
	@$(OBJCOPY) -O binary bootsect.elf $@

bootsect.o: bootsect.s
	@$(AS) -o $@ $<

bootsect.s: bootsect.S Makefile $(BOOT_INCL)
	@$(CPP) $(CPPFLAGS) -traditional $(SVGA_MODE) $(RAMDISK) $< -o $@


BOOTSECT_TMP_FILE = bootsect bootsect.elf bootsect.o bootsect.s
clean:
	@echo "clean BOOTSECT_TMP_FILE:$(BOOTSECT_TMP_FILE)"
	@rm -f $(BOOTSECT_TMP_FILE)