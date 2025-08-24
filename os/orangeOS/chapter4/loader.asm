    mov ax, 0600h  ; AH=6 AL=0
    mov bx, 0700h  ; 黑底白字
    mov cx, 0      ; 左上角
    mov dx, 0184fh ; 右下角（80，50）
    int 10h        ; 清屏

    mov ax,                 0B800h
    mov gs,                 ax
    mov ah,                 0Fh
    mov al,                 'L'
    mov [gs:((80*0+39)*2)], ax
    jmp $