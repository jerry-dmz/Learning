; 从fat12文件读取文件并加载到特定内容

org 07c00h
BaseOfStack    equ 07c00h
BaseOfLoader   equ 09000h
OffsetOfLoader equ 0100h
RootDirSectors equ 14     ; 根目录占用扇区数 224 * 32 / 512
SectorNoOfFAT1 equ 1
DeltaSectorNo  equ 17

    jmp short start
    nop

	BS_OEMName     DB 'ForrestY'    ; OEM String, 必须 8 个字节
	BPB_BytsPerSec DW 512           ; 每扇区字节数
	BPB_SecPerClus DB 1             ; 每簇多少扇区
	BPB_RsvdSecCnt DW 1             ; Boot 记录占用多少扇区
	BPB_NumFATs    DB 2             ; 共有多少 FAT 表
	BPB_RootEntCnt DW 224           ; 根目录文件数最大值
	BPB_TotSec16   DW 2880          ; 逻辑扇区总数
	BPB_Media      DB 0xF0          ; 媒体描述符
	BPB_FATSz16    DW 9             ; 每FAT扇区数
	BPB_SecPerTrk  DW 18            ; 每磁道扇区数
	BPB_NumHeads   DW 2             ; 磁头数(面数)
	BPB_HiddSec    DD 0             ; 隐藏扇区数
	BPB_TotSec32   DD 0             ; wTotalSectorCount为0时这个值记录扇区数
	BS_DrvNum      DB 0             ; 中断 13 的驱动器号
	BS_Reserved1   DB 0             ; 未使用
	BS_BootSig     DB 29h           ; 扩展引导标记 (29h)
	BS_VolID       DD 0             ; 卷序列号
	BS_VolLab      DB 'OrangeS0.02' ; 卷标, 必须 11 个字节
	BS_FileSysType DB 'FAT12   '    ; 文件系统类型, 必须 8个字节 

start:

    xchg bx, bx
    mov  ax, cs
    mov  ds, ax
    mov  es, ax
    mov  ss, ax
    mov  sp, BaseOfStack

    mov ax, 0600h  ; AH=6 AL=0
    mov bx, 0700h  ; 黑底白字
    mov cx, 0      ; 左上角
    mov dx, 0184fh ; 右下角（80，50）
    int 10h        ; 清屏

    mov  dh, 0
    call DispStr

    ; 软驱归位
    xor  ah,                  ah
    xor  dl,                  dl
    int  13h
    xchg bx,                  bx
    mov  word [wSectorIndex], 19 ; mov word ptr ds:0x7d4d,0x0013
searchRoorDir:
    cmp  word [wRootSectors], 0              ; 找完了所有目录区
    jz   loaderNotFound
    dec  word [wRootSectors]                 ;wRootSectors--
    mov  ax,                  BaseOfLoader
    mov  es,                  ax
    mov  bx,                  OffsetOfLoader
    mov  ax,                  [wSectorIndex]
    mov  cl,                  1
    call readSector
    
    xchg bx, bx
    mov  si, loaderFileName ; ds:si -> "LOADER  BIN"
    mov  di, OffsetOfLoader ; es:di -> BaseOfLoader:OffsetOfLoader  和es:bx等同。
    cld
    mov  dx, 10h            ;512/32 =16,此为一个扇区有多少目录项
    ; 在扇区中搜索
    searchInSector:
        cmp dx, 0
        jz  searchInNextSector
        dec dx
        mov cx, 11             ; 目录区每一项32B,文件名占11字节，文件名8字节，扩展名3字节。
        compareFileName:
            cmp   cx, 0               ; 比对完11个字符还没跳出，代表已经找到对应的目录项。
            jz    loaderFound
            dec   cx
            lodsb                     ; 从ds:si加载数据到ax
            cmp   al, byte[es:di]
            jz    compareNextChar
            jmp   compareNextDirEntry ; 读取到字符不相等，提前退出，并且到下一个目录项寻找。
            compareNextChar:
                inc di
                jmp compareFileName
            compareNextDirEntry:
                and di, 0ffe0h         ; 将di置为最开头的值，必为20h的倍数。
                add di, 20h            ;下一个条目
                mov si, loaderFileName
                jmp searchInSector

    ; 在下一个扇区中搜索
    searchInNextSector:
        add word [wSectorIndex], 1
        jmp searchRoorDir
loaderNotFound:
    mov  dh, 2
    call DispStr
    jmp  $
loaderFound:
    mov ax, RootDirSectors
    and di, 0ffe0h
    add di, 01ah           ; 指向目录项的起始簇号
    ; 起始簇号
    mov cx, word[es:di]
    ; call loadFat1
    ; mov  ax, BaseOfLoader
    ; mov  es, ax
    ; mov  ax, OffsetOfLoader
    ; mov  bx, ax
    ; mov  ax, cx
    ; tryLoadData:
    ;     cmp ax, 0fffh
    ;     jz  label_file_loaded

    ;     ; 没加载一个扇区，就往屏幕上显示一个.        
    ;     push ax
    ;     push bx
    ;     mov  ah, 0eh
    ;     mov  al, '.'
    ;     mov  bl, 0Fh
    ;     int  10h
    ;     pop  bx
    ;     pop  ax

    ;     call loadData
    ;     cmp  ax, 0fffh
    ;     jz   label_file_loaded
    ;     jmp  tryLoadData

    push cx
    add  cx, ax
    add  cx, DeltaSectorNo  ; 17 数据区第一个扇区簇号为2（第一、第二簇被占用），第X簇对应数据区扇区号为19+14 -2
    mov  ax, BaseOfLoader
    mov  es, ax
    mov  bx, OffsetOfLoader
    mov  ax, cx             ;17 + 14 + 起始簇号，对应数据区扇区
