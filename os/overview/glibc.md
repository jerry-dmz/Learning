[glibc源码分析（一）系统调用 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/31496865)

glib是GNU发布的libc库，即c运行库。glibc是linux系统中最底层的api，几乎所有其它运行库都会依赖于glibc。除了封装了linux操作系统所提供的系统服务外，本身也提供了许多其他一些必要功能服务的实现。

支持不同的体系架构（alpha,arm,i386,ia64,powerpc），不同体系架构之上又支持不同的操作系统(bsd,linux)

**系统调用的封装按照固定规则进行：**

寄存器eax传递系统调用号。寄存器ebx、ecx、edx、esi、edi、ebp依次传递系统调用参数。int0x80指令切入内核执行系统调用，系统调用执行完成后返回，寄存器eax保存系统调用的返回值。

**glibc的封装方式:**

* 脚本生成汇编文件，汇编文件中汇编代码封装了系统调用

脚本封装的规则，make-syscall.sh读取syscalls.list中的内容，根据每一行进行解析，生成一个.S汇编文件，一个汇编文件封装了一个系统调用

syscall-template.S是系统调用封装代码的模板文件，生成的.S汇编文件都调用它。

3种文件，make-syscall.sh文件在sysdeps/unix/make-syscall.sh。syscall-template.S文件在sysdeps/unix/syscall-template.S。syscalls.list文件则有多个，分别在sysdeps/unix/syscalls.list，sysdeps/unix/sysv/linux/syscalls.list，sysdeps/unix/sysv/linux/generic/syscalls.list，sysdeps/unix/sysv/linux/i386/syscalls.list。

具体调用逻辑封装在syscall-templates.S中

* c文件中调用嵌入式汇编代码封装了系统调用







