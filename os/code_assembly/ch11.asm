mov ax,cs
mov ss,ax
mov sp,0x7c00

;intel处理器为低端字节序(小端法，地址低处存储实际低位字节)
mov ax,[cs:gdt_base+0x7c00] ;读取gdt_base的低2个字字节（数的低位字节）
mov dx,[cs:gdt_base+0x7c00+0x02]    ;数的高位字节
mov bx,16
div bx  ;[dx:ax] /bx 得到在实模式下使用的实际段地址 + 偏移地址
mov ds,ax
mov bx,dx

;创建0#描述符，处理器要求
mov dword [bx+0x00],0x00
mov dword [bx+0x04],0x00

;保护模式下代码段描述符
mov dword [bx+0x08],0x7c0001ff ;低32位，16位段基址 + 16位段界限
mov dword [bx+0x0c],0x00409800 ;高32位，8 + （4+4）+ (4+4) + 8     0000_0000_0100_0000_1001_1000_0000_0000

;保护模式下数据段描述符,段基值0xb800
mov dword [bx+0x10],0x8000ffff
mov dword [bx+0x14],0x0040920b

;保护模式下堆栈描述符
mov dword [bx+0x18],0x00007a00
mov dword [bx+0x1c],0x00409600

;因为有4个描述符，所以是32字节
mov word [cs:gdt_size+0x7c00],31
;将段基址和段界限加载到GDTR
lgdt [cs:gdt_size+0x7c00]

;通过将0x92端口第一位置为0打开A20地址线
in al,0x92
or al,0000_0010B
out 0x92,al
cli ;之前安装的中断不能在使用，关闭中断
mov eax,cr0 ;设置cr0，允许保护模式
or eax,1
mov cr0,eax

;保护模式下，传送到段选择器的是段选择子，
jmp dword 0x0008:flush

[bits 32]
flush:
    mov cx,00000000000_10_000B
    mov ds,cx
    ;以下在屏幕上显示"Protect mode OK." 
    mov byte [0x00],'P'  
    mov byte [0x02],'r'
    mov byte [0x04],'o'
    mov byte [0x06],'t'
    mov byte [0x08],'e'
    mov byte [0x0a],'c'
    mov byte [0x0c],'t'
    mov byte [0x0e],' '
    mov byte [0x10],'m'
    mov byte [0x12],'o'
    mov byte [0x14],'d'
    mov byte [0x16],'e'
    mov byte [0x18],' '
    mov byte [0x1a],'O'
    mov byte [0x1c],'K'

    mov cx,00000000000_11_000B         ;加载堆栈段选择子
    mov ss,cx
    mov esp,0x7c00
    mov ebp,esp                        ;保存堆栈指针 
    push byte '.'                      ;压入立即数（字节）
     
    sub ebp,4
    cmp ebp,esp                        ;判断压入立即数时，ESP是否减4 
    jnz ghalt                          
    pop eax
    mov [0x1e],al                      ;显示句点 

ghalt:
    hlt
gdt_size dw 0
gdt_base dd 0x00007e00
times 510-($-$$) db 0
                 db 0x55,0xaa
                 ;此处用db用成了dd，导致多了6个字节