label_goon_loading_file:
    push ax
    push bx
    ; 屏幕上显示.
    mov  ah, 0eh
    mov  al, '.'
    mov  bl, 0Fh
    int  10h
    pop  bx
    pop  ax

    mov  cl, 1
    call readSector
    pop  ax
    ; 输入-扇区号
    ; 下一个数据簇号
    call getFatEntry

    cmp  ax, 0fffh
    jz   label_file_loaded
    push ax
    mov  dx, RootDirSectors      ; 根目录区占用扇区数14
    add  ax, dx
    add  ax, DeltaSectorNo       ; 17
    add  bx, [BPB_BytsPerSec]
    jmp  label_goon_loading_file

label_file_loaded:
    mov  dh, 1
    call DispStr

    jmp BaseOfLoader:OffsetOfLoader

loaderFileName db  "LOADER  BIN",0
MessageLength  equ 9
BootMessage    db  "Booting  "
Message1       db  "Ready.   "
Message2       db  "No LOADER"


wRootSectors   dw  RootDirSectors
wSectorIndex   dw  0
bOdd           dw  0

DispStr:
    ; AH为功能号，13h
    ; BH为页号，BL为字符属性
    ; CX为字符串长度
    ; ES:BP为字符串起始地址
    ; DH、DL为行、列
    ;
    mov ax,  MessageLength
    mul dh
    add eax, BootMessage
    mov bp,  ax
    mov ax,  ds
    mov es,  ax
    mov cx,  MessageLength
    mov ax,  01301h
    mov bx,  0007h
    mov dl,  0
    int 10h
    ret

;-------------------------------------------
; 从第ax个sector开始，将cl个Sector读取到es:bx对应的内存
;------------------------------------------
readSector:
    ; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号 -> 柱面号, 起始扇区, 磁头号)
    ; TODO:此公式带解释,跟软盘具体结构、寻址方式有关，暂时还没搞懂
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                          ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	; -------------- => ┤      └ 磁头号 = y & 1
	;  每磁道扇区数      │
	;                   └ 余 z => 起始扇区号 = z + 1
    push bp
    mov  bp,  sp
    ; TODO：此处sub sp,1效果应该是一样的
    sub  esp, 1

    ; -----------------------------
    ; int 13h
    ; ah=02h al=要读的扇区数
    ; ch=柱面（磁道号） cl=起始扇区号
    ; dh=磁头号 dl=驱动器号
    ; es:bx 数据缓冲区
    ; -----------------------------

    mov  byte[bp-1], cl
    push bx
    ; ax/bl = al .... ah
    mov  bl,         [BPB_SecPerTrk] ; 每磁道扇区数
    div  bl

    ; 起始扇区号 = ah + 1;
    inc ah
    mov cl, ah

    ; ch = al >> 1
    mov dh, al
    shr al, 1
    mov ch, al
    ; dh = al & 1
    and dh, 1

    pop bx
    mov dl, [BS_DrvNum]

    tryReading:
        mov ah, 2
        mov al, byte[bp-1]
        int 13h
        ; 如果读取失败，CF会被置为1，此时不停的尝试读，直到正确。TODO:个人猜测，这是计算机底层普遍的机制。
        jc  tryReading
    add esp, 1
    pop bp
    ret

; ; TODO:应该是按需加载，只用一次，感觉没必要。
; ; 加载fat1到baseOfLoader-0x200h处
; ; 共2*16*16*16 = 8K
; ; 一个Fat表需要512*9=4.5K
; loadFat1:
;     push cx
;     push ax
;     push bx
;     mov  ax, BaseOfLoader
;     sub  ax, 0200h
;     mov  es, ax
;     mov  bx, OffsetOfLoader

;     mov cx, 8
;     mov ax, 1
;     doLoading:
;         mov  cl, 1
;         readSector
;         add  bx, 512
;         inc  ax
;         loop doLoading
;     pop bx
;     pop ax
;     pop cx
;     ret
    
; ; ax-簇号
; ; ax-下一个簇号
; loadData:
;     push dx
    
;     mov  dx, ax
;     add  ax, RootDirSectors + DeltaSectorNo
;     mov  cl, 1
;     call readSector
    
;     BaseOfLoader+0200h 
;     pop dx
    
;     ret


; 找到序号为ax的sector在FAT中条目，结果放在ax中
getFatEntry:
	push es
	push bx
	push ax
	mov  ax,          BaseOfLoader
	sub  ax,          0100h
	mov  es,          ax
	pop  ax
	mov  byte [bOdd], 0
	mov  bx,          3
	; ax * bx,将结果放置在dx:ax中
    mul  bx
	mov  bx,          2
    ; dx:ax / bx,商存储在ax中，余数存储在dx中
	div  bx
	cmp  dx,          0
	jz   LABEL_EVEN
	mov  byte [bOdd], 1
LABEL_EVEN:
	xor  dx,          dx
	mov  bx,          [BPB_BytsPerSec]
	div  bx
	push dx
	mov  bx,          0
	add  ax,          SectorNoOfFAT1
	mov  cl,          2
	call readSector
	pop  dx
	add  bx,          dx
	mov  ax,          [es:bx]
	cmp  byte [bOdd], 1
	jnz  LABEL_EVEN_2
	shr  ax,          4
LABEL_EVEN_2:
	and ax, 0FFFh

LABEL_GET_FAT_ENRY_OK:

	pop bx
	pop es
	ret
times 510-($-$$) db 0
dw                  0xaa55