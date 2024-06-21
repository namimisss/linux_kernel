[toc]

# 启动
## 执行第一条指令
计算机刚通电时，内存(RAM)是没有内容的,所以第一条指令是在ROM上。硬件会把EPROM映射到两个地方，0xFFFFFFF0(4G向下的16Byte)和0xFFFF0(1MB向下的16Byte)处。那CPU到底是执行哪个地址呢?
CPU刚运行时是处于实模式，实模式只能使用16位寄存器，地址的计算方式为:
```bash
CS<<4 + IP
```
CPU刚运行时,CS寄存器中值为:0xF000,IP:0xFFF0,针对不同时代的CPU，对地址有不同的翻译方式:
### 8086,80286等早期时代的CPU
这类CPU翻译的地址就是按照段寄存器左移4位加上IP，即0xFFFF0
### 32位CPU
这类CPU有32位的寄存器，在CPU初始化时，会按照保护模式来初始化寄存器，及段寄存器会有:段选择子,段基址,段限长等内容,地址的计算方式为:
```bash
Base+IP
```
CS:IP的值依然是 0xF000:0xFFF0,但是CS的Base为:0xFFFF0000,所以计算出的地址为:
```bash
0xFFFF0000+0xFFF0=0xFFFFFFF0
```
因为第一条指令到最大地址之间只有16Byte的空间，所以第一条指令一般都会是一条跳转指令

