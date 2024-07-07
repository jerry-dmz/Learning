%include "pm.inc"
; bochsdbg内存dump
;
; jmp begin 指令对应：
; 0x7c00 0xe9
; 0x7c01 0x1e
; 0x7c02 0x00
;
; 0x7c ~ 0x7x1a 对应gdt定义：
; 0x7c03 ~ 0x7c0a  0x00   0x00   0x00   0x00   0x00  0x00   0x00   0x00
; 0x7c0b ~ 0x7c12  0x17   0x00   0x00   0x00   0x00  0x98   0x40   0x00
; 0x7c13 ~ 0x7c1a  0xFF   0xFF   0x00   0x80   0x0b  0x92   0x00   0x00
;
; gdtptr对应
; 0x7c1b ~ 0x7c20  0x17   0x00   0x00   0x00   0x00  0x00

org 07c00h
    jmp beign

;gdt开始
;Descriptor Base, Limit, Attr
;这个具体要参考pm.inc中的宏定义
; [section .gdt]
desc_null:Descriptor 0,0,0  ;空段，硬件要求 8字节
desc_code:Descriptor 0,seg32Len-1, DA_C + DA_32    ;非一致性代码段  TODO:此处界限，此处界限即使再大应该也不会影响执行 8字节
desc_video:Descriptor 0B8000h,0ffffh, DA_DRW    ;显存段 8字节
;gdt结束

;      db  一个字节 8位
;      dw  一个字，2字节 16位
;      dd  双字，4字节  32位
;      dq  四字，8字节  64位
;lgdt指令需要的数据
gdtlen equ $ - desc_null ;gdt长度
gdtptr dw  gdtlen - 1    ;gdt界限 2字节
        dd 0 ;gdt基址

; 选择子为描述符在描述符表里的位移
;一个描述符8字节，选择子的值必定是64的倍数
;gdt选择子开始
codeSelector  equ desc_code - desc_null
videoSelector equ desc_video - desc_null
;gdt选择子结束

; 上述数据定义33字节，故begin处地址为0x7c21
; [section .s16]
[bits 16]
beign:
    ; cs初始值值为0
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    ;TODO:此处将设置为0100h的意义
    mov sp, 0100h

    ;将32位段的基址塞到desc_code中
    xor eax,                  eax   ;此处代码多余，可以去掉
    mov ax,                   cs    ;此处代码多余，可以去掉
    shl eax,                  4     ;也多余，为什么会有这个操作???
    add eax,                  seg32 ;32位段基址
    mov word [desc_code + 2], ax    ;低16位的基址，TODO:还是没搞太懂，待调试
    shr eax,                  16
    mov byte [desc_code + 4], al    ;中8位
    mov byte [desc_code + 7], ah    ;高8位

    ;加载gdtr
    xor eax,                eax
    mov ax,                 ds        ;此处不多于，mov dword [gdtptr +2 ],ax，使用的就是ds寄存器
    shl eax,                4         ;此处代码多余
    add eax,                desc_null
    mov dword [gdtptr + 2], eax       ;这里是加16位，为什么要在这里加？前面其实定义时是不是就可以决定？？？

    lgdt [gdtptr] ;也是以ds作为基地址

    ;关中断
    cli

    ;打开地址线A20，有多种方式
    in  al,  92h
    or  al,  00000010b
    out 92h, al

    ;切换到保护模式
    mov eax, cr0
    or  eax, 1
    mov cr0, eax
    ;混合在16位的32代码
    ;直接使用jmp codeSelector:0x12234,如果偏移比较大，在16位编译模式下可能会被截断。
    ;linux中直接使用db指令直接写二进制代码实现。nasm中允许在前面加一个dword关键字。
    jmp dword codeSelector:0

; [section .32]
[bits 32]

seg32:
    mov ax,       videoSelector
    mov gs,       ax
    mov edi,      (80 * 17 +1) * 2 ;屏幕17行
    mov ah,       0xf4             ;1111:白底 1110：红字
    mov al,       'H'
    mov [gs:edi], eax
    add di,       2
    mov al,       'E'
    mov [gs:edi], eax
    add di,       2
    mov al,       'L'
    mov [gs:edi], eax
    add di,       2
    mov al,       'L'
    mov [gs:edi], eax
    add di,       2
    mov al,       'O'
    mov [gs:edi], eax
    add di,       2
    mov al,       '!'
    mov [gs:edi], eax

    jmp $
seg32Len         equ $ - seg32 ;32位代码段长度

;此处应该加下面两行代码，不然复制到img时不会是一个启动扇区，而且$$表示相对于当前段地址的偏移地址
times 510-($-$$) db  0
dw                   0xaa55
