%include	"pm.inc"	

org 0100h
	jmp begin

[SECTION .gdt]
; GDT
;                            段基址,        段界限 , 属性
desc_null:         Descriptor    0,              0, 0         ; 空描述符
desc_normal: Descriptor    0,         0ffffh, DA_DRW    ; Normal 描述符
desc_code32: Descriptor    0, SegCode32Len-1, DA_C+DA_32; 非一致代码段, 32
desc_code16: Descriptor    0,         0ffffh, DA_C      ; 非一致代码段, 16
desc_data:   Descriptor    0,      DataLen-1, DA_DRW    ; Data
desc_stack:  Descriptor    0,     TopOfStack, DA_DRWA+DA_32; Stack, 32 位
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
; END of [SECTION .gdt]

[SECTION .data1]	 ; 数据段
ALIGN 32
[BITS	32]
LABEL_DATA:
SPValueInRealMode dw  0
; 字符串
PMMessage:        db  "In Protect Mode now. ^-^", 0   ; 在保护模式中显示
OffsetPMMessage   equ PMMessage - $$
StrTest:          db  "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest     equ StrTest - $$
DataLen           equ $ - LABEL_DATA
; END of [SECTION .data1]


; 全局堆栈段
[SECTION .gs]
ALIGN 32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack equ $ - LABEL_STACK - 1

; END of [SECTION .gs]


[SECTION .s16]
[BITS	16]
begin:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	mov [LABEL_GO_BACK_TO_REAL+3], ax
	mov [SPValueInRealMode],       sp

	; 初始化 16 位代码段描述符
	mov   ax,                     cs
	movzx eax,                    ax
	shl   eax,                    4
	add   eax,                    LABEL_SEG_CODE16
	mov   word [desc_code16 + 2], ax
	shr   eax,                    16
	mov   byte [desc_code16 + 4], al
	mov   byte [desc_code16 + 7], ah

	; 初始化 32 位代码段描述符
	xor eax,                    eax
	mov ax,                     cs
	shl eax,                    4
	add eax,                    LABEL_SEG_CODE32
	mov word [desc_code32 + 2], ax
	shr eax,                    16
	mov byte [desc_code32 + 4], al
	mov byte [desc_code32 + 7], ah

	; 初始化数据段描述符
	xor eax,                  eax
	mov ax,                   ds
	shl eax,                  4
	add eax,                  LABEL_DATA
	mov word [desc_data + 2], ax
	shr eax,                  16
	mov byte [desc_data + 4], al
	mov byte [desc_data + 7], ah

	; 初始化堆栈段描述符
	xor eax,                   eax
	mov ax,                    ds
	shl eax,                   4
	add eax,                   LABEL_STACK
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
; END of [SECTION .s16]


[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LABEL_SEG_CODE32:
	mov ax, dataSelector
	mov ds, ax            ; 数据段选择子
	mov ax, testSelector
	mov es, ax            ; 测试段选择子
	mov ax, videoSelector
	mov gs, ax            ; 视频段选择子

	mov ax, stackSelector
	mov ss, ax            ; 堆栈段选择子

	mov esp, TopOfStack


	; 下面显示一个字符串
	mov ah,  0Ch               ; 0000: 黑底    1100: 红字
	xor esi, esi
	xor edi, edi
	mov esi, OffsetPMMessage   ; 源数据偏移
	mov edi, (80 * 10 + 0) * 2 ; 目的数据偏移。屏幕第 10 行, 第 0 列。
	cld
.1:
	lodsb
	test al,       al
	jz   .2
	mov  [gs:edi], ax
	add  edi,      2
	jmp  .1
.2: ; 显示完毕

	call DispReturn

	call TestRead
	call TestWrite
	call TestRead

	; 到此停止
	jmp code16Selector:0

; ------------------------------------------------------------------------
TestRead:
	xor esi, esi
	mov ecx, 8
.loop:
	mov  al, [es:esi]
	call DispAL
	inc  esi
	loop .loop

	call DispReturn

	ret
; TestRead 结束-----------------------------------------------------------


; ------------------------------------------------------------------------
TestWrite:
	push esi
	push edi
	xor  esi, esi
	xor  edi, edi
	mov  esi, OffsetStrTest ; 源数据偏移
	cld
.1:
	lodsb
	test al,       al
	jz   .2
	mov  [es:edi], al
	inc  edi
	jmp  .1
.2:

	pop edi
	pop esi

	ret
; TestWrite 结束----------------------------------------------------------


; ------------------------------------------------------------------------
; 显示 AL 中的数字
; 默认地:
;	数字已经存在 AL 中
;	edi 始终指向要显示的下一个字符的位置
; 被改变的寄存器:
;	ax, edi
; ------------------------------------------------------------------------
DispAL:
	push ecx
	push edx

	mov ah,  0Ch ; 0000: 黑底    1100: 红字
	mov dl,  al
	shr al,  4
	mov ecx, 2
.begin:
	and al, 01111b
	cmp al, 9
	ja  .1
	add al, '0'
	jmp .2
.1:
	sub al, 0Ah
	add al, 'A'
.2:
	mov [gs:edi], ax
	add edi,      2

	mov  al,  dl
	loop .begin
	add  edi, 2

	pop edx
	pop ecx

	ret
; DispAL 结束-------------------------------------------------------------


; ------------------------------------------------------------------------
DispReturn:
	push eax
	push ebx
	mov  eax, edi
	mov  bl,  160
	div  bl
	and  eax, 0FFh
	inc  eax
	mov  bl,  160
	mul  bl
	mov  edi, eax
	pop  ebx
	pop  eax

	ret
; DispReturn 结束---------------------------------------------------------

SegCode32Len equ $ - LABEL_SEG_CODE32
; END of [SECTION .s32]


; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[SECTION .s16code]
ALIGN 32
[BITS	16]
LABEL_SEG_CODE16:
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

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY ; 段地址会在程序开始处被设置成正确的值

Code16Len equ $ - LABEL_SEG_CODE16

; END of [SECTION .s16code]