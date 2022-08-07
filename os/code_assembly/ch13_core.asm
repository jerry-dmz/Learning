core_code_seg_sel equ 0x38      ;内核代码段选择子
core_data_seg_sel equ 0x30      ;内核数据段选择子
sys_routine_seg_sel equ 0x28    ;系统公共例程代码段选择子
video_ram_seg_sel equ 0x20      ;视频显示缓冲区段选择子
core_stack_seg_sel equ 0x18     ;内核堆栈段选择子
mem_0_4_gb_seg_sel equ 0x08     ;整个0~4GB内存的段的选择子

core_length dd core_end         ;内核程序总长度00
sys_routine_seg dd  section.sys_routine.start   ;公共例程段起始位置04
core_data_seg dd section.core_data.start        ;核心数据段位置08
core_code_seg dd section.core_code.start        ;核心代码段位置0c
code_entry dd start                             ;核心代码段入口10
           dw core_code_seg_sel
[bits 32]
section sys_routine vstart=0
;-------------------------------------------------------------------------------
         ;字符串显示例程
put_string:                                 ;显示0终止的字符串并移动光标 
                                            ;输入：DS:EBX=串地址
         push ecx
  .getc:
         mov cl,[ebx]
         or cl,cl
         jz .exit
         call put_char
         inc ebx
         jmp .getc

  .exit:
         pop ecx
         retf                               ;段间返回

;-------------------------------------------------------------------------------
put_char:                                   ;在当前光标处显示一个字符,并推进
                                            ;光标。仅用于段内调用 
                                            ;输入：CL=字符ASCII码 
         pushad

         ;以下取当前光标位置
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         inc dx                             ;0x3d5
         in al,dx                           ;高字
         mov ah,al

         dec dx                             ;0x3d4
         mov al,0x0f
         out dx,al
         inc dx                             ;0x3d5
         in al,dx                           ;低字
         mov bx,ax                          ;BX=代表光标位置的16位数

         cmp cl,0x0d                        ;回车符？
         jnz .put_0a
         mov ax,bx
         mov bl,80
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

  .put_0a:
         cmp cl,0x0a                        ;换行符？
         jnz .put_other
         add bx,80
         jmp .roll_screen

  .put_other:                               ;正常显示字符
         push es
         mov eax,video_ram_seg_sel          ;0xb8000段的选择子
         mov es,eax
         shl bx,1
         mov [es:bx],cl
         pop es

         ;以下将光标位置推进一个字符
         shr bx,1
         inc bx

  .roll_screen:
         cmp bx,2000                        ;光标超出屏幕？滚屏
         jl .set_cursor

         push ds
         push es
         mov eax,video_ram_seg_sel
         mov ds,eax
         mov es,eax
         cld
         mov esi,0xa0                       ;小心！32位模式下movsb/w/d 
         mov edi,0x00                       ;使用的是esi/edi/ecx 
         mov ecx,1920
         rep movsd
         mov bx,3840                        ;清除屏幕最底一行
         mov ecx,80                         ;32位程序应该使用ECX
  .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

         pop es
         pop ds

         mov bx,1920

  .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         inc dx                             ;0x3d5
         mov al,bh
         out dx,al
         dec dx                             ;0x3d4
         mov al,0x0f
         out dx,al
         inc dx                             ;0x3d5
         mov al,bl
         out dx,al

         popad
         ret                                

