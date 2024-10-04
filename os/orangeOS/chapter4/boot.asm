; %define _BOOT_DEBUG_
%ifdef _BOOT_DEBUG_
    org 0100h
%else
    org 07c00h
%endif

%ifdef _BOOT_DEBUG_
    BaseOfStack equ 0100h
%else
    BaseOfStack equ 07c00h
%endif

BaseOfLoader             equ 09000h
OffsetOfLoader           equ 0100h

RootDirSectors           equ 14 ; 根目录占用扇区数
SectorsNoOfRootDirectory equ 19
SectorNoOfFAT1           equ 1
DeltaSectorNo            equ 17

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
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BaseOfStack

    mov ax, 0600h  ; AH=6 AL=0
    mov bx, 0700h  ; 黑底白字
    mov cx, 0      ; 左上角
    mov dx, 0184fh ; 右下角（80，50）
    int 10h        ; 清屏

    mov  dh, 0
    call DispStr

    xor ah, ah
    xor dl, dl
    int 13h

    mov word [wSectorNo], SectorsNoOfRootDirectory
label_search_in_root_dir_begin:
    cmp  word [wRootDirSizeForLoop], 0
    jz   label_no_loaderbin
    dec  word [wRootDirSizeForLoop]
    mov  ax,                         BaseOfLoader
    mov  es,                         ax
    mov  bx,                         OffsetOfLoader
    mov  ax,                         [wSectorNo]
    mov  cl,                         1
    call ReadSector

    mov si, loaderFileName
    mov di, OffsetOfLoader
    cld
    mov dx, 10h
label_search_for_looaderbin:
    cmp dx, 0
    jz  label_goto_next_sector_in_root_dir
    dec bx
    mov cx, 11
label_cmp_fileName:
    cmp cx, 0
    jz  label_fileName_found
    dec cx
    lodsb
    cmp al, byte[es:di]
    jz  label_go_on
    jmp label_different
label_go_on:
    inc di
    jmp label_cmp_fileName
label_different:
    and di, 0ffe0h
    and di, 20h
    mov si, loaderFileName
    jmp label_search_for_looaderbin
label_goto_next_sector_in_root_dir:
    add word [wSectorNo], 1
    jmp label_search_in_root_dir_begin
label_no_loaderbin:
    mov  dh, 2
    call DispStr
    %ifdef _BOOT_DEBUG_
        mov ax, 4c00h
        int 21h
    %else
        jmp $
    %endif
label_fileName_found:
    mov  ax, RootDirSectors
    and  di, 0ffe0h
    and  di, 01ah
    mov  cx, word[es:di]
    push cx
    add  cx, ax
    add  cx, DeltaSectorNo
    mov  ax, BaseOfLoader
    mov  es, ax
    mov  bx, OffsetOfLoader
    mov  ax, cx
label_goon_loading_file:
    push ax
    push bx
    mov  ah, 0eh
    mov  al, '.'
    mov  bl, 0Fh
    int  10h
    pop  bx
    pop  ax

    mov  cl, 1
    call ReadSector
    pop  ax
    call GetFATEntry
    cmp  ax, 0fffh
    jz   label_file_loaded
    push ax
    mov  dx, RootDirSectors
    add  ax, dx
    add  ax, DeltaSectorNo
    add  bx, [BPB_BytsPerSec]
    jmp  label_goon_loading_file

label_file_loaded:
    mov  dh, 1
    call DispStr

    jmp BaseOfLoader:OffsetOfLoader

loaderFileName      db  "LOADER  BIN",0
MessageLength       equ 9
BootMessage         db  "Booting  "
Message1            db  "Ready.   "
Message2            db  "No LOADER"


wRootDirSizeForLoop dw  RootDirSectors
wSectorNo           dw  0
bOdd                dw  0

DispStr:
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
ReadSector:
    ; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号 -> 柱面号, 起始扇区, 磁头号)
    ; TODO:此公式带解释
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                           ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	; -------------- => ┤      └ 磁头号 = y & 1
	;  每磁道扇区数     │
	;                   └ 余 z => 起始扇区号 = z + 1
    push bp
    mov  bp,  sp
    sub  esp, 2

    ; -----------------------------
    ; int 13h
    ; ah=02h al=要读的扇区数
    ; ch=柱面（磁道号） cl=起始扇区号
    ; dh=磁头号 dl=驱动器号
    ; es:bx 数据缓冲区
    ; -----------------------------

    mov  byte[bp-2], cl
    push bx
    mov  bl,         [BPB_SecPerTrk]
    div  bl
    inc  ah
    mov  cl,         ah
    mov  dh,         al
    shr  al,         1
    mov  ch,         al
    add  ah,         1
    pop  bx
    mov  dl,         [BS_DrvNum]

.GoOnReading:
    mov ah,  2
    mov al,  byte[bp-2]
    int 13h
    jc  .GoOnReading
    add esp, 2
    pop bp

    ret

GetFATEntry:
	push es
	push bx
	push ax
	mov  ax,          BaseOfLoader
	sub  ax,          0100h
	mov  es,          ax
	pop  ax
	mov  byte [bOdd], 0
	mov  bx,          3
	mul  bx
	mov  bx,          2
	div  bx
	cmp  dx,          0
	jz   LABEL_EVEN
	mov  byte [bOdd], 1
LABEL_EVEN:
	xor dx, dx
	mov bx, [BPB_BytsPerSec]
	div bx
		   
		   
	push dx
	mov  bx,          0
	add  ax,          SectorNoOfFAT1
	mov  cl,          2
	call ReadSector
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