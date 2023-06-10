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

;生产厂商名 8字节
OemName db 'mineboot'
;每扇区字节数 2字节
BytesPerSector dw 512
;每簇扇区数,簇是FAT类文件系统最小数据存储单位
SectorsPerClus db 1
;保留扇区数，引导扇区也算保留扇区
ReservedSectors db 1
;Fat表份数
FatCount db 2
;根目录可容纳目录项数
RootEntryCount dw 224
;总扇区数
TotalSectors_16 dw 2880
;介质存储类型，对于不可移动存储介质通常是0xF8,可移动存储介质值通常是0xF0。必须与FAT[0]一致。
MediaDescriptor db 0xf0
;每Fat扇区数
SectorsPerFat dw 9
;每磁道扇区数
SectorsPerTrack dw 18
;磁头数
HeadCount dw 2
;隐藏扇区数
HiddenSectors dd 0
;如果TotalSectors_16为0，则由此值记录扇区数
TotalSectors_32 dw 2880
;int 13h的驱动器号
DriverNumber db 0
;未使用,保留
Reserved db 0
;扩展引导标记
BootSig db 0x29
;卷序列号
VolumnId dd 0
;卷标
VolumnLabel db 'boot loader'
;文件系统类型，只是描述性的字符，没有实质作用
FileType db 'FAT12'
_start:





























