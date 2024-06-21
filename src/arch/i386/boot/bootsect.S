#include <linux/config.h>
#include <asm/boot.h>
/*	DEF_SYSSIZE 	= 0x3000
#	DEF_INITSEG 	= 0x9000
#	DEF_SETUPSEG 	= 0x9020
#	DEF_SYSSEG		= 0x1000
*/
SETUPSECS	= 4
BOOTSEG		= 0x07c0
INITSEG		= DEF_INITSEG
SETUPSEG	= DEF_SETUPSEG
SYSSEG		= DEF_SYSSEG
SYSSIZE		= DEF_SYSSIZE

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
