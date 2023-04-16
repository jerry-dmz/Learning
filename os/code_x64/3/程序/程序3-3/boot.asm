

	org	0x7c00	

BaseOfStack	equ	0x7c00
;7C00~7DFF mbr被加载到此处，512B
;7E00~9FBFF 可用区域 约608KB
BaseOfLoader	equ	0x1000
OffsetOfLoader	equ	0x0000

;(224*32+512-1)/512=14个扇区
;TODO:此处为什么要加512？？？
RootDirSectors	equ	14
SectorNumOfRootDirStart	equ	19
SectorNumOfFAT1Start	equ	1
;数据区起始扇区号 = 根目录起始扇区号 + 根目录区所占扇区数 - 2
;TODO:???这个变量很容易让人造成误解
SectorBalance	equ	17	
	;TODO:此处为什么要用跳转指令？？？
	;使指令按字对齐，产生一定的延迟，等待计算机缓冲区清空
	jmp	short Label_Start
	nop
	BS_OEMName	db	'MINEboot'
	BPB_BytesPerSec	dw	512
	BPB_SecPerClus	db	1
	BPB_RsvdSecCnt	dw	1
	BPB_NumFATs	db	2
	BPB_RootEntCnt	dw	224
	BPB_TotSec16	dw	2880
	BPB_Media	db	0xf0
	BPB_FATSz16	dw	9
	BPB_SecPerTrk	dw	18
	BPB_NumHeads	dw	2
	BPB_HiddSec	dd	0
	BPB_TotSec32	dd	0
	BS_DrvNum	db	0
	BS_Reserved1	db	0
	BS_BootSig	db	0x29
	BS_VolID	dd	0
	BS_VolLab	db	'boot loader'
	BS_FileSysType	db	'FAT12   '

Label_Start:

	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ss,	ax
	mov	sp,	BaseOfStack

;=======	clear screen

	mov	ax,	0600h
	mov	bx,	0700h
	mov	cx,	0
	mov	dx,	0184fh
	int	10h

;=======	set focus

	mov	ax,	0200h
	mov	bx,	0000h
	mov	dx,	0000h
	int	10h

;=======	display on screen : Start Booting......

	mov	ax,	1301h
	mov	bx,	000fh
	mov	dx,	0000h
	mov	cx,	10
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	StartBootMessage
	int	10h

;=======	reset floppy

	xor	ah,	ah
	xor	dl,	dl
	int	13h

;=======	search loader.bin
	mov	word	[SectorNo],	SectorNumOfRootDirStart

Lable_Search_In_Root_Dir_Begin:

	cmp	word	[RootDirSizeForLoop],	0
	jz	Label_No_LoaderBin
	dec	word	[RootDirSizeForLoop]	
	mov	ax,	00h
	mov	es,	ax
	mov	bx,	8000h
	mov	ax,	[SectorNo]
	mov	cl,	1
	;es:bx存储读取的数据
	;ax，代表读哪个扇区
	;cx，代表读取扇区数
	call	Func_ReadOneSector
	mov	si,	LoaderFileName
	mov	di,	8000h
	;控制串操作指令方法（lodsb）	
	cld
	;一个扇区512字节，一个目录项32字节，故16次
	mov	dx,	10h
	
Label_Search_For_LoaderBin:

	cmp	dx,	0
	jz	Label_Goto_Next_Sector_In_Root_Dir
	dec	dx
	;目录区每个目录名字11个字节
	mov	cx,	11

Label_Cmp_FileName:
	
	;如果比较了前11个字节还是符合，则算符合的文件
	cmp	cx,	0
	jz	Label_FileName_Found
	dec	cx
	;将一个字节传送到ax
	;TODO:为何不能取指定字节,要这么麻烦。
	lodsb	
	cmp	al,	byte	[es:di]
	jz	Label_Go_On
	;如果比较途中，有一个不符合则跳转下一个目录读取
	jmp	Label_Different

Label_Go_On:
	
	inc	di
	jmp	Label_Cmp_FileName

Label_Different:

	;清空di的低32位，然后跳到下一个扇区
	and	di,	0ffe0h
	add	di,	20h
	mov	si,	LoaderFileName
	jmp	Label_Search_For_LoaderBin

