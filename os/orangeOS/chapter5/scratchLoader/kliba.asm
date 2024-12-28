[section .data]
    disp_pos dd 0
[section .text]

global disp_str

disp_str:
    push ebp
    mov  ebp, esp
    mov  esi, [ebp+8]
    mov  edi, [disp_pos]
    mov  ah,  0fh
.1:
    lodsb
    test al,  al
    jz   .2
    cmp  al,  0ah ;是否是回车
    jnz  .3
    push eax
    mov  eax, edi
    mov  bl,  160
    div  bl

    and eax, 0ffh
    inc eax
    mov bl,  160
    mul bl
    mov edi, eax
    pop eax
    jmp .1
.3:
    mov [gs:edi], ax
    add edi,      2
    jmp .1
.2:
     mov [disp_pos], edi
     pop ebp
     ret

