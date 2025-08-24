; 测试汇编和c语言相互调用
; nasm -f elf test2.asm -o test2.o
; gcc -m32 -c -o choose.o choose.c
; ld -m elf_i386 -o test3 test2.o choose.o
; 示例asm程序中push dword是32位写法，所以要按32位编译。
; 还要搞懂64位的写法。
;
extern choose ; 外部函数，遵循c语言调用约定，后面参数先入栈，并由调用者清理堆栈
[section .data]
    num1 dd 3
    num2 dd 4
[section .text]
    global _start
    global myprint
_start:
    push dword [num2]
    push dword [num1]
    call choose
    add  esp, 8

    mov ebx, 0
    mov eax, 1 ;sys_exit
    int 0x80

; void myprint(char* msg,int len) 
myprint:
    mov edx, [esp + 8]
    mov ecx, [esp + 4]
    mov ebx, 1
    mov eax, 4         ;sys_write
    int 0x80
    mov ebx, 0
    mov eax, 1         ;sys_exit
    int 0x80

