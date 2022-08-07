;es寄存器指向文本模式的显示缓冲区,Intel处理器不允许直接将立即数转移到段寄存器
mov ax, 0xb800
mov es,ax

;以下显示字符串“Label offset”
;字符的显示属性分为两个字节，第一个字符显示ASCLL码，第二个字符是字符的显示属性
;0x07表示字符以白底黑字，无闪烁无加亮的方式显示
mov byte [es:0x00],"L"
mov byte [es:0x01],0x07
mov byte [es:0x02],"a"
mov byte [es:0x03],0x07
mov byte [es:0x04],"b"
mov byte [es:0x05],0x07
mov byte [es:0x06],"e"
mov byte [es:0x07],0x07
mov byte [es:0x08],"l"
mov byte [es:0x09],0x07
mov byte [es:0x0a]," "
mov byte [es:0x0b],0x07
mov byte [es:0x0c],"o"
mov byte [es:0x0d],0x07
mov byte [es:0x0e],"f"
mov byte [es:0x0f],0x07
mov byte [es:0x10],"f"
mov byte [es:0x11],0x07
mov byte [es:0x12],"s"
mov byte [es:0x13],0x07
mov byte [es:0x14],"e"
mov byte [es:0x15],0x07
mov byte [es:0x16],"t"
mov byte [es:0x17],0x07
mov byte [es:0x18],":"
mov byte [es:0x19],0x07

;此处取的number的地址0x00302
mov ax,number
mov bx,10   ;bx保存被除数，div指令使用bx寄存器的值作为被除数

;设置数据段的基址 TODO:此处为何利用cx作为中转
mov cx,cs
mov ds,cx

;32位除法中，被除数的低16在ax寄存器中，高16位在dx寄存器中;商放到AX中，余数放到dx中
;求个位数字
mov dx,0
div bx
mov [0x7c00+number+0x00],dl

;求十位数字，将dx清0，上一次的商作为此次的被除数
xor dx,dx
div bx
mov [0x7c00+number+0x01],dl

;求百位数字
xor dx,dx
div bx
mov [0x7c00+number+0x02],dl

;求千位数字
xor dx,dx
div bx
mov [0x7c00+number+0x03],dl

;求万位数字
xor dx,dx
div bx
mov [0x7c00+number+0x04],dl

;以下用十进制显示标号的偏移地址
mov al,[0x7c00+number+0x04] ;将计算结果送到al寄存器
add al,0x30                 ;加上0x30得到这个数字的ASCLL码
mov [es:0x1a],al            ;得到的ASCLL码送到指定位置，之前显存最后字符“:”位于0x19处
mov byte [es:0x1b],0x04     ;显示属性为黑底红字，无闪烁无加亮

mov al,[0x7c00+number+0x03]
add al,0x30
mov [es:0x1c],al
mov byte [es:0x1d],0x04

mov al,[0x7c00+number+0x02]
add al,0x30
mov [es:0x1e],al
mov byte [es:0x1f],0x04

mov al,[0x7c00+number+0x01]
add al,0x30
mov [es:0x20],al
mov byte [es:0x21],0x04

mov al,[0x7c00+number+0x00]
add al,0x30
mov [es:0x22],al
mov byte [es:0x23],0x04

mov byte [es:0x24],'D'
mov byte [es:0x25],0x07
infi:jmp near infi
number db 0,0,0,0,0
;填充剩余空间，并让最后结尾为0x55,0xaa
times 203 db 0
          db 0x55,0xaa
;最终显示结果Label offset:00302D
;302+203+5+2=512字节