Label_Goto_Next_Sector_In_Root_Dir:
	
	add	word	[SectorNo],	1
	jmp	Lable_Search_In_Root_Dir_Begin
	
;=======	display on screen : ERROR:No LOADER Found

Label_No_LoaderBin:

	mov	ax,	1301h
	mov	bx,	008ch
	mov	dx,	0100h
	mov	cx,	21
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	NoLoaderMessage
	int	10h
	jmp	$

;=======	found loader.bin name in root director struct

Label_FileName_Found:

	mov	ax,	RootDirSectors
	;di中存储的是找到的地址，加26之后就是该目录对应文件的起始簇号
	and	di,	0ffe0h
	add	di,	01ah
	;簇号，（目前是一簇一扇区，情况胶简单）
	mov	cx,	word	[es:di]
	push	cx
	add	cx,	ax
	add	cx,	SectorBalance
	mov	ax,	BaseOfLoader
	mov	es,	ax
	mov	bx,	OffsetOfLoader
	mov	ax,	cx

Label_Go_On_Loading_File:
	push	ax
	push	bx
	mov	ah,	0eh
	mov	al,	'.'
	mov	bl,	0fh
	int	10h
	pop	bx
	pop	ax

	mov	cl,	1
	;es:bx扇区数据，cx读取几个扇区，ax读取扇区起始号
	call	Func_ReadOneSector
	pop	ax
	;FAT12文件系统每个表项占用12bit
	;AH=FAT表项号
	call	Func_GetFATEntry
	cmp	ax,	0fffh
	jz	Label_File_Loaded
	push	ax
	mov	dx,	RootDirSectors
	add	ax,	dx
	add	ax,	SectorBalance
	add	bx,	[BPB_BytesPerSec]
	jmp	Label_Go_On_Loading_File

Label_File_Loaded:
	
	jmp	BaseOfLoader:OffsetOfLoader

;=======	read one sector from floppy


Func_ReadOneSector:
	
	push	bp
	mov	bp,	sp
	sub	esp,	2
	mov	byte	[bp - 2],	cl
	push	bx
	mov	bl,	[BPB_SecPerTrk]
	div	bl
	inc	ah
	mov	cl,	ah
	mov	dh,	al
	shr	al,	1
	mov	ch,	al
	and	dh,	1
	pop	bx
	mov	dl,	[BS_DrvNum]
Label_Go_On_Reading:
	mov	ah,	2
	mov	al,	byte	[bp - 2]
	int	13h
	jc	Label_Go_On_Reading
	add	esp,	2
	pop	bp
	ret

;=======	get FAT Entry

Func_GetFATEntry:

	push	es
	push	bx
	push	ax
	mov	ax,	00
	mov	es,	ax
	pop	ax
	mov	byte	[Odd],	0
	mov	bx,	3
	mul	bx
	mov	bx,	2
	div	bx
	cmp	dx,	0
	jz	Label_Even
	mov	byte	[Odd],	1

Label_Even:
	;ax为loader.bin对应文件簇号
	;异或清零
    ;16位除法:
    ;   1.除数:由通用寄存器或内存单元提供
    ;   2.被除数:低16位ax，高16位dx
    ;   3.余数dx，商ax中
    ;dx-ax 除 bx = ax-dx（dx-ax是地址，除后商ax第几个扇区，余数dx下个扇区字节）
	xor	dx,	dx
	mov	bx,	[BPB_BytesPerSec]
	div	bx
	push	dx
	mov	bx,	8000h
	add	ax,	SectorNumOfFAT1Start
	mov	cl,	2
	call	Func_ReadOneSector
	;TODO：此处代码待思考
	pop	dx
	add	bx,	dx
	mov	ax,	[es:bx]
	cmp	byte	[Odd],	1
	jnz	Label_Even_2
	shr	ax,	4

Label_Even_2:
	and	ax,	0fffh
	pop	bx
	pop	es
	ret

;=======	tmp variable

RootDirSizeForLoop	dw	RootDirSectors
SectorNo		dw	0
Odd			db	0

;=======	display messages

StartBootMessage:	db	"Start Boot"
NoLoaderMessage:	db	"ERROR:No LOADER Found"
LoaderFileName:		db	"LOADER  BIN",0

;=======	fill zero until whole sector

	times	510 - ($ - $$)	db	0
	dw	0xaa55

