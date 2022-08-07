section header vstart=0
    program_length dd program_end
    code_entry dw start
               dd section.code.start
    realloc_tbl_len dw (header_end-realloc_begin)/4
    realloc_begin:
    code_segment dd section.code.start
    data_segment dd section.data.start
    stack_segment dd section.stack.start
    header_end:

section code align=16 vstart=0
new_init_0x70:
    push ax
    push bx
    push cx
    push dx
    push es
.w0:
    mov al,0x0a ;阻断NMI
    or al,0x80
    out 0x70,al
    in al,0x71 ;读寄存器A
    test al,0x80    ;测试第7位UIP，如果为0，测试结果为ZF=1，继续执行下面代码
    jnz .w0

    xor al,al   ;读秒
    or al,0x80
    out 0x70,al
    in al,0x71
    push ax

    mov al,2    ;读分
    or al,0x80
    out 0x70,al
    in al,0x71
    push ax

    mov al,4    ;读时
    or al,0x80
    out 0x70,al
    in al,0x71
    push ax

    mov al,0x0c ;读寄存器c，否则只发生一次中断
    out 0x70,al
    in al,0x71

    mov ax,0xb800
    mov ax,es

    pop ax
    call .bcd_to_ascii
    mov bx,12*160+36*2
    mov [es:bx],ah
    mov [es:bx+2],al
    
    mov al,':'
    mov [es:bx+4],al
    not byte [es:bx+5]

    pop ax
    call .bcd_to_ascii
    mov [es:bx+6],ah
    mov [es:bx+8],al

    mov al,':'
    mov [es:bx+10],al
    not byte [es:bx+11]
    
    pop ax

    call .bcd_to_ascii
    mov [es:bx+12],ah
    mov [es:bx+14],al

    mov al,0x20 ;向8259芯片发送中断结束命令
    out 0xa0,al ;向从片发送
    out 0x20,al ;向主片发送

    pop es
    pop dx
    pop cx
    pop bx
    pop ax

    iret
.bcd_to_ascii:
    mov ah,al
    and al,0x0f
    and al,0x30
    shr ah,4
    and ah,0x0f
    and ah,0x30
    ret
start:
    mov ax,[stack_segment]
    mov ss,ax
    mov sp,ss_pointer
    mov ax,[data_segment]
    mov ds,ax
    
    mov bx,init_msg ;显示初始信息
    call put_string 
    
    mov bx,inst_msg ;显示安装信息
    call put_string

    mov al,0x70 ;中断号 * 4 = 中断在IVT中偏移值
    mov bl,4
    mul bl
    mov bx,ax

    cli ;安装中断之前先关闭中断

    push es
    mov ax,0x0000   ;0x00000~0x003ff,共4 * 256字节，每个中断占4个字节
    mov es,ax
    mov word [es:bx],new_init_0x70
    mov word [es:bx+2],cs
    pop es

    mov al,0x0b ;通过0x70写时，如果值的最高位为1，则设置NMI阻断
    or al,0x80
    out 0x70,al
    mov al,0x12 ;允许更新周期，禁止周期性中断，禁止闹钟功能，允许更新周期中断，使用24小时制，日期、时间采用BCD码
    out 0x71,al

    mov al,0x0c
    out 0x70,al
    in al,0x71  ;读寄存器c，使之开始产生中断信号

    in al,0xa1  ;通过0xa1端口读取从片IMR寄存器的内容，用and指令清除第0位。
    and al,0xfe
    out 0xa1,al

    sti ;重新开放中断

    mov bx,done_msg ;显示安装完成信息 
    call put_string

    mov bx,tips_msg ;显示提示信息
    call put_string

    mov cx,0xb800
    mov ds,cx
    mov byte [12*160+33*2],'@'
.idle:
    hlt ;使处理器停止执行指令，并处于关机状态
    not byte [12*160+33*2+1]
    jmp .idle
put_string:
        mov cl,[bx]
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;是的，返回主程序 
         call put_char
         inc bx                          ;下一个字符 
         jmp put_string

   .exit:
         ret
    put_char:                             ;显示一个字符
            ;输入：cl=字符ascii
            push ax
            push bx
            push cx
            push dx
            push ds
            push es

            ;以下取当前光标位置
            mov dx,0x3d4
            mov al,0x0e
            out dx,al
            mov dx,0x3d5
            in al,dx                        ;高8位 
            mov ah,al

            mov dx,0x3d4
            mov al,0x0f
            out dx,al
            mov dx,0x3d5
            in al,dx                        ;低8位 
            mov bx,ax                       ;BX=代表光标位置的16位数

            cmp cl,0x0d                     ;回车符？
            jnz .put_0a                     ;不是。看看是不是换行等字符 
            mov ax,bx                       ; 
            mov bl,80                       
            div bl
            mul bl
            mov bx,ax
            jmp .set_cursor

    .put_0a:
            cmp cl,0x0a                     ;换行符？
            jnz .put_other                  ;不是，那就正常显示字符 
            add bx,80
            jmp .roll_screen

    .put_other:                             ;正常显示字符
            mov ax,0xb800
            mov es,ax
            shl bx,1
            mov [es:bx],cl

            ;以下将光标位置推进一个字符
            shr bx,1
            add bx,1

    .roll_screen:
            cmp bx,2000                     ;光标超出屏幕？滚屏
            jl .set_cursor

            mov ax,0xb800
            mov ds,ax
            mov es,ax
            cld
            mov si,0xa0
            mov di,0x00
            mov cx,1920
            rep movsw
            mov bx,3840                     ;清除屏幕最底一行
            mov cx,80
    .cls:
            mov word[es:bx],0x0720
            add bx,2
            loop .cls

            mov bx,1920

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
section data align=16 vstart=0
     init_msg       db 'Starting...',0x0d,0x0a,0
                   
    inst_msg       db 'Installing a new interrupt 70H...',0
    
    done_msg       db 'Done.',0x0d,0x0a,0

    tips_msg       db 'Clock is now working.',0
section stack align=16 vstart=0
    resb 256
    ss_pointer:
section program_trail
program_end:
