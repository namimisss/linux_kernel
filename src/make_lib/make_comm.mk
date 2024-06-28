define make_img
	@echo "make img:$(1),$(2)"
	@dd if=$(TOPDIR)/arch/$(ARCH)/boot/bootsect of=$(TOPDIR)/test/$(1) conv=notrunc 2>/dev/null
	@dd if=$(TOPDIR)/arch/$(ARCH)/boot/setup of=$(TOPDIR)/test/$(1) seek=1 conv=notrunc 2>/dev/null
	@mv $(TOPDIR)/test/$(1) $(TOPDIR)/test/$(2)
endef