### 参考
[cpu第一条指令理解](https://blog.csdn.net/port23/article/details/86710806?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-86710806-blog-79514441.235%5Ev43%5Epc_blog_bottom_relevance_base5&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-86710806-blog-79514441.235%5Ev43%5Epc_blog_bottom_relevance_base5&utm_relevant_index=2)
[CPU执行的第一条指令地址](https://blog.csdn.net/enlaihe/article/details/97125522?spm=1001.2101.3001.6650.5&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-5-97125522-blog-86710806.235%5Ev43%5Epc_blog_bottom_relevance_base5&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-5-97125522-blog-86710806.235%5Ev43%5Epc_blog_bottom_relevance_base5&utm_relevant_index=8)

# BIOS
现在BIOS已经开始工作了。在初始化和检查硬件之后，需要寻找到一个可引导设备。可引导设备列表存储在在 BIOS 配置中, BIOS 将根据其中配置的顺序，尝试从不同的设备上寻找引导程序。对于硬盘，BIOS 将尝试寻找引导扇区。如果在硬盘上存在一个MBR分区，那么引导扇区储存在第一个扇区(512字节)的头446字节，引导扇区的最后必须是 0x55 和 0xaa ，这2个字节称为魔术字节（Magic Bytes)，如果 BIOS 看到这2个字节，就知道这个设备是一个可引导设备

**实模式下的 1MB 地址空间分配表：**
```
0x00000000 - 0x000003FF - Real Mode Interrupt Vector Table
0x00000400 - 0x000004FF - BIOS Data Area
0x00000500 - 0x00007BFF - Unused
0x00007C00 - 0x00007DFF - Our Bootloader
0x00007E00 - 0x0009FFFF - Unused
0x000A0000 - 0x000BFFFF - Video RAM (VRAM) Memory
0x000B0000 - 0x000B7777 - Monochrome Video Memory
0x000B8000 - 0x000BFFFF - Color Video Memory
0x000C0000 - 0x000C7FFF - Video ROM BIOS
0x000C8000 - 0x000EFFFF - BIOS Shadow Area
0x000F0000 - 0x000FFFFF - System BIOS
```
在上面的章节中，我说了 CPU 执行的第一条指令是在地址 0xFFFFFFF0 处，这个地址远远大于 0xFFFFF ( 1MB )。那么实模式下的 CPU 是如何访问到这个地址的呢？0xFFFFFFF0 这个地址被映射到了 ROM，因此 CPU 执行的第一条指令来自于 ROM，而不是 RAM

**TODO**
grub2引导流程
现在linux内核一般通过grub2/uboot来当作bootloader,当内核被引导入内存后，内存使用情况如下:
```
         | Protected-mode kernel  |
100000   +------------------------+
         | I/O memory hole        |
0A0000   +------------------------+
         | Reserved for BIOS      | Leave as much as possible unused
         ~                        ~
         | Command line           | (Can also be below the X+10000 mark)
X+10000  +------------------------+
         | Stack/heap             | For use by the kernel real-mode code.
X+08000  +------------------------+
         | Kernel setup           | The kernel real-mode code.
         | Kernel boot sector     | The kernel legacy boot sector.
       X +------------------------+
         | Boot loader            | <- Boot sector entry point 0x7C00
001000   +------------------------+
         | Reserved for MBR/BIOS  |
000800   +------------------------+
         | Typically used by MBR  |
000600   +------------------------+
         | BIOS use only          |
000000   +------------------------+
```

# 内核启动第一步
- 实模式到保护模式
- 堆和控制台初始化
- 内存验证，CPU验证，键盘初始化

## 实模式到保护模式
[保护模式地址介绍](https://docs.hust.openatom.club/linux-insides-zh/booting/linux-bootstrap-2)

### 将启动参数拷贝到zeropage
在main.c文件中，首次运行的函数为:**copy_boot_params**。
这个函数将内核信息拷贝到 **struct boot_params boot_params(arch/x86/include/uapi/asm/bootparam.h)**,而 hdr 的内容是由 boot loader 填写
拷贝函数 memcpy 的定义为:
``` c++
// Copy.S
GLOBAL(memcpy)
	pushw	%si
	pushw	%di
	movw	%ax, %di
	movw	%dx, %si
	pushw	%cx
	shrw	$2, %cx
	rep; movsl
	popw	%cx
	andw	$3, %cx
	rep; movsb
	popw	%di
	popw	%si
	retl
ENDPROC(memcpy)
// arch/x86/include/asm/linkage.h
#define GLOBAL(name)	\
	.globl name;	\
	name:

#define ENDPROC(name) \
	.type name, @function ASM_NL \
	END(name)
```
copy.s中的其他使用了 fastcall 调用规则，意味着所有的函数调用参数是通过 ax, dx, cx寄存器传入的，而不是传统的通过堆栈传入
```c++
memcpy(&boot_params.hdr, &hdr, sizeof hdr);
```
函数的参数是这样传递的
- ax 寄存器指向 boot_param.hdr 的内存地址
- dx 寄存器指向 hdr 的内存地址
- cx 寄存器包含 hdr 结构的大小

## 控制台初始化
代码为: **arch/x86/boot/early_serial_console.c:console_init(void)**



intcall:
	cmpb	%al, 3f
	je	1f
	movb	%al, 3f
	jmp	1f
1:
	pushfl
	pushw	%fs
	pushw	%gs
	pushal



# qemu gdb
## 使用qemu启动内核
### 编译内核
- 关闭**nokaslr**:
```bash
make menuconfig
# disable kernel option "Randomize the kernel memory sections" inside "Processor type and features" 
# 打开debug info: Kernel hacking -> Compile-time checks and compiler options -> Compile the Kernel with debug info
```
### 制作临时文件系统
#### 编译busybox
```bash
make menuconfig
# 1. 使用静态链接
# 2. 关闭ash job control : shells -> []jobcontrol
# 3. 打开cttyhack: shells -> [*]cttyhack
```

#### 制作文件系统

1. 根文件系统方法一

```bash
mkdir -p initramfs
cd initramfs
mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
cp -av ../busybox-1.23.2/_install/* .

touch init
chmod +x init

################### init 文件插入以下代码，这是内核启动后马上会运行的代码 ###################
#!/bin/sh

# 挂载一些必要的文件系统
mount -t proc none /proc # 用于获取下方开机时间数据
mount -t sysfs none /sys
mount -t tmpfs none /tmp
mount -t devtmpfs none /dev

# 显示开机消耗时间
echo ------------------------------------------------------
echo
echo "Hello Linux"
echo "This boot took $(cut -d' ' -f1 /proc/uptime) seconds"
echo
echo ------------------------------------------------------

# 启动命令行程序，允许执行命令，不然开机日志输出完毕后什么都操作不了
exec /bin/sh
######################################

find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initrd_x86_64.gz
```

2. 根文件系统方法二
```bash
# 基本命令复制
mkdir -p initramfs
cd initramfs
mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
cp -av ../busybox-1.23.2/_install/* .
ln -s bin/busybox init

# init程序首先会访问/etc/inittab文件,增加此文件
cd etc
touch inittab
chmod +x inittab
####################### inittab 文件内容 Begin ##################

::sysinit:/etc/init.d/rcS
::askfirst:-/bin/sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a

####################### inittab 文件内容 End ##################

# inittab 文件首先会执行/etc/init.d/rcS脚本，rcS脚本创建以及内容为:
mkdir init.d
cd init.d
touch rcS
chmod +x rcS

####################### rcS 文件内容 Begin ##################

#/bin/sh
mount proc
mount -o remount,rw /
mount a
clear
echo "Tiny Linux Starting..."

####################### rcS 文件内容 End ##################

# rcS 脚本中，mount -a 是自动挂载 /etc/fstab 里面的东西
cd ..
touch fstab


####################### fstab 文件内容 Begin ##################

proc		/proc	proc		defaults	0	0
sysfs		/sys	sysfs		defaults	0	0
devtmpfs	/dev	devtmpfs	defaults	0	0

####################### fstab 文件内容 End ##################

# 返回目录根位置，制作文件系统
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../jerry_initrd.tar.gz
```

### 启动命令
使用方法一制作的文件系统
```bash
# gui
qemu-system-x86_64 -m 8G -serial stdio -enable-kvm -kernel bzImage -initrd initrd_x86_64.gz -append "init=/init"
# tty
qemu-system-x86_64 -m 8G -enable-kvm -kernel bzImage -initrd initrd_x86_64.gz -append "init=/init" -append "console=ttyS0" -nographic
```

**使用方法二制作的文件系统**
```bash
# gui
qemu-system-x86_64 -m 8G -serial stdio -enable-kvm -kernel bzImage -initrd jerry_initrd.tar.gz
# tty
qemu-system-x86_64 -m 8G -enable-kvm -kernel bzImage -initrd jerry_initrd.tar.gz -append "console=ttyS0" -nographic
```

### 使用gdb调试
第一个终端运行命令:
```bash
# gdb 调试只用在 非调试启动的命令参数上加上 -s -S 即可
# gui
qemu-system-x86_64 -m 8G -serial stdio -enable-kvm -kernel bzImage -initrd initrd_x86_64.gz -append "init=/init" -s -S
qemu-system-x86_64 -m 8G -serial stdio -enable-kvm -kernel bzImage -initrd jerry_initrd.tar.gz -s -S
# tty
qemu-system-x86_64 -m 8G -enable-kvm -kernel bzImage -initrd initrd_x86_64.gz -append "init=/init" -append "console=ttyS0 nokaslr" -nographic -s -S
qemu-system-x86_64 -m 8G -enable-kvm -kernel bzImage -initrd jerry_initrd.tar.gz -append "console=ttyS0 nokaslr" -nographic
```
第二个终端运行命令
```bash
cd ${LINUX_KERNEL_SRC_DIR}
gdb ./vmlinux
target remote :1234
hbreak start_kernel
continue
```
## 参考
[Using gdb to Debug the Linux Kernel](https://www.starlab.io/blog/using-gdb-to-debug-the-linux-kernel)

[Linux内核编译，使用qemu启动](https://zhuanlan.zhihu.com/p/683380725)

[Hardware breakpoint in GDB +QEMU missing start_kernel](https://unix.stackexchange.com/questions/396013/hardware-breakpoint-in-gdb-qemu-missing-start-kernel)

[用gdb调试vmlinux不显示符号](https://segmentfault.com/q/1010000009577541)

[QEMU+GDB调试Linux内核总结](https://blog.csdn.net/weixin_37867857/article/details/88205130)

