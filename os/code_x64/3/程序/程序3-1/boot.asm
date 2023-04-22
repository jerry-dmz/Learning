

	org	0x7c00	

;栈向下增长
;000-3FF 中断向量表
;400-4FF BIOS DATA Area
;500-7BFF 约30KB,可用区域
BaseOfStack	equ	0x7c00

Label_Start:

	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ss,	ax
	mov	sp,	BaseOfStack

;=======	clear screen

	mov	ax,	0600h ;滚动6行
	mov	bx,	0700h ;空出行的背景，7表示白色、0表示黑色
	mov	cx,	0	;滚动左上角
	mov	dx,	0184fh ;滚动右下角
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

	jmp	$

StartBootMessage:	db	"Start Boot"

;=======	fill zero until whole sector

	times	510 - ($ - $$)	db	0
	dw	0xaa55

