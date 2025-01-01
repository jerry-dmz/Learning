SELECTOR_KERNEL_CS equ 8

extern     cstart

extern     gdt_ptr

[section .bbs]
StackSpace resb 2 * 1024
StackTop:
[section .text]

global     _start

_start:
    mov  esp, StackTop
    sgdt [gdt_ptr]     ; 将gdt信息存储到导入的gdt_ptr中去
    call cstart
    lgdt [gdt_ptr]

    jmp SELECTOR_KERNEL_CS:csinit

csinit:
    push 0
    popfd
    hlt