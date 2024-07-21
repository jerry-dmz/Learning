%include	"pm.inc"	
; *****************
; 测试retf
; *****************
org 0100h
	xchg bx, bx
	jmp  code16

; GDT
	;                            段基址,        段界限 , 属性
	desc_null: Descriptor    0,              0, 0   ; 空描述符
	desc_normal: Descriptor    0,         0ffffh, DA_DRW    ; Normal 描述符
	desc_code32: Descriptor    0, SegCode32Len-1, DA_C+DA_32; 非一致代码段, 32
	desc_code32Ring3: Descriptor 0, SegCodeRing3Len, DA_C+DA_32+DA_DPL3
	desc_data:   Descriptor    0,      DataLen-1, DA_DRW    ; Data
	desc_video:  Descriptor  0B8000h,     0ffffh, DA_DRW + DA_DPL3   ; 显存首地址
	desc_stack:  Descriptor    0,     stackLength, DA_DRWA+DA_32; Stack, 32 位
	desc_stack3:  Descriptor    0,     stack3Length, DA_DRWA+DA_32+DA_DPL3; Stack-Ring3, 32 位
	;gdtr
	GdtLen equ $ - desc_null ; GDT长度
	GdtPtr dw  GdtLen - 1    ; GDT界限
			dd 0 ; GDT基地址
; GDT

; GDT选择子
	normalSelector      equ desc_normal	- desc_null
	code32Selector      equ desc_code32	- desc_null
	code32Ring3Selector equ desc_code32Ring3 - desc_null+SA_RPL3
	dataSelector        equ desc_data		- desc_null
	stackSelector       equ desc_stack	- desc_null
	stack3Selector      equ desc_stack3 - desc_null+SA_RPL3
	videoSelector       equ desc_video	- desc_null
; GDT选择子

; 32位数据段
	ALIGN 32
	[BITS	32]
	DATA_SEGMENT:
	; 字符串
	message:     db  "In Protect Mode now. ^-^", 0 ; 在保护模式中显示
	messgeOffset equ message - DATA_SEGMENT
	DataLen      equ $-DATA_SEGMENT
; 32位数据段

; 全局堆栈段
	ALIGN 32
	[BITS	32]
	stack:
		times 512 db 0

	stackLength equ $ - stack - 1
; 全局堆栈段

;Ring3堆栈段
	ALIGN 32
	[BITS	32]
	stack3:
		times 512 db 0

	stack3Length equ $ - stack3 - 1
;Ring3堆栈段

; 16位代码段-初始化
	[BITS	16]
	code16:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	; 初始化 32 位代码段描述符
	xor eax,                    eax
	mov ax,                     cs
	shl eax,                    4
	add eax,                    code32
	mov word [desc_code32 + 2], ax
	shr eax,                    16
	mov byte [desc_code32 + 4], al
	mov byte [desc_code32 + 7], ah

	; 初始化32位代码段（ring3）描述符
	xor eax,                         eax
	mov ax,                          cs
	shl eax,                         4
	add eax,                         code32Ring3
	mov word [desc_code32Ring3 + 2], ax
	shr eax,                         16
	mov byte [desc_code32Ring3 + 4], al
	mov byte [desc_code32Ring3 + 7], ah

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
	add eax,                   stack
	mov word [desc_stack + 2], ax
	shr eax,                   16
	mov byte [desc_stack + 4], al
	mov byte [desc_stack + 7], ah

	; 初始化堆栈段(ring3)描述符
	xor eax,                    eax
	mov ax,                     ds
	shl eax,                    4
	add eax,                    stack3
	mov word [desc_stack3 + 2], ax
	shr eax,                    16
	mov byte [desc_stack3+ 4],  al
	mov byte [desc_stack3 + 7], ah

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
; 16位代码段-初始化

; 32位代码段-ring0
	[BITS	32]
	code32:
		mov ax, dataSelector
		mov ds, ax            ; 数据段选择子
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
			push stack3Selector
			push stack3Length
			push code32Ring3Selector
			push 0
			retf
	SegCode32Len equ $ - code32
; 32位代码段-ring0

; 32位代码段-ring3
	ALIGN 32
	[BITS	32]
	code32Ring3:
		xchg bx,       bx
		mov  ax,       videoSelector
		mov  gs,       ax
		mov  edi,      (80 * 14 + 0) * 2
		mov  ah,       0Ch
		mov  al,       '3'
		mov  [gs:edi], ax

		jmp $
	SegCodeRing3Len equ $ - code32Ring3
; 32 位代码段-ring3