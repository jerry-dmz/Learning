

org	10000h

	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ax,	0x00
	mov	ss,	ax
	;实模式内存布局
	;000~3FF 中断向量表 1KB
	;400~4FF BIOS数据区 256B
	;500~7BFF 可用区域	约30KB
	mov	sp,	0x7c00

;=======	display on screen : Start Loader......
	;BIOS中断10h，显示消息
	;TODO:整理所有BIOS中断
	mov	ax,	1301h
	mov	bx,	000fh
	mov	dx,	0200h		;row 2
	mov	cx,	12
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	StartLoaderMessage
	int	10h

	jmp	$

;=======	display messages

StartLoaderMessage:	db	"Start Loader"





