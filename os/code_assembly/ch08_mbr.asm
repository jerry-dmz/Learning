;读取100个扇区后若干个字节的内容，加载到0x10000之后，然后跳转到用户程序执行
;声明常数（用户程序起始逻辑扇区号）
;常数的声明不会占用汇编地址（equ->equal），类似宏
app_lba_start equ 100

;align,汇编器会根据这个设置决定段的物理地址，Intel处理器要求段在内存中的起始物理地址起码是16个字节对齐的。（TODO:为什么？）
;TODO:vstart（mov ax,[cs:phy_base]，会自动加上0x7c00)
section mbr align=16 vstart=0x7c00
        
        ;初始化堆栈，位0x0000,在段内0xFFFF和0x0000之间变化。
        mov ax,0
        mov ss,ax
        mov sp,ax

        ;TODO:此处得到段地址的方式不优雅，这里不就默认偏移地址为0吗？
        mov ax,[cs:phy_base]
        mov dx,[cs:phy_base+0x02]
        mov bx,16
        div bx
        mov ds,ax
        mov es,ax

        xor di,di
        mov si,app_lba_start
        xor bx,bx
        ;首先读取用户程序头，512字节，包含最开始的程序头，以及一部分实际的指令和数据
        call read_hard_disk_0

        ;用户程序最开始的双字指示程序大小
        ;32位除法。(dx:ax)/bx,商放在ax,余数放在dx
        mov dx,[2]
        mov ax,[0]
        mov bx,512
        div bx
        cmp dx,0    ;判断有没有除尽，dx存储余数
        jnz @1
        ;TODO:如果小于一扇区或正好为扇区数，需要减一，因为之前已经预读过，ax为0时，dec ax会是什么结果？？？
        dec ax
    @1:
        ;如果ax值大于0，则直接跳到，将扇区数赋给cx，执行@2，将ds值加512字节，将第二个扇区值放在一个新段中，增加si（si指示扇区起始）
        ;如果ax值为0，代表扇区数肯定小于512字节，不需要继续读了，直接走到direct
        cmp ax,0
        jz direct
        push ds
        mov cx,ax
    @2:
        mov ax,ds
        add ax,0x20
        mov ds,ax
        xor bx,bx
        inc si
        call read_hard_disk_0
        loop @2
        pop ds
    ;重定位代码段
    direct:
        mov dx,[0x08]
        mov ax,[0x06]   ;存放入口点代码段的汇编地址
        call calc_segment_base  ;ax中存放代码段重定位后逻辑段地址
        mov [0x06],ax   ;将计算准确的地址回写
        mov cx,[0x0a]   ;段重定位表项数
        mov bx,0x0c ;段重定位表起始地址，每一项包含每个段的段地址:偏移地址
    ;重定位其他段
    realloc:
        mov dx,[bx+0x02]
        mov ax,[bx]
        call calc_segment_base
        mov [bx],ax
        add bx,4    ;一个表项两个字，故增4
        loop realloc
        jmp far [0x04]  ;全部都重定位完后，跳到代码段执行，段间远转移，接下来的工作就转移到用户程序

;从si指示的起始扇区，读取一个扇区所有字节到es指示的地址
read_hard_disk_0:
    ;调用之前先将通用寄存器入栈
    push ax
    push bx
    push cx
    push dx

    ;主寄存器有8个端口，范围为0x1f0~0x1f7
    ;0x1f0:16位端口，数据端口
    ;0x1f1:错误端口，包含硬盘驱动器最后一次执行命令后的状态
    ;0x1f2:8位端口，为0代表读取256个扇区，设置要读取的扇区数
    ;0x1f3、0x1f4、0x1f5、0x1f6:8位端口,设置开始读取扇区的起始位置（LBA28）
    ;0x1f7:8位端口,写入0x20请求硬盘读，既是命令端口，又是状态端口，内部操作期间会将第7位置为1，表示正在忙
    mov dx,0x1f2
    mov al,1
    out dx,al

    ;si初始值为100，代表从第100个扇区开始读，0x0064
    inc dx  ;0x1f3端口
    mov ax,si
    out dx,al
    
    inc dx  ;0x1f4端口
    mov al,ah ;执行完后ax=0x0000
    out dx,al
    
    inc dx  ;0x1f5端口
    mov ax,di ;di=0x0000
    out dx,al

    inc dx  ;0x1f6端口，低4位用于存储LBA28的后四位，高四位（第一位用于指示是主盘还是从盘，0表示主盘，111表示LBA模式）
    mov al,0xe0 ;ax=0x00e0=0000 0000 1110 0000
    or al,ah    ;TODO:or指令的目的
    out dx,al

    inc dx  ;0x1f7,写入0x20代表硬盘读，也指示着硬盘的状态
    mov al,0x20
    out dx,al

    .waits:
        in al,dx
        and al,0x88 ;0x88=1000 1000  要保留第7位（为1表示正在忙）、3位（为1表示硬盘已经准备好和主机交换数据）的状态
        cmp al,0x08 ;相等表示硬盘能够交互数据了，会执行.readw
        jnz .waits

        mov cx,256
        mov dx,0x1f0
    .readw:
        in ax,dx    ;0x1f0为数据端口，16位端口，一次读两个字节，要读256次，才能将一个扇区的数据读完
        mov [bx],ax ;es已经在之前初始化为加载用户程序的地址
        add bx,2
        loop .readw
        pop dx
        pop cx
        pop bx
        pop ax
        ret
calc_segment_base:
    ;TODO:仔细分析
    push dx ;第一次调用时，dx:ax得到的也只是用户程序内的偏移地址，要得到物理地址需要加上用户程序被加载到位置
    add ax,[cs:phy_base]    ;偏移地址 + 0x0000
    adc dx,[cs:phy_base+0x02] ;段地址 + 0x1000
    shr ax,4    ;20位地址，高四位是存放在dx中，余下16位存放在ax中
    ror dx,4    ;ror执行时，移出的比特既送到标志寄存器的CF位，也送到左边空出的位
    and dx,0xf000   ;将dx的低12位清零
    or ax,dx        ;将ax、dx内容合并
    
    pop dx
    
    ret
;可用空间10000~9FFFFF，可加载用户程序

;声明用户程序被加载的为位置，[cs:phy_base]=0x0000,[cs:phy_base+0x02]=0x1000
phy_base dd 0x10000

times 510-($-$$) db 0
db 0x55,0xaa


























