org 0x7c00
BaseOfStack equ 0x7c00
;Loader程序起始物理地址
BaseOfLoader equ 0x1000
OffsetOfLoader equ 0x00
;(224 * 32 + 512 -1)/512
RootDirSectors equ 14
SectorNumOfRootDirStart equ 19
SectorNumOfFAT1Start equ 1
;TODO:
SectorBalance equ 17
    jmp short Label_Start
    nop
    BS_OEMName db 'MineBoot'
    BPB_BytesPerSec dw 512
    BPB_SecPerClus db 1
    BPB_RsvdSecCnt dw 1
    BPB_NumFATS db 2
    BPB_RootEntCnt dw 224
    BPB_TotSec16 dw 2880
    BPB_Media db 0xf0
    BPB_FATSz16 dw 9
    BPB_SecPerTrk dw 18
    BPB_NumHeads dw 2
    BPB_hiddSec dd 0
    BPB_TolSec32 dd 0
    BS_DrvNum db 0
    BS_Reserved1 db 0
    BS_BootSig  db  29h
    BS_VolID dd 0
    BS_VolLab dd 'boot loader'
    BS_FileSysType db 'FAT12    '
Label_Start:
    mov ax,cs
    mov dx,ax
    mov es,ax
    mov ss,ax
    mov sp,BaseOfStack
;====== clear screen
mov ax,0600h
mov bx,0700h
mov cx,0
mov dx,0184fh
int 10h
;====== set focus
mov ax,0200h
mov bx,0000h
mov dx,0000h
int 10h
;====== display on screen:Start Booting
mov ax,1301h
mov bx,000fh
mov dx,0000h
mov cx,10
push ax
mov ax,ds
mov es,ax
pop ax
mov bp,StartBootMessage
int 10h
;====== reset floppy
xor ah,ah
xor dl,dl
int 13h
;======从根目录中搜索引导loader.bin
    ;根目录起始扇区（19，其前有引导区、fat表）
    mov word [SectorNo],SectorNumOfRootDirStart
Label_Search_In_Root_Dir_Begin:
    cmp word [RootDirSizeForLoop],0
    jz Label_No_LoaderBin
    dec word [RootDirSizeForLoop]
    mov ax,00h
    mov es,ax
    ;es:bx装载有扇区数据
    mov bx,8000h
    mov ax,[SectorNo]
    mov cl,1
    call Func_ReadOneSector
    ;读取一个扇区内容到es:bx(0x08000h)
    mov si,LoaderFileName
    mov di,8000h
    ;操作方向标志DF，std，用于串操作指令中
    cld
    ;dx记录一个扇区可容纳的目录-512/32=16个目录
    mov dx,10h
Label_Search_For_LoaderBin:
    cmp dx,0
    jz Label_Goto_Next_Sector_In_Root_Dir
    dec dx
    mov cx,11
Label_Cmp_FileName:
    cmp cx,0
    jz Label_FileName_Found
    dec cx
    ;lodsb将si++，并将8字节数据放到al
    lodsb
    cmp al,byte [es:di]
    jz Label_Go_On
    jmp Label_Different
;字符匹配，则跳到下一个字符的匹配过程
Label_Go_On:
    inc di
    jmp Label_Cmp_FileName
;跳到下一个一个目录项
Label_Different:
    ;and di 1111 1111 1110 0000
    ;di从8000（1000 0000 0000 0000）开始，最大值为0200（0000 0010 0000 0000）
    ;因为每次都是递增32，只是比较过程中lodsb逐渐di的值     
    ;TODO:换成ffe0h就不行
    and di,0ffe0h
    add di,0020h
    mov si,LoaderFileName
    jmp Label_Search_For_LoaderBin
;跳到下一个扇区
Label_Goto_Next_Sector_In_Root_Dir:
    add word [SectorNo],1
    jmp Label_Search_In_Root_Dir_Begin
;======display on screen  ERROR:NO LOADER Found
;借助bios的int10h中断，13号功能。显示字符串。
;es:bp-串地址
;cx-串长度
;dh,dl-起始行、列
;bh-页号
;al=0,bl=属性串
;al=1,bl=属性串
;TODO：
Label_No_LoaderBin:
    mov ax,1301h
    mov bx,008ch
    mov dx,0100h
    mov cx,21
    push ax
    mov ax,ds
    mov es,ax
    pop ax
    mov bp,NoLoaderMessage
    int 10h
    jmp $
