section header vstart=0
    program_length dd program_end   ;程序总长度 0x00
    head_len       dd header_end    ;程序头部总长度 0x04
    stack_seg      dd 0             ;用于接受堆栈段选择子  0x08
    stack_len      dd 1             ;程序建议的堆栈大小0x0c,4KB为单位

    prgentry       dd start         ;程序入口0x10
    code_seg       dd section.code.start;代码段位置0x14
    code_len       dd code_end      ;代码段长度0x18
    data_seg       dd section.data.start;数据段位置0x1c
    data_len       dd data_end      ;数据段长度0x20

    ;符号地址检索表（自定义的一个标准），内核提供库函数应该是通过软中断的方式，这里为了简便，制定标准，内核在加载时会读此表，将真正偏移地址回填
    salt_items     dd (header_end-salt)/256 ;0x24
    salt:
    PrintString    db '@PrintString'
                   times 256-($-PrintString) db 0
    TerminalProgram db '@TerminalProgram'
                   times 256-($-TerminalProgram) db 0
    ReadDiskData db '@ReadDiskData'
                   times 256-($-ReadDiskData) db 0
header_end:
section data vstart=0
    buffer times 1024 db 0  ;缓冲区
    message_1 db 0x0d,0x0a,0x0d,0x0a
              db '*******User program is running*******'
              db 0x0d,0x0a,0
    message_2 db 0x0d,0x0a,0
data_end:

[bits 32]

section code vstart=0
    start:
        mov eax,ds
        mov fs,eax

        mov eax,[stack_seg]
        mov ss,eax
        mov esp,0

        mov eax,[data_seg]
        mov ds,eax

        mov ebx,message_1
        call far [fs:PrintString]

        mov eax,100
        mov ebx,buffer
        call far [fs:ReadDiskData]  ;段间调用

        mov ebx message_2
        call far [fs:PrintString]

        mov ebx,buffer
        call far [fs:PrintString]
        
        jmp far [fs:TerminalProgram]

code_end:

section trail
program_end: