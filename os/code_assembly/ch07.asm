jmp near start

message db '1+2+3+...+100='

start:
        mov ax,0x7c00
        mov ds,ax
        mov ax,0xb800
        mov es,ax

        mov si,message
        mov di,0
        mov cs,startd,start-message
@g:
        ;将message定义的字符串移动到显示缓冲区
        mov al,[si]
        mov [es:di],al
        inc di
        mov byte [es:di],0x07
        inc di
        inc si
        loop @g
        xor ax,ax
        mov cx,1
@f:
        ;计算1到100的累加和，存储到ax中
        add ax,cx
        inc cx
        cmp cx,100
        jle @f

        xor cx,cx
        mov ss,cx
        mov sp,cx

        mov bx,10
        xor cx,cx
@d:
        ;32除法，得出ax各个位数，兵器其存储到堆栈中
        inc cx
        xor dx,dx
        div bx
        ;余数必定小于10，高四位必定为0，相当与用or指令做加法
        or dl,0x30
        push dx
        cmp ax,0
        jne @d
@a:
        ;去除堆栈中的数，将其推倒显示器缓区，@d中cx的值没有清空，正好可以让下面指令的loop使用
        pop dx
        mov [es:di],dl
        inc di
        mov byte [es:di],0x07
        inc di
        loop @a
        jmp near $

times 510-($-$$) db 0
db 0x55,0xaa