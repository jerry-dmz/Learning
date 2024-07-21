%include	"pm.inc"	
; *****************
; 测试从实模式进入到保护模式，又从保护模式返回实模式
; *****************
org 0100h
	xchg bx, bx
	jmp  begin

; [SECTION .gdt]
; GDT
;                            段基址,        段界限 , 属性
desc_null:         Descriptor    0,              0, 0   ; 空描述符
desc_normal: Descriptor    0,         0ffffh, DA_DRW    ; Normal 描述符
desc_code32: Descriptor    0, SegCode32Len-1, DA_C+DA_32; 非一致代码段, 32
desc_code16: Descriptor    0,         0ffffh, DA_C      ; 非一致代码段, 16
desc_data:   Descriptor    0,      DataLen-1, DA_DRW    ; Data
desc_stack:  Descriptor    0,     stackLength, DA_DRWA+DA_32; Stack, 32 位
desc_test:   Descriptor 0500000h,     0ffffh, DA_DRW
desc_video:  Descriptor  0B8000h,     0ffffh, DA_DRW    ; 显存首地址
; GDT 结束

GdtLen equ $ - desc_null ; GDT长度
GdtPtr dw  GdtLen - 1    ; GDT界限
		dd 0 ; GDT基地址

; GDT 选择子
normalSelector equ desc_normal	- desc_null
code32Selector equ desc_code32	- desc_null
code16Selector equ desc_code16	- desc_null
dataSelector   equ desc_data		- desc_null
stackSelector  equ desc_stack	- desc_null
testSelector   equ desc_test		- desc_null
videoSelector  equ desc_video	- desc_null

; [SECTION .data1]	 ; 数据段
ALIGN 32
[BITS	32]
DATA_SEGMENT:
SPValueInRealMode dw  0
; 字符串
message:          db  "In Protect Mode now. ^-^", 0 ; 在保护模式中显示
messgeOffset      equ message - DATA_SEGMENT
DataLen           equ $-DATA_SEGMENT
; END of [SECTION .data1]


; 全局堆栈段
; [SECTION .gs]
ALIGN 32
[BITS	32]
STACK_SEGMENT:
	times 512 db 0

stackLength equ $ - STACK_SEGMENT - 1

; END of [SECTION .gs]


[BITS	16]
begin:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	mov [realModeJmpLabel+3], ax
	mov [SPValueInRealMode],  sp

	; 初始化 16 位代码段描述符
	mov   ax,                     cs
	movzx eax,                    ax     ;无符号扩展操作，将ax内容拷贝到eax，并将eax其他位用0填充
	shl   eax,                    4      ;这行加下一行的目的，物理地址=基值*16 + 偏移地址
	add   eax,                    code16
	mov   word [desc_code16 + 2], ax
	shr   eax,                    16
	mov   byte [desc_code16 + 4], al
	mov   byte [desc_code16 + 7], ah

	; 初始化 32 位代码段描述符
	xor eax,                    eax
	mov ax,                     cs
	shl eax,                    4
	add eax,                    code32
	mov word [desc_code32 + 2], ax
	shr eax,                    16
	mov byte [desc_code32 + 4], al
	mov byte [desc_code32 + 7], ah

	; 初始化数据段描述符
	xor eax,                  eax
	mov ax,                   ds
	shl eax,                  4
	add eax,                  DATA_SEGMENT
	mov word [desc_data + 2], ax
	shr eax,                  16
	mov byte [desc_data + 4], al
	mov byte [desc_data + 7], ah

	; 初始化堆栈段描述符
	xor eax,                   eax
	mov ax,                    ds
	shl eax,                   4
	add eax,                   STACK_SEGMENT
	mov word [desc_stack + 2], ax
	shr eax,                   16
	mov byte [desc_stack + 4], al
	mov byte [desc_stack + 7], ah

	; 为加载 GDTR 作准备
	xor eax,                eax
	mov ax,                 ds
	shl eax,                4
	add eax,                desc_null ; eax <- gdt 基地址
	mov dword [GdtPtr + 2], eax       ; [GdtPtr + 2] <- gdt 基地址

	; 加载 GDTR
	lgdt [GdtPtr]

	; 关中断
	cli

	; 打开地址线A20
	in  al,  92h
	or  al,  00000010b
	out 92h, al

	; 准备切换到保护模式
	mov eax, cr0
	or  eax, 1
	mov cr0, eax

	; 真正进入保护模式
	jmp dword code32Selector:0 ; 执行这一句会把 code32Selector 装入 cs, 并跳转到 Code32Selector:0  处

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LABEL_REAL_ENTRY: ; 从保护模式跳回到实模式就到了这里
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax

	mov sp, [SPValueInRealMode]

	in  al,  92h       ; `.
	and al,  11111101b ;  | 关闭 A20 地址线
	out 92h, al        ; /

	sti ; 开中断

	mov ax, 4c00h ; `.
	int 21h       ; /  回到 DOS


; 32 位代码段. 由实模式跳入.
[BITS	32]
code32:
	mov ax, dataSelector
	mov ds, ax            ; 数据段选择子
	mov ax, testSelector
	mov ax, videoSelector
	mov es, ax            ; 测试段选择子
	mov gs, ax            ; 视频段选择子

	mov ax, stackSelector
	mov ss, ax            ; 堆栈段选择子

	mov  esp, stackLength
	xchg bx,  bx


	; 下面显示一个字符串
	mov ah,  0Ch               ; 0000: 黑底    1100: 红字
	xor esi, esi
	xor edi, edi
	mov esi, messgeOffset      ; 源数据偏移
	mov edi, (80 * 17 + 1) * 2 ; 目的数据偏移。屏幕第 17 行, 第 0 列。
	cld                        ; 将标志寄存器方向标志位(DF)清零，串操作指令中，DF控制内存地址的变化方向
	.work:
		lodsb              ; losb al, byte ptr ds:[esi]。由esi指向的内存单元读取一个字节数据到al中，然后根据df的值增加或减少esi的值
		test  al,       al ; 测试是否位字符串结束
		jz    .done
		mov   [gs:edi], ax ;将字符送到显存
		add   edi,      2  ;一个字符占两个字节
		jmp   .work
	.done:
		xchg bx, bx
		jmp  code16Selector:0

SegCode32Len equ $ - code32


; 16 位代码段. 由 32 位代码段跳入
ALIGN 32
[BITS	16]
code16:
	; 从保护模式回到实模式之前，需要加载一个合适的描述符选择子到有关段寄存器，以使对应段描述符高速缓存器中含有合适的段界限和属性。
	; 而且不能从32位代码段返回实模式（无法实现从32位代码段返回时cs高速缓冲寄存器中属性符合实模式的要求），而实模式是无法改变段属性的。
	; 跳回实模式:
	mov ax, normalSelector
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov eax, cr0
	and al,  11111110b
	mov cr0, eax
	; 此处跳转指令的基地址为0，实际上整条长跳转指令的基地址是从第三个字节开始。
	; 0eah offset(两字节) base(两字节)
	; 是通过mov ax,cs;mov [realModeJmpLabel+2],ax动态设置的
	; 无法直接给cs赋值，只能通过跳转指令，其实也可以搞个段专门存实模式下的cs，或跳转到32位时将其压栈，也是可以
	realModeJmpLabel:
	jmp 0: LABEL_REAL_ENTRY