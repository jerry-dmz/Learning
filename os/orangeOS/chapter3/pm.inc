;常量-----------------------------------------------------------------------------------

; G-D/B-L-AVL 4位
DA_32 equ 4000h ;0100(G-D/B-L-AVL) 0000 0000(P-DPL-S) 0000(type)

DA_DPL0 EQU	  00h ; DPL = 0
DA_DPL1 EQU	  20h ; DPL = 1
DA_DPL2 EQU	  40h ; DPL = 2
DA_DPL3 EQU	  60h ; DPL = 3

;P-DPL-S 4位 type 4位

;代码段或数据段
DA_DR   equ 90h ;1001 0000  存在的只读数据段
DA_DRW  equ 92h ;1001 0010  存在的可读写数据段 
DA_DRWA equ 93h ;1001 0011  已访问的存在的可读写数据段
DA_C    equ 98h ;1001 1000  存在的只执行代码段
DA_CR   equ 9Ah ;1001 1010  存在的可执行、可读代码段
DA_CCO  equ 9Ch ;1001 1100  存在的只执行一致性代码段
DA_CCOR equ 9Eh ;1001 1110  存在的可执行、可读一致性代码段

;系统段
DA_LDT      EQU	  82h ; 局部描述符表段类型值
DA_TaskGate EQU	  85h ; 任务门类型值
DA_386TSS   EQU	  89h ; 可用 386 任务状态段类型值
DA_386CGate EQU	  8Ch ; 386 调用门类型值
DA_386IGate EQU	  8Eh ; 386 中断门类型值
DA_386TGate EQU	  8Fh ; 386 陷阱门类型值

; 选择子类型值说明
; 其中:
;       SA_  : Selector Attribute

SA_RPL0     EQU	0     ; ┓
SA_RPL1     EQU	1     ; ┣ RPL
SA_RPL2     EQU	2     ; ┃
SA_RPL3     EQU	3     ; ┛

SA_TIG      EQU	0     ; ┓TI
SA_TIL      EQU	4     ; ┛


;由于历史问题，描述符结构有点乱，段基址（32位）、段界限（20）都被拆开了在加上属
;性占据的12位，一共8字节64位
;
;外部定义描述符时，肯定是希望简单些好。8字节从高到底分别是：
;段基址3（8位）   属性（2字节16位，其中4位段界限限） 段基址1+段基址2（24位分为16+8） 段界限1（16位）
;
;

;描述符
;usage: Descriptor Base, Limit, Atrr
;       Base: dd
;       Limit: dd（low 20bits available）
;       Atrr: dw(lower 4 bits of higher byte are always 0)
;此处还是《x86 从实模式到保护模式》的图更清楚些。
;此处描述符之所以是这样，是为了兼容以前的数据结构：
;刚开始8086实模式，基地址和界限都是16位（即低4字节），此时也只存储基址、界限
;后面某个版本有了段的概念，地址线也由20变成了更多位，只能在原基础上加的缘故。
;
; 例子：
; Descriptor 000B8000h,0ffffh, 0092h
; 输出：
; 待研究
%macro Descriptor 3
dw %2 & 0FFFFh                       ;段界限1（16位） 取段界限的低16位
dw %1 & 0FFFFh                       ;段基址1  取基址的低16位   8000
db (%1 >> 16) & 0FFh                 ;段基址2 取基址的中8位  0B
dw ((%2 >> 8) & 0F00h)|(%3 & 0F0FFh) ;属性1 + 段界限2 + 属性2
db (%1 >> 24) & 0FFh                 ;段基址3 取基址的高8位 00
%endmacro   ; 供8字节

;
; 门
; usage: Gate Selector, Offset, DCount, Attr
;        Selector:  dw
;        Offset:    dd
;        DCount:    db
;        Attr:      db
%macro Gate 4
	dw (%2 & 0FFFFh)                     ; 偏移1
	dw %1                                ; 选择子
	dw (%3 & 1Fh) | ((%4 << 8) & 0FF00h) ; 属性
	dw ((%2 >> 16) & 0FFFFh)             ; 偏移2
%endmacro ; 共 8 字节

;宏-------------------------------------------------------------------------------------