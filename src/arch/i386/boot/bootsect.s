# 0 "bootsect.S"
# 0 "<built-in>"
# 0 "<command-line>"


# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4



















# 45 "/usr/include/stdc-predef.h" 3 4

# 55 "/usr/include/stdc-predef.h" 3 4









# 2 "<command-line>" 2
# 1 "bootsect.S"

# 1 "/home/jerry/doc/note/linux_note/linux_kernel/src/include/linux/config.h" 1





# 2 "bootsect.S" 2

# 1 "/home/jerry/doc/note/linux_note/linux_kernel/src/include/asm/boot.h" 1














# 3 "bootsect.S" 2





SETUPSECS	= 4
BOOTSEG		= 0x07c0
INITSEG		= 0x9000
SETUPSEG	= 0x9020
SYSSEG		= 0x1000
SYSSIZE		= 0x7F00

ROOT_DEV	= 0
SWAP_DEV	= 0

.code16
.text
.global _start
_start:
    movw	$BOOTSEG, %ax
	movw	%ax, %ds
	movw	$INITSEG, %ax
	movw	%ax, %es
	movw	$256, %cx
	subw	%si, %si
	subw	%di, %di
	cld
	rep
	movsw
	ljmp	$INITSEG, $go

go:
	movw	$0x4000-12, %di
