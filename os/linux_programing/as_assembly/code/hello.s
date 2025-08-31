# 表示不应该在汇编后废弃此符号，链接器需要此符号
.global  _start
.global msg

# 带点的都是汇编伪指令，不会被处理
# 
.section .data
    msg:     
        .string "你好，操作系统\n"
    len = . - msg

.section .text

_start:
    # syscall: write(1, msg, len)
    mov $1,    %rax        # sys_write 系统调用号
    mov $1,   %rdi        # 文件描述符 1（标准输出）
    mov $msg, %rsi      # 字符串地址
    mov $len, %rdx      # 字符串长度
    #TODO:和int $80的区别
    syscall

    #   syscall: exit(0)
    mov $60,  %rax       # sys_exit 系统调用号
    xor %rdi, %rdi      # 退出状态码 0
    syscall
