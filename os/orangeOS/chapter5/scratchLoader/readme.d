
内存布局：

| 内存地址范围  | 用途  |
| ---- | ---- |
| 0h - 03FFh  | 中断向量表  |
| 0400h - 04FFh  | BIOS 数据区  |
| 0500h - 9FFFFh  | 可用内存区域  |
| A0000h - AFFFFh  | 显示缓冲区  |
| B0000h - B7FFFh 或 B8000h - BFFFFh  | 显示缓冲区  |
| C0000h - EFFFFh  | ROM 区域  |
| F0000h - FFFFFh  | 系统 BIOS 区域  |
| 7C00h - 7E00h  | 引导扇区  |
| 80000h - 90000h  | KERNEL.BIN  |
| 90000h - 9FC00h  | LOADER.BIN  |
| 9FC00h - A0000h  | 扩展 BIOS 数据区  |
| 00100000h - 00101000h  | 页目录表和页表  |

总结来说：

0x90000开始的63kb留给了Loader.bin，0x80000开始的64Kb留给了Kernel.bin,0x30000开始的320kb留给整理后的内核。页表、页目录放到了1MB之后的高端内存区。

编译：