;-------------------------------------------------------------------------------
read_hard_disk_0:                           ;从硬盘读取一个逻辑扇区
                                            ;EAX=逻辑扇区号
                                            ;DS:EBX=目标缓冲区地址
                                            ;返回：EBX=EBX+512
         push eax 
         push ecx
         push edx
      
         push eax
         
         mov dx,0x1f2
         mov al,1
         out dx,al                          ;读取的扇区数

         inc dx                             ;0x1f3
         pop eax
         out dx,al                          ;LBA地址7~0

         inc dx                             ;0x1f4
         mov cl,8
         shr eax,cl
         out dx,al                          ;LBA地址15~8

         inc dx                             ;0x1f5
         shr eax,cl
         out dx,al                          ;LBA地址23~16

         inc dx                             ;0x1f6
         shr eax,cl
         or al,0xe0                         ;第一硬盘  LBA地址27~24
         out dx,al

         inc dx                             ;0x1f7
         mov al,0x20                        ;读命令
         out dx,al

  .waits:
         in al,dx
         and al,0x88
         cmp al,0x08
         jnz .waits                         ;不忙，且硬盘已准备好数据传输 

         mov ecx,256                        ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx
         mov [ebx],ax
         add ebx,2
         loop .readw

         pop edx
         pop ecx
         pop eax
      
         retf                               ;段间返回 

;-------------------------------------------------------------------------------
;汇编语言程序是极难一次成功，而且调试非常困难。这个例程可以提供帮助 
put_hex_dword:                              ;在当前光标处以十六进制形式显示
                                            ;一个双字并推进光标 
                                            ;输入：EDX=要转换并显示的数字
                                            ;输出：无
         pushad
         push ds
      
         mov ax,core_data_seg_sel           ;切换到核心数据段 
         mov ds,ax
      
         mov ebx,bin_hex                    ;指向核心数据段内的转换表
         mov ecx,8
  .xlt:    
         rol edx,4
         mov eax,edx
         and eax,0x0000000f
         xlat
      
         push ecx
         mov cl,al                           
         call put_char
         pop ecx
       
         loop .xlt
      
         pop ds
         popad
         retf
      
;-------------------------------------------------------------------------------
allocate_memory:                            ;分配内存
                                            ;输入：ECX=希望分配的字节数
                                            ;输出：ECX=起始线性地址 
         push ds
         push eax
         push ebx
      
         mov eax,core_data_seg_sel
         mov ds,eax
      
         mov eax,[ram_alloc]
         add eax,ecx                        ;下一次分配时的起始地址
      
         ;这里应当有检测可用内存数量的指令
          
         mov ecx,[ram_alloc]                ;返回分配的起始地址

         mov ebx,eax
         and ebx,0xfffffffc
         add ebx,4                          ;强制对齐 
         test eax,0x00000003                ;下次分配的起始地址最好是4字节对齐
         cmovnz eax,ebx                     ;如果没有对齐，则强制对齐 
         mov [ram_alloc],eax                ;下次从该地址分配内存
                                            ;cmovcc指令可以避免控制转移 
         pop ebx
         pop eax
         pop ds

         retf

;-------------------------------------------------------------------------------
set_up_gdt_descriptor:                      ;在GDT内安装一个新的描述符
                                            ;输入：EDX:EAX=描述符 
                                            ;输出：CX=描述符的选择子
         push eax
         push ebx
         push edx
      
         push ds
         push es
      
         mov ebx,core_data_seg_sel          ;切换到核心数据段
         mov ds,ebx

         ;将GDT寄存器的基地址和边界信息保存到pgdt这个内存位置
         sgdt [pgdt]                        ;以便开始处理GDT

         mov ebx,mem_0_4_gb_seg_sel
         mov es,ebx

         movzx ebx,word [pgdt]              ;GDT界限 
         inc bx                             ;GDT总字节数，也是下一个描述符偏移 
         add ebx,[pgdt+2]                   ;下一个描述符的线性地址 
      
         mov [es:ebx],eax                   ;安装传入的描述符
         mov [es:ebx+4],edx
      
         add word [pgdt],8                  ;[pgdt]位置是大小，因此这里就是增加一个描述符的大小   
      
         lgdt [pgdt]                        ;对GDT的更改生效 
       
         mov ax,[pgdt]                      ;得到GDT界限值
         xor dx,dx
         mov bx,8
         div bx                             ;除以8，去掉余数
         mov cx,ax                          
         shl cx,3                           ;将索引号移到正确位置 

         pop es
         pop ds

         pop edx
         pop ebx
         pop eax
      
         retf 
