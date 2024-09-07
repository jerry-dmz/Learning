; 显示AL中的数字
DisplayAL:
    push ecx
    push edx
    push edi

    mov edi, [dwDispPos]

    mov ah,  0Fh
    mov dl,  al
    shr al,  4   ; 得到高4位值
    mov ecx, 2
.begin:
    and al, 01111b ; 得到低4位值
    cmp al, 9      ; 比较是数字还是字母
    ja  .1
    add al, '0'    ; 数字变成ASCLL码
    jmp .2
.1:
    sub al, 0ah ; A比0大10要减去，这里是为了得到字符到A的间隔
    add al, 'A' ; 字母变成ASCLL码
.2:
    mov  [gs:edi], ax
    add  edi,      2  ; 一个ASCLL码两个自己，ah存放显示属性，al存放实际值
    mov  al,       dl
    loop .begin

    mov [dwDispPos], edi
    pop edi
    pop edx
    pop ecx

    ret
    
; 显示堆栈中一个整型数值
DisplayInt:
    mov  eax, [esp + 4]
    shr  eax, 24
    call DisplayAL

    mov  eax, [esp + 4]
    shr  eax, 16
    call DisplayAL

    mov  eax, [esp + 4]
    shr  eax, 8
    call DisplayAL

    mov  eax, [esp + 4]
    call DisplayAL

    mov  ah,          0Fh
    mov  al,          "h"
    push edi
    mov  edi,         [dwDispPos]
    mov  [gs:edi],    ax
    add  edi,         4           ; 这里为什么加4不清楚，应该是2吧？TODO:
    mov  [dwDispPos], edi
    pop  edi

    ret

DisplayString:

    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]   ; 从栈中获取传递给函数的参数，在常见的函数约定中，第一个参数通常位于ebp+8的位置
    mov edi, [dwDispPos]
    mov ah,  0fh
.1:
    lodsb
    test al,  al
    jz   .2
    cmp  al,  0Ah  ; 是否是回车
    jnz  .3
    ; 换行处理
    push eax
    mov  eax, edi
    mov  bl,  160  ; 一行显示80个字符，共160个字节
    div  bl        ; eax中存放商，即当前在第几行显示
    and  eax, 0FFh ;去除高24位的残存值，避免影响
    inc  eax       ; 换到下一行
    mov  bl,  160
    mul  bl
    mov  edi, eax
    pop  eax
    jmp  .1
.3:
    mov [gs:edi], eax
    add edi,      2
    jmp .1
.2:
    mov [dwDispPos], edi

    pop edi
	pop esi
	pop ebx
	pop ebp
	ret

DisplayReturn:

    push szReturn      ;换行
    call DisplayString
    add  esp, 4

    ret