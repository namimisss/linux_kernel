$(warning "boot makefile")

$(warning "topdir:$(TOPDIR)")
$(warning "as:$(AS)")
BOOT_INCL =	$(TOPDIR)/include/linux/config.h \
		$(TOPDIR)/include/asm/boot.h

zImage: bootsect
	@echo "zImage"

bootsect: bootsect.o
	@echo "$(LD) -Ttext 0x0 -s -oformat binary -o $@ $<"
	@$(LD) -Ttext 0x0 -o bootsect.elf $<
	@$(OBJCOPY) -O binary bootsect.elf $@

bootsect.o: bootsect.s
	@echo "$(AS) -o $@ $<"
	@$(AS) -o $@ $<

bootsect.s: bootsect.S Makefile $(BOOT_INCL)
	@echo "BOOT_INCL:$(BOOT_INCL)"
	@echo "CPPFLAGS:$(CPPFLAGS)"
	@$(CPP) $(CPPFLAGS) -traditional $(SVGA_MODE) $(RAMDISK) $< -o $@


BOOTSECT_TMP_FILE = bootsect bootsect.elf bootsect.o bootsect.s
clean:
	@echo "clean BOOTSECT_TMP_FILE:$(BOOTSECT_TMP_FILE)"
	@rm $(BOOTSECT_TMP_FILE)