;-------------------------------------------------------------------------------
make_seg_descriptor:                        ;构造存储器和系统的段描述符
         mov edx,eax
         shl eax,16
         or ax,bx                           ;描述符前32位(EAX)构造完毕

         and edx,0xffff0000                 ;清除基地址中无关的位
         rol edx,8
         bswap edx                          ;装配基址的31~24和23~16  (80486+)

         xor bx,bx
         or edx,ebx                         ;装配段界限的高4位

         or edx,ecx                         ;装配属性

         retf

;===============================================================================

section core_data vstart=0  ;系统核心数据段
    pgdt        dw 0
                dd 0
    ram_alloc   dd 0x00100000

    ;对外提供的例程，类似中断
    salt:
    salt1       dd '@PrintString'
                times 256-($-salt1) db 0
                dd put_string
                dd sys_routine_seg_sel
    salt2       dd '@ReadDiskData'
                times 256-($-salt2) db 0
                dd read_hard_disk_0
                dd sys_routine_seg_sel
    salt3       dd '@PutDwordAsHexString'
                times 256-($-salt3) db 0
                dd put_hex_dword
                dd sys_routine_seg_sel
    salt4       dd '@TerminateProgram'
                times 256-($-salt4) db 0
                dd return_point
                dd core_code_seg_sel
    salt_item_len equ $-salt4
    salt_items equ ($-salt)/salt_item_len

    message_1        db  '  If you seen this message,that means we '
                          db  'are now in protect mode,and the system '
                          db  'core is loaded,and the video display '
                          db  'routine works perfectly.',0x0d,0x0a,0

    message_5        db  '  Loading user program...',0
         
    do_status        db  'Done.',0x0d,0x0a,0
         
    message_6        db  0x0d,0x0a,0x0d,0x0a,0x0d,0x0a
                          db  '  User program terminated,control returned.',0

    bin_hex          db '0123456789ABCDEF'
    
    core_buf times 2048 db 0    ;内核用到的缓冲区
    esp_pointer dd 0            ;内核用来临时保存自己的栈指针
    cpu_brand0  dd 0x0d,0x0a,'  ',0
    cpu_brand   times 52 db 0
    cpu_brnd1   db 0x0d,0x0a,0x0d,0x0a,0

section core_code vstart=0
load_relocate_program:
    TODO:
start:
    mov ecx,core_data_seg_sel       ;ds指向核心数据段
    mov ds,ecx
    mov ebx,message_1
    call sys_routine_seg_sel:put_string

    ;显示处理器品牌信息
    mov eax,0x80000002
    cpuid
    mov [cpu_brand+0x00],eax
    mov [cpu_brand+0x40],ebx
    mov [cpu_brand+0x08],ecx
    mov [cpu_brand+0x0c],edx

    mov eax,0x80000003
    cpuid
    mov [cpu_brand+0x10],eax
    mov [cpu_brand+0x14],ebx
    mov [cpu_brand+0x18],ecx
    mov [cpu_brand+0x1c],edx

    mov eax,0x80000004
    cpuid
    mov [cpu_brand+0x20],eax
    mov [cpu_brand+0x24],ebx
    mov [cpu_brand+0x28],ecx
    mov [cpu_brand+0x2c],edx

    mov ebx,cpu_brnd0
    call sys_routine_seg_sel:put_string
    mov ebx,cpu_brand
    call sys_routine_seg_sel:put_string
    mov ebx,cpu_brnd1
    call sys_routine_seg_sel:put_string

    mov ebx,message_5
    call sys_routine_seg_sel:put_string
    mov esi,50      ;用户程序位于逻辑50扇区
    call load_relocate_program

    mov ebx,do_status
    call sys_routine_seg_sel:put_string
    mov [esp_pointer],esp   ;临时保存堆栈指针
    mov ds,ax   ;TODO:这是什么意思，ax此时应该为0004？
    ;此时的代码段选择子已经是核心代码段选择子，在mbr跳到start时就已经装载
    jmp far [0x10]