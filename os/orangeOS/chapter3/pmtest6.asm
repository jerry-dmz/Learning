;--------------------
; 测试分页
; 探查内存分布并显示
;--------------------

%include "pm.inc"

PageDirBase   equ 200000h ; 页目录开始地址 2M
PageTableBase equ 201000h ; 页表开始地址 2M + 4K

org 0100h
    xchg bx, bx
    jmp  begin

;gdt
    desc_null: Descriptor 0, 0, 0
    desc_normal: Descriptor 0, 0ffffh,DA_DRW
    desc_page_dir: Descriptor PageDirBase, 4095, DA_DRW
    desc_page_table: Descriptor PageTableBase, 1023, DA_DRW|DA_LIMIT_4K
    desc_code32: Descriptor 0, code32Len - 1,DA_C + DA_32
    desc_data:Descriptor 0,dataLen-1, DA_DRW
    desc_stack:Descriptor 0, stackLen, DA_DRWA + DA_32
    desc_video: Descriptor 0b8000h, 0ffffh, DA_DRW
;gdt

gdtLen equ $ - desc_null
gdtPtr dw  gdtLen - 1
       dd 0

;段选择子
    normalSelector    equ desc_normal-desc_null
    pageDirSelector   equ desc_page_dir-desc_null
    pageTableSelector equ desc_page_table-desc_null
    code32Selector    equ desc_code32-desc_null
    dataSelector      equ desc_data-desc_null
    stackSelector     equ desc_stack-desc_null
    videoSelector     equ desc_video-desc_null
;段选择子

;数据段
    align 32
    [bits 32]
    data:
        _szPMMessage:       db "In Protect Mode now. ^-^", 0Ah, 0Ah, 0                   ; 进入保护模式后显示此字符串
        _szMemChkTitle:     db "BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0 ; 进入保护模式后显示此字符串
        _szRAMSize          db "RAM size:", 0
        _szReturn           db 0Ah, 0
        ; 变量
        _wSPValueInRealMode dw 0
        _dwMCRNumber:       dd 0                                                         ; Memory Check Result
        _dwDispPos:         dd (80 * 14 + 0) * 2                                         ; 屏幕第 6 行, 第 0 列。
        _dwMemSize:         dd 0
        _ARDStruct: ; Address Range Descriptor Structure
            _dwBaseAddrLow:  dd 0
            _dwBaseAddrHigh: dd 0
            _dwLengthLow:    dd 0
            _dwLengthHigh:   dd 0
            _dwType:         dd 0
        
        _MemChkBuf: times 256 db 0 ;内存描述信息缓冲区
        
        ; 保护模式下使用这些符号
        szPMMessage   equ _szPMMessage	- data
        szMemChkTitle equ _szMemChkTitle	- data
        szRAMSize     equ _szRAMSize	- data
        szReturn      equ _szReturn	- data
        dwDispPos     equ _dwDispPos	- data
        dwMemSize     equ _dwMemSize	- data
        dwMCRNumber   equ _dwMCRNumber	- data
        ARDStruct     equ _ARDStruct	- data
            dwBaseAddrLow  equ _dwBaseAddrLow	- data
            dwBaseAddrHigh equ _dwBaseAddrHigh	- data
            dwLengthLow    equ _dwLengthLow	- data
            dwLengthHigh   equ _dwLengthHigh	- data
            dwType         equ _dwType		- data
        MemChkBuf equ _MemChkBuf	- data

    dataLen equ $-data
; 数据段

;栈段
    align 32
    [bits 32]
    stack:
        times 512 db 0
    stackLen equ $-stack-1
;栈段

