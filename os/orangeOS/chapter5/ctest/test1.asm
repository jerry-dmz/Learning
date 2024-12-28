;用汇编编写一个elf形式的hello world程序
; nasm test1.asm -f elf64 -o test1.o
; ld test1.o -o test1
[section .data]
    strHello db  "Hello world!" ,0Ah
    STRLEN   equ $ - strHello
[section .text]
    global _start ; 链接器默认入口点，必须定义且导出，类似c语言中main函数
_start:
    mov edx, STRLEN
    mov ecx, strHello
    mov ebx, 1
    mov eax, 4        ;sys_write
    int 0x80
    mov ebx, 0
    mov eax, 1        ;sys_exit
    int 0x80
    