;found loader.bin name in root director struct
Label_FileName_Found:
    mov ax,RootDirSectors
    and di,0ffe0h
    add di,001ah
    mov cx,word [es:di]
    push cx
    add cx,ax
    add cx,SectorBalance
    mov ax,BaseOfLoader
    mov es,ax
    mov bx,OffsetOfLoader
    mov ax,cx
Label_Go_On_Loading_File:
    push ax
    push bx
    mov ah,0eh
    mov al,'.'
    mov bl,0fh
    int 10h
    pop bx
    pop ax
    mov cl,1
    call Func_ReadOneSector
    pop ax
    call Func_GetFATEntry
    cmp ax,0fffh
    jz Label_File_Loaded
    push ax
    mov dx,RootDirSectors
    add ax,dx
    add ax,SectorBalance
    add bx,[BPB_BytesPerSec]
    jmp Label_Go_On_Loading_File
Label_File_Loaded:
    jmp BaseOfLoader:OffsetOfLoader


;======read one sector from floppy
;al-读入扇区数
;ch-磁道号
;cl-扇区号
;dh-磁头号
;dl-驱动器号
;es:bx-数据缓冲区
;接受参数：
;   ax-待读取的磁盘起始扇区号
;   cl-读取的扇区数量    
;   es:bx-数据读取到此缓存区
Func_ReadOneSector:
    push bp
    mov bp,sp
    ;esp=esp-2
    sub esp,2
    mov byte [bp-2],cl
    push bx
    ;bx=每磁道扇区数
    mov bl,[BPB_SecPerTrk]
    ;规则：
    ;   除数，8位和16位，在一个寄存器或内存单元
    ;   除数为8位，被除数为16位，默认在ax存放
    ;   除数为16位，被除数为32位，在dx和ax中存放
    ;结果：
    ;   除数为8位，al存储商，ah存储余数
    ;   除数为16位，ax存储商，dx存储余数
    div bl
    ;al = ax / bl = 读取扇区数 / 每磁道扇区数
    ;ah存储余数，代表哪个磁道哪个扇区
    inc ah
    mov cl,ah
    mov dh,al
    ;al存储商，为磁道号
    shr al,1
    mov ch,al
    and dh,1
    pop bx
    ;TODO:int13h的驱动器号
    mov dl,[BS_DrvNum]
Label_Go_On_reading:
    mov ah,2
    mov al,byte [bp-2]
    int 13h
    ;此BIOS中断读完后会将CF置0
    jc Label_Go_On_reading
    add esp,2
    pop bp
    ret
;FAT12文件系统每个表项占用12bit
;AH=FAT表项号
Func_GetFATEntry:
    push es
    push bx
    push ax
    mov ax,00
    mov es,ax
    pop ax
    ;每个表项12字节，1.5B
    ;表项的起始扇区
    mov byte [Odd],0
    mov bx,3
    mul bx
    mov bx,2
    div bx
    cmp dx,0
    jz Label_Even
    mov byte [Odd],1
Label_Even:
    ;异或清零
    ;16位除法:
    ;   1.除数:由通用寄存器或内存单元提供
    ;   2.被除数:低16位ax，高16位dx
    ;   3.余数dx，商ax中
    ;dx-ax 除 bx = ax-dx（dx-ax是地址，除后商ax第几个扇区，余数dx下个扇区字节）
    ;
    xor dx,dx
    mov bx,[BPB_BytesPerSec]
    div bx
    push dx
    mov bx,8000h
    ;从FAT表第一项开始遍历，一次读取两个扇区
    add ax,SectorNumOfFAT1Start
    mov cl,2
    ;al-读入扇区数
    ;ch-磁道号
    ;cl-扇区号
    ;dh-磁头号
    ;dl-驱动器号
    ;es:bx-数据缓冲区
    ;接受参数：
    ;   ax-待读取的磁盘起始扇区号
    ;   cl-读取的扇区数量    
    ;   es:bx-数据读取到此缓存区
    call Func_ReadOneSector
    ;TODO:这一段代码待思考
    pop dx
    add bx,dx
    mov ax,[es:bx]
    cmp byte [Odd],1
    jnz Label_Even_2
    shr ax,4
Label_Even_2:
    and ax,0fffh
    pop bx
    pop es
    ret
;======temp varaiable
RootDirSizeForLoop dw RootDirSectors
SectorNo    dw 0
Odd db 0
;======display messages
StartBootMessage:   db  "Start Boot"
NoLoaderMessage:    db  "ERROR:No LOADER Found"
LoaderFileName:     db  "Loader.bin",0