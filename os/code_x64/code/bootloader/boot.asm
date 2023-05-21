;具体思路，建立FAT文件系统,加载loader

;----内存空间布局----：
;000~3FF        1KB 中断向量表
;400~4FF        256B BIOS数据区
;500~7BFF       约30KB 可用区域
;7C00~7DFF      512B MBR被加载到此处
;7E00~9FBFF     约608KB 可用区域
;9FCC00~9FFFF   1KB 扩展BIOS数据区   
;A0000~AFFFFF   64KB 彩色适配器 
;B0000~B7FFF    32KB 黑白适配器
;B8000~BFFFF    32KB 文本模式适配器
;C0000~C7FFF    32KB 显示器BIOS
;C8000~EFFFF    160KB 映射硬件适配器ROM或内存映射式I/O
;F0000~FFFEF    64kB减去16B 系统BIOS范围 
;FFFF0~FFFFF    16B  初始加电时CS:IP指向此处 
;----内存空间布局----

org 0x7c00
;定义常量，equ是伪指令，并不代表最后文件会包含此数据，类似宏

;栈地址，因为栈由高往低递减，因此定为此处较合适
stackBase equ 0x7c00



;定义FAT文件系统元数据。FAT类文件系统将扇区划分引导扇区、FAT表、根目录区、数据区。
;要求第一个为一个跳转指令，跳过后面的文件系统元数据

jmp short _start
nop

_start:





























