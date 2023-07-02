%include "C:\Users\dmzc\Desktop\Learing\os\orangeOS\chapter3\a\pm.inc"
org 07c00h
    jmp beign

;gdt开始
[section .gdt]
desc_null:Descriptor 0,0,0  ;空段，硬件要求
desc_code:Descriptor 0,seg32Len, DA_C + DA_32    ;非一致性代码段  TODO:此处界限
desc_video:Descriptor 0B8000h,0ffffh,DA_DRW    ;显存段
;gdt结束

;lgdt指令需要的数据
gdtlen  equ $ - desc_null  ;gdt长度
gdtptr  dw gdtlen - 1;gdt界限
        dd  0      ;gdt基址

;gdt选择子开始
codeSelector    equ desc_code - desc_null
videoSelector   equ desc_video - desc_null 
;gdt选择子结束

[section .s16]
[bits 16]
beign:
    mov ax,cs
    mov dx,ax
    mov es,ax
    mov ss,ax
    mov sp,0100h

    ;将32位段的基址塞到desc_code中
    xor eax,eax
    mov ax,cs
    shl eax,4       ;为什么会有这个操作???实模式下是20位物理地址，但是32位下是32位的
    add eax,seg32   ;32位段基址
    mov word [desc_code + 2], ax ;低16位的基址
    shr eax, 16
    mov byte [desc_code + 4], al ;中8位
    mov byte [desc_code + 7], ah ;高8位

    ;加载gdtr
    xor eax, eax
    mov ax, ds  ;这个似乎也是多余的
    shl eax, 4
    add eax, desc_null
    mov dword [gdtptr + 2], eax ;这里是加16位，一字节即1dw

    lgdt [gdtptr]

    ;关中断
    cli

    ;打开地址线A20，有多种方式
    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp dword codeSelector:0

[section .32]
[bits 32]

seg32:
    mov ax,videoSelector
    mov gs,ax

    mov edi,(80 * 11 + 79) * 2  ;屏幕11行，79列
    mov ah,0ch                  ;0000:黑底 1110：红字
    mov ah,'P'
    mov [gs:edi],ax

    jmp $
seg32Len equ $ - seg32          ;32位代码段长度