;实模式初始化代码
[bits 16]
begin:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0100h ;长度为512，正好是堆栈段的长度

    mov ebx, 0          ; 第一次、最后一次为0，其余都不为0（BIOS中断处理使用）
    mov di,  _MemChkBuf ;es:di指向一个地址范围描述符结构（ARDS）结构，BIOS存放结果
    get:
        mov eax, 0E820h          ;获取内存的功能号
        mov ecx, 20              ; es:di指向地址范围描述符结构大小，以字节为单位。
        mov edx, 0534D4150h      ;'SMAP'，使用此标志对调用者要请求的系统映像信息进行校验。
        ; 中断结果，CF=0表示没有错误；
        int 15h
        jc  fail
        add di,  20
        inc dword [_dwMCRNumber]
        cmp ebx, 0
        jne get
        jmp ok
    fail:
            mov dword [_dwMCRNumber], 0
    ok:    
    ;初始化描述符
    xor eax,                  eax
    mov ax,                   cs
    shl eax,                  4
    add eax,                  seg_code32
    mov word [desc_code32+2], ax
    shr eax,                  16
    mov byte [desc_code32+4], al
    mov byte [desc_code32+7], ah

    xor eax,                eax
    mov ax,                 ds
    shl eax,                4
    add eax,                data
    mov word [desc_data+2], ax
    shr eax,                16
    mov byte [desc_data+4], al
    mov byte [desc_data+7], ah

    xor eax,                 eax
    mov ax,                  ds
    shl eax,                 4
    add eax,                 stack
    mov word [desc_stack+2], ax
    shr eax,                 16
    mov byte [desc_stack+4], al
    mov byte [desc_stack+7], ah

    xor eax,              eax
    mov ax,               ds
    shl eax,              4
    add eax,              desc_null
    mov dword [gdtPtr+2], eax

    lgdt [gdtPtr]

    cli

    in   al,  92h
    or   al,  00000010b
    out  92h, al
    mov  eax, cr0
    or   eax, 1
    mov  cr0, eax
    xchg bx,  bx
    jmp  dword code32Selector:0

;实模式初始化代码

;32位代码段
[bits 32]
seg_code32:
    xchg bx,  bx
    xchg bx,  bx
    mov  ax,  dataSelector
    mov  ds,  ax
    mov ax,videoSelector,
    mov  gs,  ax
    mov  ax,  stackSelector
    mov  ss,  ax
    mov  esp, stackLen

    push szPMMessage
    call DisplayString
    add  esp, 4

    push szMemChkTitle
    call DisplayString
    add  esp, 4

    call DispMemSize
    call SetupPaging
    jmp  $

DispMemSize:
    push esi
    push edi
    push ecx

    mov esi, MemChkBuf
    mov ecx, [dwMCRNumber]

    .loop:
        mov edx, 5
        mov edi, ARDStruct
    .continue_outer:
        push dword [esi]
        call DisplayInt
        pop  eax                             ; 这行和下行是为了给ARDStruct赋值
        stosd
        add  esi,            4
        dec  edx
        cmp  edx,            0
        jnz  .continue_outer
        call DisplayReturn
        cmp  dword [dwType], 1
        jne  .continue_inner
        mov  eax,            [dwBaseAddrLow] ; TODO:为什么只加低32位？
        add  eax,            [dwLengthLow]
        cmp  eax,            [dwMemSize]
        jb   .continue_inner
        mov  [dwMemSize],    eax
    .continue_inner:
        loop .loop
        call DisplayReturn
        push szRAMSize
        call DisplayString
        add  esp, 4

        push dword [dwMemSize]
        call DisplayInt
        add  esp, 4

        pop ecx
        pop edi
        pop esi
        ret

SetupPaging:
    xor  edx, edx
    mov  eax, [dwMemSize]
    mov  ebx, 400000h     ; 4M
    div  ebx              ; 计算页目录item数，一个对应4M
    mov  ecx, eax
    test edx, edx
    jz   .no_remain
    inc  eax
.no_remain:
    push ecx
    mov  ax,  pageDirSelector
    mov  es,  ax
    xor  edi, edi
    xor  eax, eax
    mov  eax, PageTableBase | PG_P | PG_USU | PG_RWW
.1:
    stosd
    add  eax, 4096
    loop .1

    mov ax,  pageTableSelector
    mov es,  ax
    pop eax
    mov ebx, 1024                   ; 一个页面可以表示4M内存，一页4K，得出页数
    mul ebx
    mov ecx, eax
    xor edi, edi
    xor eax, eax
    mov eax, PG_P | PG_USU | PG_RWW
.2:
    stosd
    add  eax, 4096
    loop .2

    mov eax, PageDirBase
    mov cr3, eax
    mov eax, cr0
    or  eax, 80000000h
    mov cr0, eax
    jmp short .3
.3:
    nop

    ret
    

%include "lib.inc"

code32Len equ $-seg_code32
;32位代码段