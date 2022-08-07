section header vstart=0
    program_length dd program_end
    code_entry dw start ;定义入口点
    dd section.code_1.start ;代码段地址
    realloc_tbl_len dw (header_end-code_1_segment)/4

    code_1_segment dd section.code_1.start
    code_2_segment dd section.code_2.start
    data_1_segment dd section.data_1.start
    data_2_segment dd section.data_2.start
    stack_segment dd section.stack.start
    header_end:

section code_1 align=16 vstart=0
    ;从数据区取字符，如果是0，则返回主程序
    put_string:
        mov cl,[bx]
        or cl,cl
        jz .exit
        call put_char
        inc bx
        jmp put_string
    .exit:
        ret
    put_char:
        push ax
        push bx
        push cx
        push dx
        push ds
        push es

        mov dx,0x3d4    ;通过索引寄存器端口设置要操作0x0e端口(从0x0e端口读数据，读光标)
        mov al,0x0e
        out dx,al
        mov dx,0x3d5    ;数据端口
        in al,dx
        mov ah,al

        mov dx,0x3d4
        mov al,0x0f
        out dx,al
        mov dx,0x3d5
        in al,dx
        mov bx,ax   ;经过上面的读，bx中就存储了光标位置

        cmp cl,0x0d ;判断是不是回车，如果是回车需要将光标置于行首
        jnz .put_0a
        mov ax,bx
        mov bl,80
        div bl
        mul bl  ;乘法，bl和al相乘，结果放在ax中
        mov bx,ax
        jmp .set_cursor
    .put_0a:
        cmp cl,0x0a
        jnz .put_other
        add bx,80
        jmp .roll_screen
    .put_other:
        mov ax,0xb800
        mov es,ax
        shl bx,1    ;一个字符对应两个字节，乘以2既得在显存中的地址
        mov [es:bx],cl
        shr bx,1    ;恢复bx的值
        add bx,1    ;增加光标的值
    .roll_screen:
        cmp bx,2000 ;如果bx小于一屏内容，直接设置光标，否则滚动屏幕
        jl .set_cursor
        mov ax,0xb800
        mov ds,ax
        mov es,ax
        cld
        ;将第二行到最后一行的值移到第一行到24行
        mov si,0xa0
        mov di,0x00
        mov cx,1920
        rep movsw
        mov bx,3840
        mov cx,80
    .cls
        mov word[es:bx],0x0720
        add bx ,2
        loop .cls
        mov bx,1920
    
    ;根据bx中值设置光标
    .set_cursor:
        mov dx,0x3d4
        mov al,0x0e
        out dx,al
        mov dx,0x3d5
        mov al,bh
        out dx,al
        mov dx,0x3d4
        mov al,0x0f
        out dx,al
        mov dx,0x3d5
        mov al,bl
        out dx,al

        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax

        ret
    ;程序入口点
    start:
        mov ax,[stack_segment]
        mov ss,ax
        mov sp,stack_end

        mov ax,[data_1_segment]
        mov ds,ax
        
        mov bx,msg0
        call put_string

        push word [es:code_2_segment]
        mov ax,begin
        push ax

        retf
    continue:
        mov ax,[es:data_2_segment]
        mov ds,ax
        mov bx,msg1
        call put_string
        jmp $
section code_2 align=16 vstart=0
    begin:
        push word [es:code_1_segment]
        mov ax,continue
        push ax

        retf
section data_1 align=16 vstart=0
    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0
section data_2 align=16 vstart=0
     msg1 db '  The above contents is written by LeeChung. '
         db '2011-05-06'
         db 0
section stack align=16 vstart=0
    resb 256
    stack_end:
section trail align=16
program_end:
    
