# 查找列表中最大的数
# rbx中就是最大值
#
#
#
.global  _start

.section .data

    # 数据列表
    data_list:
        .long 23, 12, 34, 123, 1, 0

.section .text
    _start:
        movl $0, %edi
        movl data_list(, %edi, 4), %eax
        movl %eax, %ebx
    loop:
        cmpl $0, %eax
        je loop_exit
        incl %edi
        movl data_list(, %edi, 4), %eax
        cmpl %ebx, %eax
        jle loop
        mov %eax, %ebx
        jmp loop
    loop_exit:
        movl $1, %eax
        int $0x80
 