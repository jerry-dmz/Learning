    core_base_address equ 0x00040000    ;内核起始内存地址
    core_start_sector equ 0x00000001    ;内核起始逻辑扇区号

    mov ax,cs
    mov ss,ax
    mov sp,0x7c00

    mov eax,[cs:pgdt+0x7c00+0x02]   ;GDT表的32位物理地址，用eax隐含的指定了取4个字节
    xor edx,edx                     ;TODO:为什么用xor来清零，它更快些吗？
    mov ebx,16
    div ebx

    mov ds,eax                      ;商为段地址
    mov ebx,edx                     ;余数为段内起始偏移地址


    ;#初始代码段描述符，数据段，对应0~4GB的线性地址空间
    mov dword [ebx+0x08],0x0000ffff ;基地址为0,界限0xffff
    mov dword [ebx+0x0c],0x00cf9200 ;粒度为4KB,(0xffff-1)*0x1000-1 = 4GB

    ;#初始化代码段段描述符
    mov dword [ebx+0x10],0x7c0001ff
    mov dword [ebx+0x14],0x00409800

    ;初始堆栈段描述符
    mov dword [ebx+0x18],0x7c00fffe ;TODO:为什么这么设置，这个问题很关键？？？
    mov dword [ebx+0x1c],0x00cf9600

    ;显示缓冲区描述符
    mov dword [ebx+0x20],0x800007ff
    mov dword [ebx+0x24],0x0040920b

    mov word [cs:pgdt+0x7c00],39    ;GDT表界限

    lgdt [cs:pgdt+0x7c00]           ;加载GDT到GDTR

    in al,0x92                      ;打开A20
    or al,0000_0010B
    out 0x92,al

    cli                             ;关中断

    mov eax,cr0
    or eax,1
    mov cr0,eax                     ;设置PE位

    jmp dword 0x0010:flush          ;清空流水线并串行化处理器

    [bits 32]
;加载内核程序到固定的位置，初始化数据段段和堆栈（代码段在跳转时就已经加载）
flush:
        mov eax,0x0008
        mov ds,eax

        mov eax,0x0018
        mov ss,eax
        xor esp,ebp

        mov edi,core_base_address
        mov eax,core_start_sector
        mov ebx,edi
        call read_hard_disk_0   ;从core_start_sector读取一个扇区，内容送到core_base_address开头的地方

        mov eax,[edi]   ;第一个扇区的4个字节存放了要读取的程序的大小，因此做除法得到扇区数
        xor edx,edx
        mov ecx,512
        div ecx
        or edx,edx  ;余数不为0，代表有不足512字节的内容需要存放，要考虑eax小于0（程序字节数小于512的情况）
        jnz @1  
        dec eax
    @1:
        or eax,eax  ;与67行对应
        jz setup

        mov ecx,eax ;将扇区数传递到ecx，作为loop的循环次数
        mov eax,core_start_sector 
        inc eax 
    @2:
        call read_hard_disk_0
        inc eax
        loop @2
    ;行到此处时，就从硬盘中将程序内容全部加载到core_base_address开始的位置了

setup:
    mov esi,[0x7c00+pgdt+0x02]  ;不可以通过代码段描述符读pgdt，但可以通过4GB的数据段访问
    
    ;建立公共例程段描述符，edi为内核加载的地址，而内核前面几位定义了各个段的起始地址
    mov eax,[edi+0x04]  ;公用例程代码段起始地址
    mov ebx,[edi+0x08]  ;核心数据段汇编地址
    sub ebx,eax         
    dec ebx             ;得公共例程段界限,因为从0开始计数
    add eax,edi         ;edi为内核加载地址，结果为公共例程段的基地址
    mov ecx,0x00409800  ;字节粒度的数据段描述符 0x0000_0000_0100_0000_0101_0100_0000_0000   段基址_GBL(AVL)_段界限_P(DPL)S_段基值
    call make_gdt_descriptor
    ;构造完段描述符之后，将其写道gdt，因为之前构造了6个，所以从28开始
    mov [esi+0x28],eax
    mov [esi+0x2c],edx

    ;构造核心数据段描述符
    mov eax,[edi+0x08]
    mov ebx,[edi+0x0c]
    sub ebx,eax
    dec ebx
    add eax,edi
    mov ecx,0x00409200  ;字节粒度的描述符
    call make_gdt_descriptor
    mov [esi+0x30],eax
    mov [esi+0x34],edx

    ;构造核心代码段描述符
    mov eax,[edi+0x0c]
    mov ebx,[edi+0x00]  ;程序总长度 - 代码段地址，即为最后一个段的界限
    sub ebx,eax
    dec ebx
    add eax,edi
    mov ecx,0x00409800
    call make_gdt_descriptor
    mov [esi+0x38],eax
    mov [esi+0x3c],edx

    mov word [0x7c00+pgdt],63
    lgdt [0x7c00+pgdt]

    ;edi+0x10是code_entry的位置。
    jmp far [edi+0x10]




;从硬盘读取一个逻辑扇区
;eax-逻辑扇区号
;ds:ebx=目标缓冲地址
;返回ebx=ebx+512,实模式下一个段最大64KB，程序装不下，所以每加载一个扇区，就将ds的值增加512字节，保证程序能全部加载进来
read_hard_disk_0:
    push eax
    push ecx
    push edx
    
    push eax

    mov dx,0x1f2    
    mov al,1
    out dx,al

    inc dx  ;0x1f3  LBA7~0
    pop eax
    out dx,al

    inc dx  ;0x1f4 LBA15~8
    mov cl,8
    shr eax,cl
    out dx,al

    inc dx  ;0x1f5 LBA23~16
    shr eax,cl
    out dx,al

    inc dx  ;0x1f6 LBA27~24
    shr eax,cl
    or al,0xe0 ;主盘
    out dx,al

    inc dx  ;0x1f7 读命令
    mov al,0x20
    out dx,al

    .waits
        in al,dx
        and al,0x88
        cmp al,0x08
        jnz .waits
        mov ecx,256
        mov dx,0x1f0
    .readw:
    in ax,dx
    mov [ebx],ax
    add ebx,2
    loop .readw

    pop edx
    pop ecx
    pop eax

    ret

;TODO:待解读，此处构造段描述符的逻辑还需解读
;构造描述符
;输入:eax=线性基地址 ebx=段界限 ecx=属性
;返回edx:eax 完整的描述符
make_gdt_descriptor:
    mov edx,eax
    shl eax 16  ;左移16位，将段基地址的低16位构造好
    or ax,bx    ;通过移位，然后或来组合eax的低16和ebx的第16位

    and edx ,0xffff0000 ;清除及地址中无关的位，清空基地址的低16位，前面步骤已经构造好
    rol edx,8           ;循环左移，使高32位基地址就位
    bswap edx           ;装配基地址的31~24和23~16位
    xor bx,bx           ;将ebx的低16清0
    or edx,ebx          ;装配段界限的高4位
    or edx,ecx          ;装配属性

    ret

pgdt dw 0
     dd 0x00007e00  ;GDT的物理地址
times 510-($-$$) db 0
                 db 0x55,0xaa





