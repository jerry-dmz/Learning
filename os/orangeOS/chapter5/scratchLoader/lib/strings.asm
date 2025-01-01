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
    ; gcc高版本对ebx使用可能不同。在gcc11.4.0中，ebx被作为字符串常量池的索引
    ; 比如 disp_str("ddss"）被翻译成:
    ; sub  esp 0x0c
    ; lea  eax, [ebx-8192]
    ; push eax
    ; call .112
    ; add  esp 0x10
    push ebx
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
    pop ebx
    jmp .1
.3:
    mov [gs:edi], ax
    add edi,      2
    jmp .1
.2:
     mov [disp_pos], edi
     pop ebp
     ret

