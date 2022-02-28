## 《趣谈linux》

#### 大纲

* **初创期**，基于开放的运营商环境（**X86体系架构**），创办一家外包公司（**系统的启动**）。一开始没有其他员工，老板亲自接项目（**实模式**）。
* **发展期**，公司做大，项目变多（**保护模式、多进程**），为了管理各个外包项目，建立了项目管理体系（**进程管理**）、会议室管理体系（**内存管理**）、文档资料管理体系（**文件系统**）、售前售后体系（**输入输出设备管理**）。
* **壮大期**，公司壮大，开始促进内部项目的合作（**进程间通信**）和外部公司合作（**网络通信**）。
* **集团化**，公司壮大，成立多家子公司（**虚拟化**），或者鼓励内部创业（容器化），这个时候公司就变成了集团。大管家的调度能力不再局限于一家公司，而是集团公司（**linux集群**），从而成功上市（**从单机操作系统到数据中心调度**）。

#### 路线

* ##### 第一个坡：熟练的使用linux命令行

  《鸟哥的linux私房菜》、《linux系统管理手册》

* ##### 第二个坡：通过系统调用或glibc编写程序

  《UNIX环境高级编程》

  [别出心裁的Linux系统调用学习法 - 娄老师 - 博客园 (cnblogs.com)](https://www.cnblogs.com/rocedu/p/6016880.html)

  《Unix/Linux编程实践教程》

* ##### 第三个坡：了解linux内核机制

  《深入理解linux内核》

  《庖丁解牛Linux内核分析》

* ##### 第四个坡：阅读linux源码，聚焦核心逻辑和场景

  《linux内核源代码情景分析》

  《linux 驱动开发》

* ##### 第五个坡：实验定制化Linux组件

* ##### **第六个坡：**面向真实场景的开发

#### 想法

* 为什么要学习linux？

* 要有那些前置性的工作？

* 怎么样学习linux？

  先对大致流程原理有个实际性的认识吧。然后一个个爬坡（**一定要有疑问，一定要有产出，一定要有计划**）。做好关键性的笔记（场景用例），以达到更好的效果，对于暂时不懂的东西可以记录，不能浮于表面。

* 时间跨度到底要有多大？

* 涉及到硬件方面相关的东西，该如何兼顾（对机器设施并不了解）？

#### 任务1.跟着专栏熟悉linux各种机制的大体流程

硬件安装-->操作系统安装-->qq安装-->打开qq

输入设备（键盘鼠标），**客户对接员**，把客户需求拿回来，产生中断事件

输出设备（显示器），**交互人员**

鼠标双击qq，os从中断得知是要运行qq，并且qq将会长期运行，需要进行**立项**

立项需要有**项目执行计划书**（qq这个二进制程序），存放在格式化后的硬盘上（格式化的本质在硬盘里设置一些文件系统管理相关的信息）

系统调用会列出那些接口可以调用，进程需要的时候可以去调用。其中，**立项**就是办事大厅提供的关键服务之一。

立项之后，共享资源（人力资源、硬件资源....）在多个项目之间使用，因此需要调用各个项目的使用，**进程管理**

https://github.com/torvalds/linux   **linux项目架构熟悉、其build规范**  **TODO:**

References:
https://www.kernel.org/
https://courses.linuxchix.org/kernel-hacking-2002/08-overview-kernel-source.html



###### **1.常见的系统调用**

**立项服务-创建进程****fork**

linux中，创建一个新的进程，需要一个老的进程调用**fork**实现。当父进程调用fork时，子进程将各个子系统为父进程创建的数据结构全部拷贝一份（甚至连程序代码都拷贝）。

对于**fork**调用返回值，如果当前进程是子进程，返回0；如果是父进程，返回子进程的pid；子进程需要**execve**执行另一个程序

父进程可以调用**waitipid**，将子进程的进程号传递过去，就能获知子进程的运行情况

所以说，所有子进程最终都是老板，也就是**祖宗进程**fork过来的，因此需要对整个公司的项目运行负最终的责任。

**会议室管理-内存管理**

项目启动之后，每个项目组有独立的会议室，存放自己项目相关的数据（进程内存空间）。

**首先**，项目执行计划书要放进去，执行过程肯定要不停的看，**代码段**

项目执行过程中，会产生一些架构图、流程图，这些项目进行的数据可能是即时的（局部变量）和长久些的（全局变量），**数据段**

只有进程使用部分内存的时候，才会使用内存管理系统的系统调用来登记，只有到真正写入数据的时候，发现没有对应物理内存，才会触发中断，现分配物理内存

堆中分配内存的系统调用 **brk**、**mmap**

**档案库管理-文件管理**

项目执行计划书要保存在档案库里，有一些需要长时间保存，这样，哪怕公司暂停营业，再次经营时也可以使用。放到文件系统中。文件之所以能做到这一点，一方面是因为**介质**，另一方面是因为**格式**。公司之所以强调资料库，也是希望将一些知识固化为标准格式，放在一起进行管理。

对于文件的操作：**open、close、create、lsleek、read、write**

linux中**一切皆文件**的体现：

* 启动一个进程，需要一个程序文件，这是一个**二进制文件**；
* 启动的时候，要加载一些配置文件，这是文本文件；启动之后会打印一些日志，如果写到硬盘上，也是**文本文件**；
* 如果想把日志打印到交互控制台，这也是个文件，标准**stdout**文件;
* 这个进程的输入可以作为另一个进程的输入，这种方式称为**管道**，管道也是一个文件；
* 进程可以通过网络和其他进程进行通信，建立的**socket**，也是一个文件；
* 进程需要访问外部设备，**外部设备**也是个文件；
* 文件被存储在文件夹里，**文件夹**也是一个文件；
* 进程运行起来，想要看到进程的运行情况，会在/proc下面有对应的**进程号**，还是一系列文件；

每个文件，linux都会分配一个**文件描述符**，这是一个整数。有了这个文件描述符，我们就可以使用系统调用，查看或干预进程运行的方方面面。

文件描述不是面向操作系统的，而是针对进程的，所以同一个文件在不同的进程可能有不同的fd，一个进程是不需要所有文件的，每当进程用到文件的时候，就向系统来要这个文件。对于进程来说，一个类似数组的东西就可以管理所有系统分配给他的文件，所以fd就是按自然数自增，0-标准输入，1-标准输出，2-标准错误是固定的，后面用到一次递增。

**项目异常处理-信号处理**

当项目遇到异常情况,这时候就需要发送一个**信号**给项目组，当收到信号时，对于一些不严重的信号，可以该干什么就干什么，但是像**SIGKILL**、**SIGSTOP**，可以执行该信号的默认动作。每种信号都定义有默认动作，例如硬件故障、默认终止；也可以提供信号处理函数，可以通过**sigaction**系统调用，注册一个信号处理函数

**项目组间沟通-进程间通信**

有多种不同的通信方式：

* 通过**msgget**在内核创建一个消息队列，**msgsnd**将消息发送到**消息队列**，而消息接收方可以使用**msgrcv**从队列中取消息
* 通过**shmget**创建一个**共享内存**块，通过**shmat**将共享内存映射到自己的内存空间

**共享内存**的方式，就会存在“竞争”，信号量机制**Semaphore**

**公司间沟通-网络通信**

内核里有对网络协议栈的实现，网络服务是通过套接字来提供的，通过**Socket**调用建立一个socket，socket也是一个文件，也是一个文件描述符，可以通过读写函数通信。

https://www.kernel.org

**Glibc**提供了丰富的API，除了提供例如字符串处理、数学运算等用户态服务之外，最重要的是封装了操作系统提供的系统服务，即**系统调用**的封装

每个特定的系统调用对应了至少一个Glibc封装的库函数

Glibc一个单独的API可能调用多个系统调用，多个API也可能对应同一个系统调用

**strace**--用来跟踪进程执行时系统调用和所接受的信号 **TODO:**

[操作系统导论 (豆瓣) (douban.com)](https://book.douban.com/subject/33463930/)

[搭建大型源码阅读环境——使用 OpenGrok - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/24369747)  **TODO:**



###### **2.x86架构**

开放的运营环境

<img src="..\images\1.webp" alt="img" style="zoom: 33%;" />

CPU包含3个部分：

**运算单元**：只管算，不知道应该算那些数据，运算结果应该放在那里

**数据单元**：运算单元计算的数据每次都要经过总线，到内存现拿，所以有了数据单元，包括CPU内部的缓存和寄存器组，可以暂时存放数据和运算结果

**控制单元**：是一个统一的指挥中心，可以获得下一条指令，然后执行这个指令

cpu控制单元有个**指令指针寄存器**，它里面存放的是下一条指令在内存中的地址。控制单元会不停的将代码段的指令拿进来，先放入指令寄存器。

总线主要有两类数据，一个是地址数据，也就是想拿内存中哪个位置的数据，**地址总线**；另一类是真正的数据，**数据总线**。

**地址总线**的位数，决定了能访问的地址范围到底有多广，能够访问位置越多，能管理的内存的范围就越广

**数据总线**的位数，决定一次能拿多少数据进来，一次拿的数据越多，访问速度就越快



x86平台的发展历史   **标准**  **开放**  **兼容**

IBM PC，采用英特尔的8080作为CPU，微软的MS-DOS做操作系统

IBM被迫公开一些技术

因此，英特尔的技术成为了行业的开放事实标准，由于这些系列开端于8086，因此称为x86架构

![img](..\images\2.jpg)

例如8086地址总线就有20位，数据总线只有16位

从8086到32位处理器：

通用寄存器有扩展，8个16位的扩展到8个32位，指令寄存器IP，也扩展成32位

改动比较大的就是**段寄存器**，CS、SS、DS、ES仍然是16位的。但是不再是段的起始地址。段的起始地址放在内存的某个地方。这个地方是一个表格，表格中的一项项是**段描述符**。这里面才是段的起始地址。而段寄存器存放的是这个表格中的哪一项，称为选择子。

因此在32位的系统架构下，前一种模式称为**实模式**，后一种称为**保护模式**



###### **3.系统启动**

BIOS时期

<img src="..\images\3.jpeg" alt="img" style="zoom:50%;" />

两个16位拼接成20位，最终是得到哪个数即可，最终得到的20位的串，能够标识位于哪个段，哪个单元

x86系统会将1M中最后一段映射到ROM，f0000-fffff

当电脑刚刚加电时，将cs设置为0xffff，将ip设置为0x0000，所以第一条指令就会指向0xffff0,正在ROM的范围。在这里有个JMP命令会跳到ROM中做初始化工作的代码

* 检查硬件是不是都是好的；
* 建立BIOS中断服务程序、中断向量表

BIOS需要从档案库门卫，慢慢打听操作系统的位置

操作系统在哪里呢？一般会安装在硬盘上，在BIOS的界面上可以看到一个启动盘的选项。启动盘有什么选项？它一般在第一个扇区，占512个字节，而且以0xAA55结束，当满足这个条件时，说明这是个启动盘，在512字节以内会启动**相关的代码**。

这些代码在linux里是由Grub2放进去的

grub2第一个安装的就是**boot.img**。它由boot.S编译而成，一共512字节，正式安装到启动盘的第一个扇区。这个扇区就被称为MBR。

BIOS完成任务后，会将**boot.img**从硬盘加载到内存0x7c00运行

由于512字节实在有限，boot.img做不了什么，最重要的一件事就是加载grub2的另一个镜像**core.img**

core.img就是管理处，由lzma_decompress.img、diskboot.img、kernel.img和一系列模块组成

<img src="..\images\2.webp" alt="img" style="zoom:30%;" />

boot.img先加载的是core.img的第一个扇区。如果是从硬盘启动的话，这个扇区就是diskboot.img,对应的代码是diskboot.S

boot.img将控制权交给diskboot之后。diskboot的任务就是将core.img中其他部分加载进来，显示解压缩程序lzma_decompress.img,再往下是kernel.img,最后是各个模块module对应的映像。不是linux的内核，而是grub的内核。

lzma_decompress.img对应的代码是startup_raw.S,本来kernel.img是压缩过的，现在执行的时候，需要解压缩。

在这之前，遇到的程序都非常小，完全可以在实模式下运行，但是随着运行的东西越来越大，lzma_decompress.img做了一个重要的决定，就是调用**real_to_prot**,切换到到保护模式。

切换到保护模式需要做的工作（大部分都与内存的访问相关）：

第一项是**启用分段**，就是在内存中建立起段描述符，将寄存器里的段寄存器变成段选择子，指向某个描述符，这样就能实现不同进程的切换了。

第二项是**启动分页**，能够管理的内存变大了，需要将内存分成相等大小的块

[A20 Gate 的历史原因_BakerTheGreat的博客-CSDN博客](https://blog.csdn.net/BakerTheGreat/article/details/107945857)

保护模式要打开Gate A20,也就是第21地址控制线 **TODO**:

接下来对压缩过的kernel.img解压缩，然后跳转到kernel.img开始运行

kernel.img对应的代码是startup.S以及一堆c文件，在startup.S中会调用grub.main,这是kernel的主函数。

在这个函数里，grub_load_config开始解析grub.conf中的配置信息；如果是正常启动，会调用grub_normal_execute函数，这个函数grub_show_menu会显示出让你选择的系统的列表。

一旦选中一个，就开始调用grub_menu_execute_entry,开始解析并执行选择的一项。

例如里面的linux16命令，表示装载指定的内核文件，并传递内核启动参数。于是，grub_cmd_linux被调用。它会首先读取整个linux内核镜像到内存。

如果配置里还有inittrd命令，用于为即将启动的内核传递init ramdisk路径，于是grub_cmd_initrd会被调用，将**initramfs**加载到内存中

当做完这一切之后，grub_command_execute("boot",0,0)才真正的启动内核。

《一个64位操作系统的设计与实现》

《从实模式到保护模式》

https://opensource.com/article/17/2/linux-boot-and-startup

https://opensource.com/article/17/3/introduction-grub2-configuration-linux

内核初始化

start_kernel,在init/main.c中

<img src="..\images\4.jpeg" alt="img" style="zoom:33%;" />

操作系统中，先要有个创始进程，有一行指令 set_task_stack_end(&init_task)。它是系统创建的第一个进程，称为**0号进程**，这是唯一一个没有通过fork或者kernel_thread产生的进程

第二个要初始化的是**办事大厅**。trap_init，里面设置了很多**中断门**，用于处理各种中断。其中有一个set_system_intr_gate(IA32_SYSCALL_VECTOR,entry_INT80_32),这是系统调用的中断门。系统调用也是通过发送中断的方式进行的。当然64位的有另外的系统调用方法。

第三个要初始化的是**会议室管理系统**，mm_init用来初始化内存管理模块

项目需要项目管理调度，需要执行一定的调度策略，sched_init用来初始化调度模块

vfs_caches_init会用来初始化基于内存的文件系统的rootfs。在这个函数里，会调用mnt_init()->init_rootfs().其中有一行代码，register_filesystem(&rootfs_fs_type)。在VFS虚拟文件系统里面注册了一种类型，定义为struct file_system_type rootfs_fstype

为了兼容各种各样的文件系统，需要将文件的相关数据结构和操作抽象出来，形成一个抽象对上提供统一的接口，即VFS(虚拟文件系统)。

最后调用的是rest_init(),进行其他方面的初始化

* 初始化**1号进程**，用kernel_thread(kernel_init,NULL,CLONE_FS)创建第二个进程，即1号进程。执行kernel_thread时，还在内核态

kernel_init里面调用kernel_init_freeable,里面有这样代码：

```
if (!ramdisk_execute_command)
    ramdisk_execute_command = "/init";

  if (ramdisk_execute_command) {
    ret = run_init_process(ramdisk_execute_command);
......
  }
......
  if (!try_to_run_init_process("/sbin/init") ||
      !try_to_run_init_process("/etc/init") ||
      !try_to_run_init_process("/bin/init") ||
      !try_to_run_init_process("/bin/sh"))
    return 0;
```

1号进程运行的时一个文件，如果打开run_init_process

```
static int run_init_process(const char *init_filename)
{
  argv_init[0] = init_filename;
  return do_execve(getname_kernel(init_filename),
    (const char __user *const __user *)argv_init,
    (const char __user *const __user *)envp_init);
}

do_execve->do_execveat_common->exec_binprm->searchbinary_handler

int search_binary_handler(struct linux_binprm *bprm)
{
  ......
  struct linux_binfmt *fmt;
  ......
  retval = fmt->load_binary(bprm);
  ......
}

static struct linux_binfmt elf_format = {
.module  = THIS_MODULE,
.load_binary  = load_elf_binary,
.load_shlib  = load_elf_library,
.core_dump  = elf_core_dump,
.min_coredump  = ELF_EXEC_PAGESIZE,
};

void
start_thread(struct pt_regs *regs, unsigned long new_ip, unsigned long new_sp)
{
set_user_gs(regs, 0);
regs->fs  = 0;
regs->ds  = __USER_DS;
regs->es  = __USER_DS;
regs->ss  = __USER_DS;
regs->cs  = __USER_CS;
regs->ip  = new_ip;
regs->sp  = new_sp;
regs->flags  = X86_EFLAGS_IF;
force_iret();
}
EXPORT_SYMBOL_GPL(start_thread);
```

最后做的是start_thread,将pt_regs（内核用来保存用户态运行上下文的），将用户态的代码段cs设置为_USER_CS,将用户态的数据段DS设置为_USER_DS,

这样就可以返回了，1号进程就完成了内核态到用户态的切换

一开始到用户态的是ramdisk的init，后来会启动真正根文件系统的init,成为所有用户态进程的祖先

initrd16 /boot/initramfs-3.10.0-862.e17.x86_64.img，这是一个基于内存的文件系统

init程序实在文件系统上的，文件是在一个存储设备上的。访问存储设备是需要驱动的，如果存储系统数目有限，驱动是可以放到内核里的。

但是存储系统越来越多，如果将所有存储系统的驱动都放到内核，那就太大了，因此只能先弄一个基于内存的文件系统。内存访问是不需要驱动的，就是ramdisk。然后运行ramdisk的/init。等它运行完了就已经在用户态。/init这个程序先根据存储系统的类型加载驱动，有了驱动就可以设置真正的根文件系统。有了真正的根文件系统，ramdisk上的/init会启动文件系统上的init。

* 创建2号进程，kernel_thread(kthread,NULL,CLONE_FS|CLONE_FILES),这里的kthreadadd负责所有的内核态的线程的调度和管理，是内核所有线程运行的祖先。

《庖丁解牛Linux内核分析》

[Source Insight 4.0 安装过程及简单使用_Alan的博客-CSDN博客](https://blog.csdn.net/qq_41290252/article/details/103689626)

[main.c - init/main.c - Linux source code (v5.15.2) - Bootlin](https://elixir.bootlin.com/linux/latest/source/init/main.c)

[Android 8.0 开机流程 (一) Linux内核启动过程_不羁的码农-CSDN博客](https://blog.csdn.net/mahang123456/article/details/88722948)

glibc有个syscalls.list,里面罗列着所有glibc的函数对应的系统调用

[**glibc源码分析**](.\glibc.md)

简单来将，syscall-template.S中定义了系统调用的调用方式

```
#define PSEUDO(name, syscall_name, args)                      \
  .text;                                      \
  ENTRY (name)                                    \
    DO_CALL (syscall_name, args);                         \
    cmpl $-4095, %eax;                               \
    jae SYSCALL_ERROR_LABEL
```

对于任何一个系统调用，最终都会调用DO_CALL

**32位系统调用过程**

i386 目录下的 sysdep.h 文件

```
/* Linux takes system call arguments in registers:
  syscall number  %eax       call-clobbered
  arg 1    %ebx       call-saved
  arg 2    %ecx       call-clobbered
  arg 3    %edx       call-clobbered
  arg 4    %esi       call-saved
  arg 5    %edi       call-saved
  arg 6    %ebp       call-saved
......
*/
#define DO_CALL(syscall_name, args)                           \
    PUSHARGS_##args                               \
    DOARGS_##args                                 \
    movl $SYS_ify (syscall_name), %eax;                          \
    ENTER_KERNEL                                  \
    POPARGS_##args

`# define ENTER_KERNEL int $0x80

ENTRY(entry_INT80_32)
        ASM_CLAC
        pushl   %eax                    /* pt_regs->orig_ax */
        SAVE_ALL pt_regs_ax=$-ENOSYS    /* save rest */
        movl    %esp, %eax
        call    do_syscall_32_irqs_on
.Lsyscall_32_done:
......
.Lirq_return:
  INTERRUPT_RETURN
```

通过push和SAVE_ALL将当前用户态的寄存器，保存到pt_regs结构里。

进入内核前，保存所有寄存器，然后调用do_syscall_32_irqs_on



```
static __always_inline void do_syscall_32_irqs_on(struct pt_regs *regs)
{
  struct thread_info *ti = current_thread_info();
  unsigned int nr = (unsigned int)regs->orig_ax;
......
  if (likely(nr < IA32_NR_syscalls)) {
    regs->ax = ia32_sys_call_table`[nr](
      (unsigned int)regs->bx, (unsigned int)regs->cx,
      (unsigned int)regs->dx, (unsigned int)regs->si,
      (unsigned int)regs->di, (unsigned int)regs->bp);
  }
  syscall_return_slowpath(regs);
}
```

对于系统调用结束之后，在entry_INT80_32之后，紧接着调用的是INTERRUT_RETURN

#define INTERRUPT_RETURN                iret

iret指令将原来用户态保护的现场恢复过来

**64位调用过程**

```
/* The Linux/x86-64 kernel expects the system call parameters in
   registers according to the following table:
    syscall number  rax
    arg 1    rdi
    arg 2    rsi
    arg 3    rdx
    arg 4    r10
    arg 5    r8
    arg 6    r9
......
*/
#define DO_CALL(syscall_name, args)                \
  lea SYS_ify (syscall_name), %rax;                \
  syscall
```

和32位不一样，这里是真正进行调用，而不是中断，改用syscall指令，传递参数的寄存器都变了。

syscall指令使用了一种特殊的寄存器-**特殊模块寄存器**，这种寄存器是CPU为了完成某些特殊控制功能为目的的寄存器。

系统初始化的时候，trap_init除了初始化了上面的中断模式，还会调用cpu_init->syscall_init

```
wrnmsrl(MSR_LSTR,(unsigned long)entry_SYSCALL_64);
```

rdmsr和wrmsr是用来读写特殊模块寄存器的。MSR_LSTAR就是这样一个特殊的寄存器，当syscall指令调用的时候，会从这个寄存器里面拿出函数地址调用，也就是调用entry_SYSCALL_64

在 arch/x86/entry/entry_64.S 中定义了 entry_SYSCALL_64。

```

ENTRY(entry_SYSCALL_64)
        /* Construct struct pt_regs on stack */
        pushq   $__USER_DS                      /* pt_regs->ss */
        pushq   PER_CPU_VAR(rsp_scratch)        /* pt_regs->sp */
        pushq   %r11                            /* pt_regs->flags */
        pushq   $__USER_CS                      /* pt_regs->cs */
        pushq   %rcx                            /* pt_regs->ip */
        pushq   %rax                            /* pt_regs->orig_ax */
        pushq   %rdi                            /* pt_regs->di */
        pushq   %rsi                            /* pt_regs->si */
        pushq   %rdx                            /* pt_regs->dx */
        pushq   %rcx                            /* pt_regs->cx */
        pushq   $-ENOSYS                        /* pt_regs->ax */
        pushq   %r8                             /* pt_regs->r8 */
        pushq   %r9                             /* pt_regs->r9 */
        pushq   %r10                            /* pt_regs->r10 */
        pushq   %r11                            /* pt_regs->r11 */
        sub     $(6*8), %rsp                    /* pt_regs->bp, bx, r12-15 not saved */
        movq    PER_CPU_VAR(current_task), %r11
        testl   $_TIF_WORK_SYSCALL_ENTRY|_TIF_ALLWORK_MASK, TASK_TI_flags(%r11)
        jnz     entry_SYSCALL64_slow_path
......
entry_SYSCALL64_slow_path:
        /* IRQs are off. */
        SAVE_EXTRA_REGS
        movq    %rsp, %rdi
        call    do_syscall_64           /* returns with IRQs disabled */
return_from_SYSCALL_64:
  RESTORE_EXTRA_REGS
  TRACE_IRQS_IRETQ
  movq  RCX(%rsp), %rcx
  movq  RIP(%rsp), %r11
    movq  R11(%rsp), %r11
......
syscall_return_via_sysret:
  /* rcx and r11 are already restored (see code above) */
  RESTORE_C_REGS_EXCEPT_RCX_R11
  movq  RSP(%rsp), %rsp
  USERGS_SYSRET64
```



```

__visible void do_syscall_64(struct pt_regs *regs)
{
        struct thread_info *ti = current_thread_info();
        unsigned long nr = regs->orig_ax;
......
        if (likely((nr & __SYSCALL_MASK) < NR_syscalls)) {
                regs->ax = sys_call_table[nr & __SYSCALL_MASK](
                        regs->di, regs->si, regs->dx,
                        regs->r10, regs->r8, regs->r9);
        }
        syscall_return_slowpath(regs);
}
```

无论32位，还是64位，都会调用到sys_call_table

**系统调用表**

32 位的系统调用表定义在 arch/x86/entry/syscalls/syscall_32.tbl 文件里。例如 open 是这样定义的：

```
5  i386  open      sys_open  compat_sys_open
```

第四列是系统调用在内核中实现的函数，都以sys_开头。

系统调用在内核中的实现函数要有一个声明。声明往往在include/linux/syscalls.h文件，如

```
asmlinkage long sys_open(const char __user *filename,int flags, umode_t mode);
```

而真正实现这个系统调用，一般在.c文件中，例如sys_open的实现在fs/open.c里

```
SYSCALL_DEFINE3(open, const char __user *, filename, int, flags, umode_t, mode)
{
        if (force_o_largefile())
                flags |= O_LARGEFILE;
        return do_sys_open(AT_FDCWD, filename, flags, mode);
}

#define SYSCALL_DEFINE1(name, ...) SYSCALL_DEFINEx(1, _##name, __VA_ARGS__)
#define SYSCALL_DEFINE2(name, ...) SYSCALL_DEFINEx(2, _##name, __VA_ARGS__)
#define SYSCALL_DEFINE3(name, ...) SYSCALL_DEFINEx(3, _##name, __VA_ARGS__)
#define SYSCALL_DEFINE4(name, ...) SYSCALL_DEFINEx(4, _##name, __VA_ARGS__)
#define SYSCALL_DEFINE5(name, ...) SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
#define SYSCALL_DEFINE6(name, ...) SYSCALL_DEFINEx(6, _##name, __VA_ARGS__)


#define SYSCALL_DEFINEx(x, sname, ...)                          \
        SYSCALL_METADATA(sname, x, __VA_ARGS__)                 \
        __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)


#define __PROTECT(...) asmlinkage_protect(__VA_ARGS__)
#define __SYSCALL_DEFINEx(x, name, ...)                                 \
        asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))       \
                __attribute__((alias(__stringify(SyS##name))));         \
        static inline long SYSC##name(__MAP(x,__SC_DECL,__VA_ARGS__));  \
        asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__));      \
        asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__))       \
        {                                                               \
                long ret = SYSC##name(__MAP(x,__SC_CAST,__VA_ARGS__));  \
                __MAP(x,__SC_TEST,__VA_ARGS__);                         \
                __PROTECT(x, ret,__MAP(x,__SC_ARGS,__VA_ARGS__));       \
                return ret;                                             \
        }                                                               \
        static inline long SYSC##name(__MAP(x,__SC_DECL,__VA_ARGS__)
        
声明实现都有了，在编译的过程中，需要根据syscall_32.tbl和syscall_64.tbl生成自己的unistd_32.h和unistd_64.h.

生成方式在 arch/x86/entry/syscalls/Makefile 中。这里面会使用两个脚本，其中第一个脚本 arch/x86/entry/syscalls/syscallhdr.sh，会在文件中生成 #define __NR_open；第二个脚本 arch/x86/entry/syscalls/syscalltbl.sh，会在文件中生成 __SYSCALL(__NR_open, sys_open)。这样，unistd_32.h 和 unistd_64.h 是对应的系统调用号和系统调用实现函数之间的对应关系。
```

在文件arch/x86/entry/syscall_32.c,定义了这样一个表，里面include了unistd_32.h。从而所有的系统调用都在这个表里

```

__visible const sys_call_ptr_t ia32_sys_call_table[__NR_syscall_compat_max+1] = {
        /*
         * Smells like a compiler bug -- it doesn't work
         * when the & below is removed.
         */
        [0 ... __NR_syscall_compat_max] = &sys_ni_syscall,
#include <asm/syscalls_32.h>
};
```



###### **4.进程管理**

《程序员的自我修养-链接、装载和库》---->resolved 已大概了解,二进制能玩儿的东西还有很多

c语言下的多线程:<Programming with POSIX Threads>

在linux里,无论是进程,还是线程,在内核里统一都叫Task,由一个统一的结构task_struct进行管理

<<浪潮之巅>>

```c
struct task_struct{
    //任何一个进程,如果只有主进程,pid tgid 都是自己,group_header指向自己;如果一个进程创建了其他线程,线程有自己的pid,tgid就是线程的
    //pid,group_header执行进程的主线程
    pid_t pid;
    pid_t tgid;
    struct task_struct* group_header;
    
    //signal_struct里还有一个struct sigpending shared_pending,这个是线程组共享的;下面的sighand是本任务的.
    struct signal_struct* signal;
    //正在通过信号函数进行处理
    struct sighand_struct* sighand;
 	//被阻塞,暂不处理
    sigset_t blocked;
    sigset_t real_blocked;
    sigset saved_sigmask;
    //尚等待待处理
    struct sigpending pending;
    //信号处理函数默认使用用户态的函数栈,当然也可以开辟新的栈专门用于信号处理,sas_ss_xxx这三个变量就起这个作用
    unsigned long sas_ss_sp;
    size_t sas_ss_size;
    unsigned int sas_ss_flags;
    
    //state定义在include/linux/sched.h头文件,state通过bitset设置的
     volatile long state;
    int exit_state;
    //PF_EXITING表示正在退出;PF_VCPU表示进程运行在虚拟CPU;PF_FORKNOEXEC表示fork完了,还没有exec
    unsigned int flags;
    
    //是否在运行队列上
    int on_rq;
    //优先级
    int prio;
    int static_prio;
    int normal_prio;
    unsigned int rt_priority;
    //调度器类
    const struct sched_class* sched_class;
    //调度实体
    struct shced_entity se;
    struct sched_rt_entiy rt;
    struct shced_dl_entity dl;
    //调度策略
    unsigned int policy;
    可以使用那些xpu
    int nr_cpus_allowed;
    cpumask_t cpus_allowed;
    struct sched_info sched_info;
    
    u64 utime;//用户态消耗的cpu时间
    u64 stime;//内核态消耗的cpu时间
    unsigned long nvcsw;//自愿上下文切换计数
    unsigned long nivcsw;//非自愿上下文切换计数
    u64 start_time;//进程启动时间,不包含睡眠时间
    u64 real_start_time;//进程时间,包含睡眠时间
    
    //进程亲缘关系TODO:这种声明是什么意思
    struct task_struct __rcu *real_parent;
    struct task_struct __rcu *parent;
    struct list_head children;
    struct list_haed sibling;
    
    //进程权限,大部分都是用户和用户所属的用户组信息uid gid SUID SGID EUID EGID FSUID FSGID  capabilities
    //谁能操作此进程
    const struct cred __rcu *read_cred;
    //此进程可以操作谁
    const struct cred __rcu *cred;
    
    //内存管理
    struct mm_struct *mm;
    struct mm_struct *active_mm;
    
    //文件与文件系统
    //Filesystem information
    struct fs_struct *fs;
    //Open file information
    struct files_struct *files;
    
    struct thread_info thread_info;
    //内核栈
    void *stack;
}
```

![image-20220112230956774](..\images\os\image-20220112230956774.png)

![image-20220112235605391](..\images\os\image-20220112235605391.png)

Linux给每个task都分配了内核栈,arch/x86/include/asm/page_32_types.h,arch/x86/include/asm/page_64_types.h

![image-20220113000214212](C:\Users\dmzc\Desktop\Learing\os\images\os\image-20220113000214212.png)

这段空间最低位置,是一个thread_info结构,与体系结构相关的,都放在thread_info里

```c
union thread_union{
    #ifndef CONFIG_THREAD_INFO_IN_TASK
    	struct thread_info thread_info;
    #endif
    unsigned long stack[THREAD_SIZE/sizeof(long)]
}
```

在内核栈的最高地址端,存放pt_regs,保存用户态寄存器值

通过内核栈中thread_info找到task_struct

```C
struct thread_info{
	struct task_struct *task;
    __uu32 flags;
    __uu32 status;
    __uu32 cpu;
    mm_sgement_t addr_limit;
    unsigned int sig_on_uaccess_error:1;
    unsigned intuaccess_err:1;
}
```

常用current_thread_info()->task获取task_struct

新的机制里,每个CPU运行的task_struct不通过thread_info获取,而是直接放到了Per CPU

Per CPU就是为每个CPU构造的一个变量副本,这样多个CPU各自操作自己的副本,当前进程的变量current_task就被声明为Per CPU变量

Per CPU变量使用方式:

* arch/x86/include/asm/current.h中声明:DECALARE_PER_CPU(struct task_struct *,current_task);
* arch/x86/kernel/cpu/common.c中定义:DEFINE_PER_CPU(struct task_struct *,current_task)=&init_task

系统刚初始化时,current_task都指向了init_task   当某个CPU上的进程进行切换时,current_task被修改为将要切换到的目标进程.例如,进程切换函数__switch_to就会改变current_task

要获取当前的运行中的task_struct时,就需要调用this_cpu_read_stable进行读取

![img](C:\Users\dmzc\Desktop\Learing\os\images\os\82ba663aad4f6bd946d48424196e515c.jpeg)

**实时调度策略**

SCHED_FIFO:高优先级的进程可以抢占低优先级的进程,相同优先级的进程,遵循先来先得的规则

SCHED_RR:采用时间片,相同优先级的任务当用完时间片会被放到队列尾部,以保证公平性,高优先级的任务可以抢占低优先级的任务

SCHED_DEADLINE:当产生一个调度点时,DL调度器总是选择其deadline距离当前时间点最近的哪个任务,并调度它执行

**普通调用策略**

SCHED_NORMAL:普通进程

SCHED_BATCH:后台进程,几乎不需要和前端进行交互

SCHED_IDLE:特别空闲时才跑的进程

task_struct->sched_class封装了调度策略的执行逻辑

**完全公平调度算法**

在linux里,实现了一个基于CFS的调度算法:

CFS为每个进程安排一个虚拟运行时间vruntime.如果一个进程在运行,随着时间的增长,进程的vruntime将不断增大,没有得到执行的进程vruntime不变.

vruntime=delte_exec*NICE_0_LOAD/权重,选取下一个进程运行的时候,还是按照最小的vruntime来的.

**调度队列与调度实体**

需要一个数据结构来对vruntime排序,为了兼顾频繁的查询和更新,使用红黑树,红黑树的一个节点应该包括vruntime,称为调度实体

完全公平算法调度实体sched_entity

```c
struct sched_entity{
    struct load_weight load;
    struct rb_node run_node;
    struct list_head group_node;
	unsigned int on_rq;
    u64 exec_start;
    u64 sum_exec_runtime;
    u64 vruntime;
    u64 prev_sum_exec_runtime;
    u64 nr_migrations;
    struct shced_statistics statistics;
}
```

**每个CPU都有自己的struct rq结构,其用于描述在此CPU上运行的所有进程,其包括一个实时进程队列rt_rq和一个CFS运行队列cfs_rq,在调度时,调度器首先会先去实时进程队列找是否有实时进程需要运行,如果没有才会去CFS运行队列找是否有进程需要运行.**

```c
struct rq{
    raw_spinlock_t lock;
    unsigned int nr_running;
    unsigned long cpu_load[CPU_LOAD_IDX_MAX];
    struct load_weight load;
    unsigned long nr_load_updates;
    u64 nr_switches;
    struct cfs_rq csf;
    struct rt_rq rt;
    struct dl_rq dl;
    struct task_struct *curr,*idle,*stop;
}
```

对于普通进程公平队列cfs_rq

```c
struct cfs_rq{
    struct load_wieght load;
    unsigned int nr_running,h_nr_running;
    u64 exec_clock;
    u64 min_vruntime;
    #ifndef CONFIG_64BIT
    	u64 min_vruntime_copy
    #endif
      struct rb_root tasks_timeline;
      struct rb_node *rb_leftmost;
      struct shced_entity *curr,*next,*last,*skip;
} 
```

```c++
struct sched_class {
    const struct sched_calss * next;
    void(*enqueue_task) (struct rq *rq,struct task_struct *p,int flags);
    void(*dequeue_task) (struct rq *rq,struct task_struct *p,int flags);
    void(*yeild_task) (struct rq *rq);
    bool(*yeild_to_task) (struct rq *rq,struct task_struct *p,bool preempt);
    void (*check_preempt_curr) (struct rq *rq,struct task_struct *p,int flags);
    struct task_struct * (*pick_next_task) (struct rq *rq,struct task_struct *prev,struct rq_flags *rf);
    void (*put_prev_task) (struct rq *rq,struct task_struct *p);
    
    //修改调度策略
    void (*set_curr_task) (struct rq *rq);
    //每次周期性时钟到,此函数被调用,可能触发调度
    void (*task_tick) (struct rq *rq,struct task_struct *p,int queued);
    void (*task_fork) (struct  *p);
    void (*task_dead) (struct task_struct *p);
    
    void (*switched_from) (struct rq *this_rq,struct task_struct *task);
    void (*switched_to) (struct rq *this_rq,struct task_struct *task);
    void (*prio_changed) (struct rq *this_rq,struct task_struct *task,int oldprio);
    unsigned int(*get_rr_interval) (struct rq *rq,struct task_struct *task);
    void (*update_curr) (struct rq *rq);
}
```

此结构定义了很多方法,用于在队列上操作任务

每个CPU都有一个队列rq，这个队列里面包含多个子队列，例如rt_rq和cfs_rq，不同队列有不同的实现方式，cfs_rq就是用红黑树实现的。

当CPU需要找下一个任务执行时，会按照优先级依次调用调度类，不同的调度类操作不同的队列

**主动调度**

计算主要是CPU和内存的合作；网络和存储则多是和外部设备的合作；操作外部设备时，往往需要让出CPU，此时就会选择调用schedule函数

```c++
asmlinkage __visible void __sched schedule(void){
  struct task_struct *tsk = current;
  sched_submit_work(tsk);
  do{
    preempt_disable();
    __schedule(false);
    sched_preempt_enable_no_resched();
  }while(need_resched());
}
```

主要逻辑在__schedule函数

```c++
static void __sched notrace __schedule(bool preempt){
  struct task_struct *prev,*next;
  unsigned long *switch_count;
  struct rq_flags rf;
  struct rq *rq;
  int cpu;
  
  cpu=smp_processor_id();
  rq=cpu_rq();
  prev=rq->curr;
  
  next=pick_next_task(rq,prev,&rf);
  clear_tsk_need_resched(prev);
  clear_preempt_need_resched();
}
```

```c++
static inline struct task_struct * pick_next_task(struct rq *rq,struct task_struct *prev,struct rq_flags *rf,){
  const struct sched_class *class;
  struct task_struct *p;
  if(likely((prev->sched_class==&idle_sched_class||
           prev->sched_class==&fair_sched_class)&&
    	rq->nr_running==rq->cfs.h_nr_running){
    	p=fair_sched_class.pick_next_task(rq,prev,rf);
    	if(unlikely(p==RETRY_TASK))
          goto again;
    	if(unlikely(!p))
      		p=idle_sched_class.pick_next_task(rq,prev,rf);
         return p；
  }
  again:
     for_each_class(class){
       p=class->pick_next_task(rq,prev,rf);
       if(p){
         if(unlikely(p==RETRY_TASK))
           goto again;
         return p;
       }
     }
}
```

fair_sched_class.pick_next_task调用pick_next_task_fair

取出当前的正在运行的任务curr，如果依然是可运行状态，则调用update_curr更新vruntime。

接着pick_next_entity从红黑树里，去取最左边的一个节点。如果发现继任和前任不一样，说明有一个需要运行的进程，就需要更新红黑树，前面前任的已经更新过，只需要调用put_prev_entity将其放回红黑树，然后调用set_next_entity将继任者设置为当前任务。

当选出的继任和前任不同，就要进行上下文切换,继任者进程正式进入运行

```c++
if(likely(prev!=next)){
  rq->nr_switches++;
  rq->curr=next;
  ++*switch_count;
  
  rq=context_switch(rq,prev,next,&rf);
}
```

**进程下上下切换**

切换进程空间（虚拟内存）；切换寄存器和CPU上下文

```c++
static __always_inline struct rq *context_switch(struct *rq,struct task_struct *prev,struct task_struct *next,struct rq_flags *rf){
	struct mm_struct *mm,*oldmm;
  	mm=next->mm;
  	oldmm=prev->active_mm;
  	switch_mm_irqs_off(oldmm,mm,next);
  	switch_to(prev,next,prev);
  	barrier();
  return finish_task_switch(prev);
}
```

```assembly
ENTRY(__switch_to_asm)
	.......
	movl %esp,TASK_threadsp(%eax)
	movl TASK_threadsp(%edx),%esp
	.......
	jmp __switch_to
END(__switch_asm_to)
```



x86体系结构中，提供一种以硬件的方式进行进程切换的模式，对于每个进程，**x86希望在内存里维护一个TSS**（Task State Segment,任务状态段）结构。这里有所有的寄存器。

还有一个特殊的**寄存器TR(Task Register,任务寄存器)，指向某个进程的TSS。**更改TR的值，将会触发硬件保存CPU所有寄存器的值到当前进程的TSS，然后从**新进程的TSS**中读出所有寄存值，加载到CPU对应的寄存器中。

但是这样做进程切换时，都会全量切换和保存

linux操作系统的解决方法：cpu_init给每一个CPU关联一个TSS，然后将TR指向这个TSS，然后在操作系统的运行过程中，TR就不切换了，永远指向这个TSS。

```c++
void cpu_init(void){
  int cpu = smp_processor_id();
  struct task_struct *curr = current;
  struct tss_struct *t = &per_cpu(cpu_tss,cpu);
  load_sp0(t,thread);
  set_tss_desc(cpu,t);
  load_TR_desc(); 
}
struct tss_struct{
  struct x86_hw_tss x86_tss;
  unsigned long io_bitmap[IO_BITMAP_LONGS + 1];
}
```

task_struct中有一个thread_struct变量，这里保留了要进程切换的时候需要修改的值****

**进程A切换到进程B的过程：**

进程A在用户态写一个文件，通过系统调用陷入内核，这个切换的过程，用户态的指令寄存器是保存在内核栈的pt_regs里。

到了内核态，就开始沿着写文件的逻辑一步一步执行，发现需要等待，就调用__schedule函数，此时，进程A在内核态的指令指针是指向 _schedule。

_schedule经过层层调用，到达了context_switch的最后三条指令（其中barrier语句是一个编译器指令，用于保证switch_to和finish_task_switch的执行顺序，不会因为编译阶段优化而改变）

当进程A在内核里执行switch_to的时候，内核态的指令指针也是指向这一行的。但是在switch_to里面，将寄存器和栈都切换成了进程B的，唯一没有变的就是指令指针寄存器。当switch_to返回的时候，指令指针寄存器指向了下一条语句finish_task_switch。

此时的finish_task_switch已经不是进程A的finish_task_switch了，而且进程B的finish_task_switch。

**之前B进程被别人切换的时候，也是调用__schedule,也是switch_to,被切换到其他进程，所以，B进程当年的下一条指令也是finish_task_swicth**

**抢占式调度**

一个进程执行时间太长了，切换到另一个进程。计算机中有一个时钟，会过一段时间触发一次时间中断，通知操作系统。时钟中断函数会调用scheduler_tick

```c++
void scheduler_tick(void){
    int cpu=smp_processor_id();
    struct rq *rq=cpu_rq(cpu);
    struct task_struct *curr=rq->curr;
    ......
    curr->sched_class->task_tick(rq,curr,0);
    cpu_load_update_active(rq);
    calc_global_load_tick(rq);
}
```

根据当前进程的task_struct,找到对应的调度实体sched_entity和cfs_rq队列，调用entity_tick。

```c++
static void entity_tick(struct cfs_rq *cfs_rq,struct sched_entity *curr,int queued){
    update_curr(cfs_rq);
    update_load_avg(curr,UPDATE_TG);
    update_cfs_shares(curr);
    if(cfs_rq->nr_running>1)
        check_preempt_tick(cfs_rq,curr);
}
//在entity_tick里，会更新当前进程的vruntime，然后调用check_preempt_tick(检查是否是时候被抢占了)
static void check_preempt_tick(struct cfs_rq *cfs_rq,struct sched_entity *curr){
    unsigned long ideal_runtime,delta_exec;
    struct sched_entity *se;
    s64 delta;
  	//一个调度周期中，该进程的实际运行时间  
    //TODO:抢占式调度真正发生的时机，这里是怎么计算的
    ideal_runtime = sched_slice(cfs_rq,curr);
    delta_exec = curr->sum_exec_runtime - curr->prev_sum_exec_runtime;
    if(delta_exec > ideal_runtime){
        resched_curr(rq_of(cfs_rq));
        return;
    }
    ......
    se = __pick_first_entity(cfs_rq);
    delta = curr->vruntime - se->vruntime;
    if(delta < 0){
        resched_curr(rq_of(cfs_rq));
    }
}
```

发现当前进程应该被抢占，不能直接把它踢下来，而是把它标记为应该被抢占。调用resched_curr，他会set_tsk_need_resched,标记进程应该被抢占。TIF_NEED_RESCHED。

另外一个可能被抢占的场景是**当一个进程被唤醒的时候**

**真正的抢占时机**

用户态的抢占时机，从系统调用返回的那个时刻，是一个抢占的时机。从中断返回的时刻，也是一个被抢占的时机。

**exit_to_usermode_loop,判断如果被打了_TIF_NEED_RESCHED,就调用schedule进行调度**

对内核态的执行中，被抢占的时机一般发生在preempt_enable()中

在内核态的执行中，有的操作是不能被中断的，所以在执行这些操作之前，总是先调用preempt_disable()关闭抢占，当再次打开的时候，就是一次内核态代码被抢占的机会。

**进程创建**

fork调用，sys_fork,调用_do_fork

dup_task_struct中主要做了下面几件事：

* alloc_task_struct_node分配一个task_struct结构；
* 调用alloc_thread_stack_node创建内核栈，这里面调用__vmalloc_node_range分配一个连续的THREAD_SIZE的内存空间，赋值给task_struct的void *stack成员变量；
* 调用arch_dup_task_struct(struct task_struct *dst,struct task_struct *src),将task_struct进行复制，其实就是调用memcpy；
* 调用setup_thread_task设置thread_info

copy_creds主要做了下面几件事：

* 调用prepare_creds,准备一个新的struct cred *new(从内存分配一个cred结构，然后调用memcpy复制一份父进程的cred)；然后将新进程的两个权限都指向新的cred

copy_process重新设置进程运行的统计量

copy_process开始设置调度相关的变量 retval=sched_fork(clone_flags,p)

​      调用_sched_fork,将on_rq设为0，初始化sched_entity,将里面的exec_start、sum_exec_runtime、prev_sum_exec_runtime、vruntime都设为0。设置进程的状态、设置进程优先级、设置调度类。调用调度类的task_for函数，对于CFS来讲，先调用update_curr,对于当前的进程进行统计量更新，然后把子进程和父进程的vrnutime设成一样，最后调用place_entity,初始化sched_entity。这里有一个变量sysctl_sched_child_runs_first,可以设置父进程和子进程谁先运行。

接下来，copy_process开始初始化与文件和文件系统相关的变量

​	retval=copy_files(clone_flags);

​	retval=copy_fs(clone_flags,p);

copy_files用于复制一个进程打开的文件信息，files_struct

copy_fs用于复制一个进程的目录信息,fs_struct来维护。一个进程有自己的根目录和根文件系统root，也有当前目录pwd和当前目录的文件系统，都在fs_struct里维护。

copy_process开始初始化与信号相关的变量

​	init_sigpending(&p-<pending);

​	retval = copy_sighand(clone_flags,p);

​	retval = copy_signal(clone_flags,p);

copy_process接下来复制进程内存空间

​	retval = copy_mm(clone_flags,p)

接下来，copy_process开始分配pid，设置tid，group_leader,并且建立进程之间的亲缘关系

复制完毕后，就要**唤醒新进程**

```c++
void wake_up_new_task(struct task_struct *p){
    struct rq_flags rf;
    struct rq *rq;
    ......
    p->state = TASK_RUNNING;
   .......
   activate_task(rq,p,ENQUEUE_NOCLOCK);
   p->on_rq = TASK_ON_RQ_QUEUED;
   trace_sched_wakeup_new(p);
   check_preempt_curr(rq,p,WF_FORK);
}
```

**创建线程**

线程不是一个完全由内核实现的机制，由内核态和用户态合作完成的。pthread_create不是一个系统调用，是Glibc库的一个函数。

首先处理线程的属性参数。

接下来，就像在内核里一样，每一个进程或线程都有一个task_struct结构，在用户态也有一个用于维护线程的结构，就是pthread

凡是涉及函数的调用，都要使用栈，每个线程都有自己的栈，接下来就是创建线程栈

* 为了防止栈越界，会在栈的末尾会有一块guardsize
* 线程栈是在进程的堆里面创建的，是应该有缓存的
* 如果没有缓存里没有，就需要调用__mmap创建一块新的
* 线程栈也是自顶向下生长的，pthread结构也是放到栈空间里的，在栈底位置。
* 计算出guard内存位置，调用setup_stack_prot设置这块内存
* 接下来，开始填充pthread这个结构里的成员变量stackblock、stackblock_size、guardsize、specfic。这里s'pecific是用于存放Thread Specific Data的，也即属于线程的全局变量；
* 将这个线程栈放到stack_used链表中，其实管理线程栈总共两个链表，一个是stack_used,也就是这个栈正被使用；另一个是stack_cache,一旦线程结束，先缓存起来，不释放

真正创建线程的函数

```c++
static int create_thread(struct pthread *pd,const struct pthread_attr *attr,bool *stopped_start,STACK_VARIABLES_PARMS,bool *thread_ran){
    const int clone_flags=(CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SYSVSEM | CLONE_SIGHAND | CLONE_THREAD  | CLONE_SETTLS | CLONE_PARENT_SETTID | CLONE_CHILD | 0);
  ARCH_CLONE(&start_thread,STACK_VARIABLES_ARGS,clone_flags,pd,&pd->tid,tp,&pd->tid);
   *thread_ran=true;
}
```

ARCH_CLONE,其实调用的是__clone,其中就会调用 _do_fork，其中复杂标志的设定，影响一下步骤：

* 对于copy_files、copy_fs、copy_sighand、copy_mm,原来是调用dup_fd复制一个files_struct,现在将原来的files_struct引用计数加一。
* 对于copy_signal,原来是创建一个新的signal_struct,现在因为CLONE_THREAD，直接返回，而因为有了这个标识，使得亲缘关系有了一定的变化

clone在内核的调用完毕，要返回系统调用，回到用户态

根据__clone的第一个参数，回到用户态调用通用的start_thread，这是所有线程在用户态的统一入口。

```c++
#define STRAT_THREAD_DEFN
	static int __attribute__((noreturn)) start_thread (void *arg)
START_THREAD_DEFN
    {
        struct pthread *pd	= START_THREAD_SELF;
        /*Run the code the user provided**/
        THRAD_SETMEM(pd,result,pd->start_routine(pd->arg));
        /**
         * Call destructors for the thread_local TLS variables
         * Run the destructor for the thread-local data.
         */
        __nptl_deallocate_tsd();
        if(__glibc_unlikely(atomic_decrement_and_test(&__nptl_nthreads)))
            exit(0);
        __free_tcb();
        __exit_thread();
    }
```

**内存管理**

物理内存的管理、虚拟地址的管理、虚拟地址和物理地址如何映射

从最低位排起，先是**Text Segment、Data Segment和BBS Segment**；接下来是**堆**，堆是往高地址增长的；接下来的区域**Memory Mapping Segment**，这块可以用来把文件映射进内存用，如果二进制的执行文件**依赖于某个动态链接库**；**栈地址段**，主线程的函数调用的函数栈。

到了内核，无论是哪个进程进来的，看到的都是同一个内核空间，看到的都是同一个进程列表

内核的代码访问内核的数据结构，大部分的情况下都是使用虚拟地址的，虽然内核代码权限很大，但是能够使用的虚拟地址范围也只能在内核空间，也即内核代码访问内核数据结构。

[现代操作系统内存管理到底是分段还是分页，段寄存器还有用吗？ - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/409754117)

进入32位时代后，有了些变化：

* 32位时代，段寄存器增加了两个：**fs、gs**，这两个寄存器有特殊用途
* 段寄存器存放的不在是段基地址，而是**段选择子**

段寄存器存放是一个号码，是一个表格中**表项的号码**。这个表，有可能是**全局描述表GDT**，也有可能是**局部描述表LDT**。

到底是哪个表？是由段选择子从低到高的第三位来决定的，如果这一位是0，则是**GDT**，否则就是**LDT**。

这两个表的表项叫做段描述符，描述了一个内存段的信息。CPU单独添置了两个寄存器，用来指向两个表，分别是gdtr和ldtr

寻址时，CPU首先根据段寄存器中的号码，通过gdtr或ldtr来到GDT/LDT中取出对应的段描述符，然后在取出这个段的基地址，最后再结合段内的偏移，完成内存寻址。

**无论是分段还是分页，这都是x86架构CPU的内存管理机制，这俩是同时存在的（保护模式下），并不是让操作系统二选一**

​       **进程的代码段、数据段、栈段、扩展段这四个段全部重合了，而是整个进程地址空间共计4GB成为一个段**

Intel 64指令手册

In 64-bit mode:CS,DS,ES,SS are threated as if each segment base is 0,regardless of the value of the associated segment descriptor base.

```c++
#define GDT_ENTRY_INIT(flags, base, limit) { { { \
    .a = ((limit) & 0xffff) | (((base) & 0xffff) << 16), \
    .b = (((base) & 0xff0000) >> 16) | (((flags) & 0xf0ff) << 8) | \
      ((limit) & 0xf0000) | ((base) & 0xff000000), \
  } } }

DEFINE_PER_CPU_PAGE_ALIGNED(struct gdt_page,gdt_page)={.gdt={
 #ifdef CONFIG_X86_64
    [GDT_ENTRY_KERNEL32_CS] = GDT_ENTRY_INIT(0xc09b,0,0xfffff),
    [GDT_ENTRY_KERNEL_CS] = GDT_ENTRY_INIT(0xa09b,0,0xfffff),
    [GDT_ENTRY_KERNEL_DS] = GDT_ENTRY_INIT(0xc093,0,0xfffff),
    [GDT_ENTRY_DEFAULT_USER32_CS] = GDT_ENTRY_INIT(0xc0fb,0,0xfffff),
    [GDT_ENTRY_DEFAULT_USER_DS] = GDT_ENTRY_INIT(0xc0f3,0,0xfffff),
    [GDT_ENTRY_DEFAULT_USER_CS] = GDT_ENTRY_INIT(0xa0fb,0,0xfffff),
 #else
    [GDT_ENTRY_KERNEL_CS] = GDT_ENTRY_INIT(0xc09a,0,0xfffff),
    [GDT_ENTRY_KERNEL_DS] = GDT_ENTRY_INIT(0xc092,0,0xfffff),
    [GDT_ENTRY_KERNEL_DEFAULT_USER_CS] = GDT_ENTRY_INIT(0xc0fa,0,0xfffff),
    [GDT_ENTRY_KERNEL_DEFAULT_USER_DS] = GDT_ENTRY_INIT(0xc0f2,0,0xfffff),
    .......
 #endif
}};
EXPORT_PER_CPU_SYMBOL_GPL(gdt_page)
```

//TODO:GDT、LDT表项结构？？？？？

定义了内核代码段、内核数据段、用户代码段和用户数据段，还会定义以下4个段选择子

```c++
#define __KERNEL_CS (GDT_ENTRY_KERNEL_CS*8)
#define __KERNEL_DS (GDT_ENTRY_KERNEL_DS*8)
#define __USER_DS (GDT_ENTRY_DEFAULT_USER_DS*8 + 3)
#define __USER_CS (GDT_ENTRY_DEFAULT_USER_CS*8 + 3)
```

Linux下，所有段的起始地址都是一样的，为0。在Linux操作系统中，并没有使用到分段的全部功能，分段可以做权限审核。

Linux倾向于**分页**的内存管理方式

前10位定位到页目录项中的一项。将这一项对应的页表取出来共1k项，在用中间10位定位到页表中一项，将这一项对应的存放数据的页取出来，在用12位定位到页中的具体位置访问数据。

只给进程分配一个数据页，如果只使用页表，也需要4M的内存；如果使用页目录，页目录需要1K个全部分配，占用4K，但里面只有一项使用。到了页表项，只需要分配能够管理哪个数据页的页表项页就可以了。

对于64位系统，就变成了4级目录



current->mm->task_size = TASK_SIZE

对于32位系统，最大能寻址4G，用户态虚拟地址空间3G，内核态1G

对于64位系统，虚拟地址只用了48位，用户态空间和内核空间都是128T，之间隔着很大的空隙，以此来进行隔离。

mm_struct定义了虚拟内存区域的统计信息和位置

```c++
//用于内存映射的起始地址，一般情况，从高地址到低地址增长的
unsigned long mmap_base;
//总共映射的页的数目
unsigned long total_vm;
//被锁定不能被换出
unsigned long locked_vm;
//不能换出，也不能移动
unsigned long pinned_vm;
//存放数据的页的数目
unsigned long data_vm;
//存放可执行文件的页的数目
unsigned long exec_vm;
//栈所占的页的数目
unsigned long stack_vm;
//分别代表可执行代码、已初始化数据的开始和结束位置
unsigned long start_code,end_code,start_data,end_data;
//堆的起始、结束位置，栈的起始位置
unsigned long start_brk,brk,start_stack;
//参数列表和环境变量的位置
unsigned long arg_start,arg_end,env_start,env_end;
```

task_struct有以下结构：

```c++
//单链表，用于将这些区域串起来
struct vm_area_struct *mmap;/** list of VMAs */
//红黑树节点，便于快速查找一个内存区域
struct rb_root mm_rb;
```

```c++
struct vm_area_struct{
    //该区域在用户空间中起始和结束地址
    unsigned long vm_start;
    unsigned long vm_end;
    //将这个区域串到链表
    struct vm_area_struct *vm_next,*vm_prev;
    //将这个区域放到红黑树
    struct rb_node vm_rb;
    struct mm_struct *vm_mm;
    //对这个内存区域可以做的操作的定义
    const struct vm_operations_struct *vm_ops;
    //虚拟内存区域可以映射到物理内存，也可以映射到文件，映射到文件就需要vm_file指定
    struct list_head anon_vma_chain;
    struct anon_vma *anon_vma;
    struct file *vm_file;
    void * vm_private_data;
} __randomize_layout
```

```c++
static int load_elf_binary(struct linux_binprm *bprm){
    ......
 	  //设置内存映射区mmap_base
      setup_new_exec(bprm);
    ......
      //设置栈的vm_area_struct
      retval = setup_arg_pages(bprm,randomize_stack_top(STACK_TOP),executable_stack);
      //将ELF文件中的代码部分映射到内存中来
      error = elf_map(bprm->file,load_bias + vaddr,elf_ppnt,elf_prot,elf_flags,total_size);
      //设置堆的vm_area_struct
      retval = set_brk(elf_bss,elf_brk,bss_prot);
      //将依赖的so映射到内存中的内存映射区域
      elf_entry = load_elf_interp(&loc->interp_elf_ex,
                                  interpreter,
                                  &interp_map_addr,
                                  load_bias,
                                  interp_elf_phdata);
    current->mm->end_code = end_code;
    current->mm->start_code = start_code;
    current->mm->start_data = start_data;
    current->mm->end_data = end_data;
    current->mm->start_stack = bprm->p;
}
```

映射完毕后，一下情况会修改：

* 函数的调用，涉及到函数栈的改变
* 通过malloc申请一个堆内的空间，底层要么执行brk，要么执行mmap

brk系统调用实现入口是sys_brk函数

```c++
SYSCALL_DEFINE1(brk,unsigned long,brk){
    unsigned long retval;
    unsigned long newbrk,oldbrk;
    struct mm_struct *mm = current->mm;
    struct vm_area_struct *next;
    //将原来的堆顶和现在的堆顶，都按照页对齐地址
    newbrk = PAGE_ALIGN(brk);
    oldbrk = PAGE_ALIGN(mm->brk);
    //如果对齐后的相同，说明增加的很少，不需要另外分配页
    if(oldbrk == newbrk)
        goto set_brk;
    //如果新堆顶小于就堆顶，则是释放内存，至少释放了一页，调用do_munmap将这一页的内存映射去掉
    if(brk <= mm->brk){
        if(!do_munmap(mm,newbrk,oldbrk-newbrk,&uf))
            goto set_brk
        goto out;
    }
    //堆要扩大，找到原堆顶所在的vm_area_struct的下一个vm_area_struct，看当前的堆顶和下一个vm_area_struct之间还能不能分配	一个完整的页
    next = find_vma(mm,oldbrk);
 	//如果能分配一个完整的页，则调用do_brk进一步分配堆空间
    if(next && newbrk + PAGE_SIZE > vm_start_gap(next))
        goto out;
    if(do_brk(oldbrk,newbrk-oldbrk,&uf) < 0)
        goto out;
    set_brk:
    	mm->brk = brk;
    	return brk;
    out:
    	retval = mm->brk;
    	return retval;
}
```

内核态布局

![image-20220130000413003](os.assets/image-20220130000413003.png)

**直接映射区**：就是这一块空间是连续的，和物理内存是非常简单的映射关系

__pa(vaddr)返回与虚拟地址vaddr相关的物理地址

__va(paddr)计算出对应于物理地址paddr的虚拟地址

对于直接映射区，系统启动时，物理内存的前1M已经被占用了，从1M开始加载内核代码段，然后就是内核的全局变量、BSS等，具体内存布局可以查看/proc/iomem

在内核运行过程中，如果碰到系统调用创建进程，会创建task_struct这样的实例，内核的进程管理代码会将实例创建在3G至3G+896M的虚拟空间中，当然能也会被放在物理内存里面的前面896M，相应的页表也会被创建。

内核栈也被分配在896M的空间

* VMALLOC_START到VMALLOC_END之间称为内核动态映射空间，也即内核像用户进程一样malloc申请内存
* PKMAP_BASE到FIXADDR_START的空间称为持久内核映射。使用alloc_pages，在物理内存的高端内存得到struct page结构，可以调用kmap将其映射到这个区域
* FIXADDR_START到FIXADDR_TOP的空间，称为固定映射区域，主要用于满足特殊需求

最后一个区域可以通过kmap_atomic实现临时内核映射。把文件内容写入物理内存，需要内核来处理，只好通过kmap_atomic做一个临时映射，写入物理内存完毕后，在kunmap_atomic解映射即可。

![image-20220130004835043](os.assets/image-20220130004835043.png)



**物理内存的组织方式**

平坦内存模型：物理地址是连续的，页也是连续的。每个页有一个结构struct page

这种模式下，CPU会有多个，在总线的一侧，所有的内存条组成一大片内存，在总线的另一侧，所有的CPU访问都要过总线，而且距离都是一样的，这种模式称为**SMP**（对称多处理器）

为了提高性能和可扩展性，有了一种更高级的模式，**NUMA**（Non-uniform memory access）,非一致内存访问。

这种模式下，内存不再是一整块，每个CPU和内存在一起，称为一个NUMA节点。但是，本地内存不足的情况下，每个CPU都可以去另外的NUMA节点申请内存，这时访问延时就会比较长。

内存被分成了多个节点，每个节点再被分成一个个页面。由于页需要全局唯一定位，页还是需要有全局唯一的页号的。但是由于物理内存不连续，页号就不在连续，内存模型就变成了非连续内存模型。

NUMA往往是非连续内存模型，而非连续内存模型不一定就是NUMA

**稀疏内存模型** TODO:

```c++
typedef struct pglist_data{
    
    struct zone node_zones[MAX_NR_ZONES];
   	//备用节点和它的内存区域的情况
    struct zonelist node_zonelists[MAX_ZONELISTS];
    //当前节点的区域的数量
    int nr_zones;
    //节点的struct page数组，用于描述这个节点里的所有的页
    struct page *node_mem_map;
    //这个节点的起始页号
    unsigned long node_start_pfn;
    //这个节点中包含不连续的物理内存地址的页面数
    unsigned long node_present_pages;
    //真正可用的物理页面的数目
    unsigned long node_spanned_pages;
    //节点id
    int node_id;
}pg_data_t;
```

每一个节点分成一个个区域，放在数组node_zones里，zone的定义：

```c++
enum zone_type{
    #ifdef CONFIG_ZONE_DMA
    	//用作DMA
    	ZONE_DMA,
    #endif
   	//对于64位，有DMA、DMA32两个
    #ifdef CONFIG_ZONE_DMA32
    	ZONE_DMA32,
    #endif
    	//直接映射区
  		ZONE_NORMAL,
    #ifdef CONFIG_HIGHMEM
    	//高端内存区
    	ZONE_HIGHMEM,
    #endif
    	//可移动区域，通过将物理内存划分为可移动分配区域和不可移动分配区域来避免内存碎片
        ZONE_MOVABLE,
    	__MAX_NR_ZONES
 }
```

```c++
struct zone{
 struct pglist_data *zone_pgdat;
 //用于区分冷热页
 struct per_cpu_pageset __percpu *pageset;
 unsigned long zone_start_pfn;
 //这个zone被伙伴系统管理的所有的page数目
 unsigned long managed_pages = present_pages - reserved_pages;
 unsigned long spanned_pages = zone_end_pfn - zone_start_pfn;
 //这个zone在物理内存中真实存在的所有page数目
 unsigned long present_pages = spanned_pages - absent_pages;
 
 const char *name;
 struct free_area free_area[MAX_ORDER];
 unsigned long flags;
 spinlock_t lock;
} ____cacheline_internodealigned_in_
```

页的数据结构struct page,里面有很多union，同一块内存根据情况保存不同类型数据，是因为一个物理页面使用模式有多种。

##### 第一种模式

要用就用一整页。这一整页的内存，或者**直接和虚拟地址空间建立映射关系**，称为匿名页；或者用于**关联一个文件**，然后再和虚拟地址空间建立映射关系（称为内存映射文件）。

如果是这种模式，使用到union中以下变量：

* struct address_space *mapping,用于内存映射，如果是匿名页，最低位为1；如果是映射文件，最低位为0；
* pgoff_t index是在映射区的偏移量；
* atomic_t mapcount,每个进程都有自己的页表，这里指多少个页表项指向这个页
* struct list_head lru,表示这一页应该在一个链表上
* compound相关的变量用于复合页，就是将物理上连续的两个或多个页看成一个独立的大页

##### 第二种模式

仅需分配小块内存，为了满足小内存块的需求，Linux系统采用了**slab  allocator**的技术，用于分配称为slab的一小块内存。基本原理是从内存管理模块申请一整块页，然后划分成多个小块的存储池，用复杂的队列来维护这些小块的状态（被分配了 / 被放回池子 / 应该被回收）

如果某一页是用于分割成一小块一小块的内存进行分配的使用模式，则会使用union中以下变量：

* s_mem 已经分配了正在使用的slab的第一个对象
* freelist 池子中的空闲对象
* rcu_head 需要释放的列表

要分配比较大的内存，如分配页级别的，可以使用伙伴系统

把所有空闲页分组为11个页块链表，每个块链表分别包含很多个大小的页块，有1、2、4、8、16、32、64、128、256、512和1024个连续页的页块。最大可以申请1024个页，对应4MB大小。每个页块的第一个页的物理地址是该页块大小的整数倍。

![image-20220130183058453](os.assets/image-20220130183058453.png)





struct zone有以下定义：struct free_area free_area[MAX_ORDER]

```c++
static inline struct page *alloc_pages(gfp_t gfp_mask,unsigned int order){
    return alloc_pages_current(gfp_mask,order);
}
/**
 *alloc_pages_current - Allocate pages
 *@gfp
 *		//用于分配一个页映射到用户进程的虚拟地址空间，并且希望直接被内核或者硬件访问，主要用于一个用户进程希望通过内存映射的方式
 *		//，访问某些硬件的缓存
 *		%GFP_USER user allocation
 *		//用于内核分配页，主要ZONE_NORMAL区域，也即直接映射区
 *		%GFP_KERNEL kernel allocation
 *		//分配高端内存区域的内存
 *		%GFP_HIGHMEM highmem allocation
 *		%GFP_FS don't call back into a file system
 *		%GFP_ATOMIC don't sleep
 *@order：Power of two of allocation size in pages.0 is a single page.
 *
 *	Allocate a page from the kernel page pool.When not in interrupt context and apply then current process
 * 	NUMA policy.Returns NULL when no page can be allocated.
 */
struct page *alloc_pages_current(gfp_t gfp,unsigned order){
    struct mempolicy *pol=&default_policy;
    struct page *page;
 	//伙伴系统的核心方法
    page = __alloc_pages_nodemask(gfp,order,
                                 policy_node(gfp,pol,numa_node_id()),
                                  policy_nodemask(gfp,pol));
    return page;
}
```

```c++
//每一个zone，都有伙伴系统维护的各种大小的队列，rmqueue----就是找到合适大小的队列，把页面取下来
static struct page * get_page_from_freelist(gfp_t gfp_mask,unsigned int order,int alloc_flags,const struct alloc_context *ac){
    for_next_zone_zonelist_nodemask(zone,z,ac->zonelist,ac->high_zoneidx,ac->nodemask){
        struct page *page;
        page = rmqueue(ac->preferred_zoneref->zone,zone,order,gfp_mask,alloc_flags,ac->migratetype);
    }
}
rmqueue->__rmqueue->rmqueue_smallest
    
static inline struct page *__rmqueue_smallest(struct zone *zone,unsigned int order,int migratetype){
    unsigned int current_order;
    struct free_area * free_area;
    struct page * page;
    for(current_order = order;current_order < MAX_ORDER,++current_order){
        area = &(zone->free_area[current_order]);
        page = list_first_entry_or_null(&area->free_list[migratetype],struct page,lru);
        if(!page)
            continue;
        list_del(&page->lru);
        rmv_page_order(page);
        area->nr_free--;
        //TODO:此处的逻辑？？？
        expand(zone,page,order,current_order,area,migratetype);
        set_pcppage_migratetype(page,migratetype);
        return page
    }
    return NULL;
}
```

```c++
static struct kmem_cache *task_struct_cachep;
//task_struct缓存区域
task_struct_cachep = kmem_cache_create("task_struct",
                                      arch_task_struct_size,align,
                                      SLAB_PANIC | SLAB_NOTRACK | SLAB_ACCOUNT,NULL);

static inline struct task_struct *alloc_task_struct_node(int node){
    //从缓存区域取task_struct
    return kmem_cache_alloc_node(task_struct_cachep,GFP_KERNEL,node);
}

static inline void free_task_struct(struct task_struct *tsk){
    //将task_struct放回缓存区	
    kmem_cache_free(task_struct_cachep,tsk);
}

//对于缓存来讲，其实就是分配了连续几页的大内存块，然后根据缓存对象的大小，切成小内存块
struct kmem_cache{
    struct kmem_cache_cpu __percpu *cpu_slab;
    unsigned long flags;
    unsigned long min_partial;
    //包含这个指针的大小
    int size;
    //纯对象的大小
    int object_size;
    //把下一个空闲对象的指针存放在这一项里的偏移量
    int offset;
    #ifdef CONFIG_SLUB_CPU_PARTIAL
    	int cpu_partial;
    #endif
    //order,就是2的order次方个页面的，objects就是能够存放的缓存对象的数量
    struct kmem_cache_order_objects oo;
    struct kmem_cache_order_objects max;
    struct kmem_cache_order_objects min;
    gfp_t allocflags;
    int refcount;
    void (*ctor)(void *);
    const char *name;
    //双向链表，task_struct、mm_struct、fs_struct的缓存放到链表，LIST_HEAD(slab_caches)
    struct list_head list;
    struct kmem_cache_node *node[MAX_NUMNODES];
}
```

kmem_cache_cpu和kmem_cache_node,它们都是每个NUMA节点上有一个

分配缓存块时，要分两种路径，**fast path**和**slow path**。kmem_cache_cpu是快速通道，kmem_cache_node是普通通道。每次分配内存时，先从kmem_cache_cpu进行分配，如果kmem_cache_cpu没有空闲块，就到kmem_cache_node中进行分配，如果还是没有空闲的块，才去伙伴系统分配新的页。

```c++
struct kmem_cache_cpu{
    //指向大内存块里面第一个空闲的项（会有指针指向下一个空闲的项，最终所有空闲的项会形成一个链表）
    void **freelist;
    unsigned long tid;
    //指向大内存块的第一个页，缓存块就是里面分配。
    struct page *page;
    #ifdef CONFIG_SLUB_CPU_PARTIAL
    	//也是的也是大内存块的第一个页（它里面部分被分配出去了，部分是空的。这是一个备用列表，当page满了，就从这里找）
    	struct page *partial;
    #endif
}

struct kmem_cache_node{
    spinlock_t list_lock;
    #ifdef CONFIG_SLUB
    	unsigned long nr_partial;
    	//这个链表里存放的是部分空闲的内存块。这是kmem_cache_cpu里面的partial的备用列表，如果哪里没有，就到这里来找。
    	struct list_head partial;
    #endif
}
```

分配过程：

kmem_cache_alloc_node会调用slab_alloc_node

```c++
/**
 *	Inlined fastpath so that allocation functions (kmalloc,kmem_cache_alloc)
 *  have the fastpath folded into their functions.So no function call overhead 
 *  for requests that can be satisfied on the fastpath.
 *
 *	The fastpath works by first checking if the lockless freelist can be used.
 * 	if not then __slab_alloc is called for slow processing.
 *  
 *	Otherise we can simply pick the next object from the lockless free list.
 */
static __always_inline void *slab_alloc_node(struct kmem_cache *s,gfp_t gfpflags,int node,unsigned long addr){
    void *object;
    struct kmem_cache_cpu *c;
    struct page *page;
    unsigned tid;
    //快速通道，取出cpu_slab也即kmem_cache_cpu的freelist,这就是第一个空闲的项
    tid = this_cpu_read(s->cpu_slab->tid);
    c = raw_cpu_ptr(s->cpu_slab);
    object = c->freelist;
    page = c->page;
    if(unlikely(!object || !node_match(page,node))){
        //进入普通通道
        object = __slab_alloc(s,gfpflags,node,addr,c);
        stat(s,ALLOC_SLOWPATH)
    }
    return object;
}

static void *___slab_alloc(struct kmem_cache *s,gfp_t gfpflags,int node,unsigned long addr,struct kmem_cache_cpu *c){
    void *freellist;
    struct page *page;
    .......
    redo:
    .......
    //must check again c->freelist in case of cpu migration or IRQ
  	freelist = c->freelist;  
    if(freelist)
        goto load_freelist;
    freelist = get_freelist(s,page);
    
    if(!freelist){
        c->page = NULL;
        stat(s,DEACTIVATE_BYPASS);
        goto new_slab;
    }
    load_freelist:
    	c->freelist = get_freepointer(s,freelist);
    	c->tid = next_tid(c->tid);
    	return freelist;
    new_slab:
    	//先去kmem_cache_cpu的partial找，如果partial不为空，就将kmem_cache_cpu的page，也就是快速通道的那一大块内存
    	//替换为partial里的大块内存，然后redo
    	if(slub_percpu_partial(c)){
            page = c->page = slub_percpu_partial(c);
            slub_set_percpu_partial(c,page);
            stat(s,CPU_PARTIAL_ALLOC);
            goto redo;
        }
    //如果还没有，就new_slab_objects
    freelist = new_slab_objects(s,gfpflags,node,&c);
    return freelist;
} 

static inline void *new_slab_objects(struct kmem_cache *s,gfp_t flags,int node,struct kmem_cache_cpu **pc){
    void *freelist;
    struct kmem_cache_cpu *c = *pc;
    struct page *page;
    //根据node_id 找到对应的kmem_cache_node，然后调用get_partial_node开始在这个节点进行分配
    freelist = get_partial(s,flags,node,c);
    
    if(freelist)
        return freelist;
    //如果当前kmem_cache_node也没有空闲内存，则调用new_slab进行页面分配
    page = new_slab(s,flags,node);
    if(page){
        c = raw_cpu_ptr(s->cpu_slab);
        if(c->page)
            flush_slab();
        freelist = page->freelist;
        page->freelist = NULL;
        stat(s,ALLOC_SLAB);
        c->page = page;
        *pc =  c;
    }else{
        freelist = NULL;
    }
    return freelist;
}

//从当前kmem_cache_node，调用get_partial_node,在这个节点进行分配，如果这个节点没有，就需要调用new_slab进行分配
static void *get_partial_node(struct kmem_cache *s,struct kmem_cache_node *n,struct kmem_cache_cpu *c,gfp_t flags){
    struct page *page,*page2;
    void *object = NULL;
    int available = 0;
    int objects;
    .......
    list_for_each_safe(page,page2,&n->partial,lru){
        void *t;
        t = acquire_slab(s,n,page,object == NULL,&objects);
        if(!t)
            break;
        available += objects;
        if(!object){
            c->page = page;
            stat(s,ALLOC_FROM_PARTIAL);
            object = t;
        }else{
            put_cpu_partial(s,page,0);
            stat(s,CPU_PARTIAL_NODE);
        }
        if(!kmem_cache_has_cpu_partial(s) || available > slub_cpu_partial(s) / 2)
            break;
    }
    return object;
}

static struct page *allocate_slab(struct kmem_cache *s,gfp_t flags,int node){
    struct page *page;
    struct kmem_cache_order_objects oo =  s->oo;
    gfp_t alloc_gfp;
    void *start,*p;	
    int idx,order;
    bool shuffle;
    flags &=gfp_allowed_mask;
    
    page = alloc_slab_page(s,alloc_gfp,node,oo);
    if(unlikely(!page)){
        oo = s->min;
        alloc_gfp = flags;
        /**
         * Allocation may have failed due to fragmentation.
         * Try a lower order alloc if possible.
         */
        page = alloc_slab_page(s,alloc_gfp,node,oo);
        if(unlikefly(!page))
            goto out;
        stat(s,ORDER_FALLBACk);
    }
    return page;
}
```

**页面换出**

触发页面换出的情况：

* get_page_from_freelist->node_reclaim->shrink_node，页面换出也是以内存节点为单位的

* 内核线程kswapd，这个内核线程，在初始化的时候就被创建

  balance_pgdat->kswapd_shrink_node->shrink_node,也是以内存节点为单位的

```c++
/**
* The backgroundd pageout daemon,started as a kernel thread from the init process
*
* This basically trickles out pages so that we have some free memory available even if
* there is no other activity that frees anything up.This is needed for things like routing
* etc,where we otherwise might have all activity going on in asynchronous contexts that cannot 
* page things out.
*
* If there are applications that are active memory-allocators(most normal use),this basically
* shouldn'tmatter.
*/
static int kswapd(void *p){
    unsigned int alloc_order,reclaim_order;
    unsigned int classzone_idx = MAX_NR_ZONES - 1;
    pg_data_t *pgdat = (pa_data_t*)p;
    struct task_struct *tsk = current;
    for( ; ; ){
        kswapd_try_to_sleep(pgdat,alloc_order,reclaim_order,classzone_idx);
        reclaim_order = balance_pgdat(pgdat,alloc_order,classzone_idx);
    }
}
```

以上两种场景都是调用shrink_node

```c++
/**
 * This is a basic per-node page freer.Used by both kswapd and direct reclaim.
 */
static void shrink_node_memcg(struct pglist_data *pgdat,struct mem_cgroup *memcg,struct scan_control *sc,unsigned long *lru_pages){
 unsigned long nr[NR_LRU_LISTS];
 enum lru_list lru;
 while(nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] || nr[LRU_INACTIVE_FILE]){
     unsigned long nr_anon,nr_file,percentage;
     unsigned long nr_scanned;
     for_each_evictable_lru(lru){
         if(nr[lru]){
             nr_to_scan = min(nr[lru],SWAP_CLUSTER_MAX);
             nr[lru] -= nr_to_scan;
             
             nr_reclaimed += shrink_list(lru,nr_to_scan,lruvec,memcg,sc);
         }
     }
 }
}
```

内存也总共分两类，一类是**匿名页**，和虚拟地址空间进行关联；一类是**内存映射**，不但和虚拟地址空间关联，还和文件管理关联。

每一类都有两个列表，一个是active，一个是inactive。如果要换出内存，就是从不活跃的列表中找出最不活跃的。

```c++
enum lru_list {
    LRU_INACTIVE_ANON = LRU_BASE;
    LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE;
    LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE;
    LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE;
    LRU_UNEVICTABLE,
    NR_LRU_LISTS
};

#define for_each_evictable_lru(lru) for(lru=0;lru <= LRU_ACTIVE_FILE;lru++)
static unsigned long shrink_list(enum lru_list lru,unsigned long nr_to_scan,
                                struct lruvec *lruvec,struct mem_cgroup *memcg,
                                struct scan_control *sc){
    if(is_active_lru(lru)){
        if(inactive_list_is_low(lruvec,is_file_lru(lru),memcg,sc,true))
            shrink_active_list(nr_to_scan,lruvec,sc,lru);
        return 0;
    }
    return shrink_inactive_list(nr_to_scan,lruvec,sc,lru);
}
//shrink_list会先缩减活跃页面列表，再压缩不活跃的页面列表。对于不活跃列表的缩减，shrink_inactive_list就需要对页面进行回收
//;对于匿名页，需要分配swap，将内存页写入文件系统；对于内存映射关联了文件的，需要将在内存中的修改写回文件中。
```

**用户态内存映射**

mmap系统调用

```c++
SYSCALL_DEFINE6(mmap,unsigned long,addr,unsigned long,len,unsigned long,prot,unsigned long,flags,unsigned long,fd,unsigned long,off){
    error = sys_map_pgoff(addr,len,prot,flags,fd,off >> PAGE_SHIFT);
}

SYSCALL_DEFINE6(mmap_pgoff,unsigned long,addr,unsigned long,len,unsigned long,prot,unsigned long,flags,unsigned long,fd,unsigned long,pgoff){
    struct file *file = NULL;
    .......
    file = fget(fd);
    .......
    retval = vm_mmap_pgoff(file,addr,len,prot,flags,pgoff);
    return retval;
}
```

vm_mmap_pgoff->do_mmap_pgoff->do_mmap,主要做了以下事:

* 调用get_unmapped_area找到一个没有映射的区域
* 调用mmap_region映射这个区域

```c++
unsigned long get_unmapped_area(struct file *file,unsigned long addr,unsigned long len,unsigned long pgoff,unsigned long flags){
   unsigned long (*get_area)(struct file *,unsigned long,unsigned long,unsigned long,unsigned long);
   //如果是匿名映射，调用mm_struct->get_unmapped_area,其实就是arch_get_unmapped_area,会调用find_vma_prev,在
   //表示虚拟内存区域的vm_area_struct红黑树找到相应的位置
   //如果不是匿名映射，而是映射到一个文件，如果是ext4文件系统，调用的是thp_get_unmapped_area,最终还是调用
   //mm_struct->get_unmapped_area
   get_area = current->mm->get_unmapped_area;
   if(file){
       if(file->f_op->get_unmapped_area){
           get_area = file->f_op->get_unmapped_area;
       }
   }
}

unsigned long mmap_region(struct file *file,unsigned long addr,unsigned long len,vm_flags_t vm_flags,unsigned long pgoff,struct list_head *uf){
    struct mm_struct *mm = current->mm;
    struct vm_area_struct *vma,*prev;
    struct rb_node **rb_link,*rb_parent;
    //是否能够基于虚拟内存区域的前一个vm_area_struct合并到一起
    vma = vma_merge(mm,prev,addr,addr + len,vm_flags,NULL,file,pgoff,NULL,NULL_VM_UEFD_CTX);
    if(vma)
        goto out;
    //在slub里创建一个新的vm_area_struct,然后设置参数
    vma = kmem_cache_zalloc(vm_area_cachep,GFP_KERNEL);
    if(!vma){
        error = -ENOMEM;
        goto unacct_error;
    }
    vma->vm_mm = mm;
    vma->vm_start = addr;
    vma->vm_end = addr + len;
    vma->vm_flags = vm_flags;
    vma->vm_page_prot = vm_get_page_prot(vm_flags);
    vma->vm_pgoff = pgoff;
    INIT_LIST_HEAD(&vma->anon_vma_chain);
    
    if(file){
        vma->vm_file = get_file(file);
        error = call_mmap(file,vma);
        addr = vma->vm_start;
        vm_flags = vma->vm_flags;
    }
    //将新创建的vm_area_struct挂载在mm_struct里面的红黑树上
    vma_link(mm,vma,prev,rb_link,rb_parent);
    return addr;
}
//对于打开的文件，有个struct file结构，file->address_space中有棵变量名为i_mmap的红黑树，vm_area_struct就挂在这棵树上

struct address_space {
    struct inode *host;/** owner: inode,block_device*/
    struct rb_root i_mmap;/** tree of private and shared mappings */
    const struct address_space_operations *a_ops;
}

static void __vma_link_file(struct vm_area_struct *vma){
    struct file *file;
    file = vma->vm_file;
    if(file){
        struct address_space *mapping = file->f_mapping;
        vma_interval_tree_insert(vma,&mapping->i_mmap);
    }
}
```

**用户态缺页异常**

一旦开始访问虚拟内存某个区域，如果物理页，就会触发缺页中断，do_page_fault

```c++
dotraplinkage void notrace do_page_fault(struct pt_regs,unsigned long error_code){
    unsigned long address = read_cr2();/** Get the faulting address */
    __do_page_fault(regs,error_code,address);
}

static noinline void __do_page_fault(struct pt_regs *regs,unsigned long error_code,unsigned long address){
    struct vm_area_struct *vma;
    struct task_struct *tsk;
    struct mm_struct *mm;
    tsk = current;
    mm = tsk->mm;
    //判断缺页中断是否发生在内核
    if(unlikely(fault_in_kernel_space(address))){
        //如果发生在内核则调用vmalloc_fault
        if(vmalloc_fault(address) >= 0){
            return;
        }
        //如果在用户空间，找到vm_area_struct,然后调用handle_mm_fault来映射这个区域
        vma = find_vma(mm,address);
        fault = handle_mm_fault(vma,address,flags);
    }
}

static int __handle_mm_fault(struct vm_area_struct *vma,unsigned long address,unsigned int flags){
    struct vm_fault vmf = {
        .vma = vma,
        .address = address & PAGE_MASK,
        .flags = flags,
        .pgoff = linear_page_index(vm,address),
        .gfp_mask = __get_fault_gfp_mask(vma),
    };
    struct mm_struct *mm = vma->vm_mm;
    //全局页目录项
    pgd_t *pgd;
    p4d_t *p4d;
    int ret;
    pgd = pgd_offset(mm,address);
    p4d = p4d_alloc(mm,pgd,address);
    //上层页目录项
    vmf.pud = pub_alloc(mm,p4d,address);
    //中间页目录项
    vmf.pmd = pmd_alloc(mm,vmf.pud,address);
    //直接页表项
    return handle_pte_fault(&vmf);
}
//每个进程都有独立的地址空间，为了这个进程独立完成映射，每个进程都有独立的进程页表，这个页表的最顶级的pgd存放在task_struct中的
//mm_struct的pgd变量里
```

![image-20220201112401953](os.assets/image-20220201112401953.png)

dup_mm->mm_init->mm_alloc_pgd->pgd_alloc->pgd_ctor

```c++
static void pgd_ctor(struct mm_struct *mm,pgd_t *pgd){
    if(CONFIG_PGTABLE_LEVELS == 2 ||
      (CONFIG_PGTABLE_LEVELS==3 && SHARED_KERNEL_PMD) ||
      CONFIG_PGTABLE_LEVELS >= 4){
        //拷贝了对于swapper_pg_dir的引用。swapper_pg_dir是内核页表最顶级的全局目录
        clone_pgd_range(pgd + KERNEL_PGD_BOUNDARY,
                        swapper_pg_dir + KERNEL_PGD_BOUNDARY,
                        KERNEL_PGD_PTRS);
    }
}
```

一个进程的虚拟地址空间包含用户态和内核态。为了从虚拟地址空间映射到物理页面，页表也分为用户地址空间的页表和内核页表。在内核里，映射靠内核页表，这里内核页表会拷贝一份到进程的页表。

一个进程fork完毕之后，有了内核页表，有了自己顶级的pgd，但是对于用户空间还没映射过，这需要等到这个进程在某个CPU上运行，并对内存访问的那一刻。

当这个进程被调度到某个CPU上运行时，调用context_switch进行上下文切换。对于内存方面的切换会调用switch_mm_irqs_off,这里会调用load_new_mm_cr3。

**cr3**

* cr3是CPU的一个寄存器，会指向当前进程的顶级pgd。如果CPU的指令要访问进程的虚拟内存，就会自动从cr3里得到pgd在物理内存的地址。然后根据里面的页表解析虚拟内存的地址为物理内存，从而访问真正的物理内存上的数据。

* 存放当前进程的顶级pgd，是硬件的要求。存放的是pgd在物理内存的地址，不能是虚拟地址。因而load_new_mm_cr3里面会使用__pa,将mm_struct里面的成员变量pgd变为物理地址，才能加载到cr3中。
* 用户态在运行过程中，访问虚拟内存中的数据，会被cr3里面指向的页表转换为物理地址后，才在物理内存中访问数据，这个过程是在用户态运行的

```c++
static int handle_pte_fault(struct vm_fault *vmf) {
    pte_t entry;
    vmf->pte = pte_offset_map(vmf->pmd,vmf->address);
    vmf->orig_pte = *vmf->pte;
    //页表项中从没出现过
    if(!vmf->pte){
        //匿名页
        if(vma_is_anonymous(vmf->vma))
            return do_anonymous_page(vmf)
        else
        //映射到文件
            return do_fault(vmf);
    }
 
    //原来出现过，被换到硬盘中
    if(!pte_present(vmf->orig_pte))
        return do_swap_page(vmf);
}

static int do_anonymous_page(struct vm_fault *vmf){
    struct vm_area_struct *vma = vmf->vma;
    struct mem_cgroup *memcg;
    struct page *page;
    int ret = 0;
    pte_t entry;
    //分配一个页表项
    if(pte_alloc(vma->vm_mm,vmf->pmd,vmf->address));
    	return VM_FAULT_OOM;
    //分配一个页，之后会调用alloc_pages_vma,最终调用__alloc_pages_nodemask
    //伙伴系统的核心方法
    page = alloc_zeroed_user_highpage_movable(vma,vmf->address);
    //将页表项指向新分配的物理页
    entry = mk_pte(page,vma->vm_page_prot);
    if(vma->vm_flags & VM_WRITE)
        entry = pte_mkwrite(pte_mkdirty(entry));
    vmf->pte = pte_offset_map_lock(vma->vm_mm,vmf->pmd,vmf->address,&vmf->ptl);
    //将页表项塞到页表
    set_pte_at(vma->vm_mm,vmf->address,vmf->pte,entry);
}

static int __do_fault(struct vm_fault *vmf) {
    struct vm_area_struct *vma = vmf->vma;
    int ret;
    ret = vma->vm_ops->fault(vmf);
    return ret;
}

static const struct vm_operations_struct ext4_file_vm_ops = {
    .fault = ext4_filemap_fault,
    .map_pages = filemap_map_pages,
    .page_mkwrite = ext4_page_mkwrite,
}

int ext4_filemap_fault(struct vm_fault *vmf){
    struct inode = file_inode(vmf->vma->vm_file);
    err = filemap_fault(vmf);
    return err;
}

int filemap_fault(struct vm_fault *vmf){
    int error;
    struct file *file = vmf->vma->vm_file;
    struct address_space *mapping = file->f_mapping;
    struct inode *inode = mapping->host;
    pgoff_t offset = vm->pgoff;
    struct page *page;
    int ret = 0;
    //对于文件映射，文件在物理内存有页面作为缓存，找到这个页
    page = find_get_page(mapping,offset);
    if(likely(page)&&!(vmf->flags & FAULT_FLAG_TRIED)) {
        //如果找到这个页，预读一些数据到内存，没有就跳到no_cached_page
        do_async_mmap_readahead(vmf->vma,ra,file,page,offset);
    } else if(!page) {
        goto no_cached_page;
    }
    vmf->page = page;
 	return ret | VM_FAULT_LOCKED;
 no_cached_page:
    error = page_cache_read(file,offset,vmf->gfp_mask);
}

static int page_cache_read(struct file *file,pgoff_t offset,gfp_t gfp_mask) {
    struct address_space *mapping = file->f_mapping;
    struct page *page;
    page = __page_cache_alloc(gfp_mask|__GFP_COLD);
    ret = add_to_page_cache_lru(page,mapping,offset,gfp_mask & GFP_KERNEL);
    ret = mapping->a_pos->readpage(file,page);
}

static const struct address_space_operations ext4_apos = {
    .readpage = ext4_readpage,
    .readpages = ext4_readpages,
}

static int ext4_read_inline_page(struct inode *inode,struct page *page) {
    void *kaddr;
    //将物理内存映射到内核的虚拟空间(临时映射到内核)
    kaddr = kmap_atomic(page);
    ret = ext4_read_inline_data(inode,kaddr,len,&iloc);
    flush_dcache_page(page);
    //取消内核的临时映射
    kunmap_atomic(kaddr);
}
```



```c++
int do_swap_page(struct vm_fault *vmf) {
    struct vm_area_struct *vma = vmf->vma;
    struct page *page,*swapcache;
    struct mem_cgroup *memcg;
    swp_entry_t entry;
    pte_t pte;
    entry = pte_do_swp_entry(vmf->orig_pte);
    //查找swap文件有没有缓存
    page = lookup_swap_cache(entry);
   	//如果没有缓存，调用swapin_readahead把swap文件读到内存，形成内存页，并通过mk_pte生成
   	//页表项。set_pte_at将页表项插入页表，swap_free将swap文件清理（因为重新加载回内存，不需要swap文件了）。
    if(!page) {
        //swapin_readahead最终也会调用swap_readpage,同样也需要用kmap_atomic做临时映射。
        page = swapin_readahead(entry,GFP_HIGHUSER_MOVABLE,vma,vmf->address);
    }
    swapcache = page;
    pte = mk_pte(page,vma->vm_page_prot);
    set_pte_at(vma->vm_mm,vmf->address,vmf->pte,pte);
    vmf->orig_pte = pte;
    swap_free(entry);
}
```

![image-20220201191037724](os.assets/image-20220201191037724.png)



页表一般很大，只能放在内存中，操作系统每次访问内存，都要先查询页表得到物理地址，然后访问该物理地址读取指令、数据。

为了提高映射速度，引入了**TLB**(Translation Lookaside Buffer),专门用来做地址映射的硬件设备，不在内存中，存储的数据比较少，但是比内存快。是页表的Cache，其中存储了当前最可能被访问到的页表项。

![image-20220201191553451](os.assets/image-20220201191553451.png)

**内核态内存映射**

* 内核态内存映射函数vmalloc、kmap_atomic是如何工作的
* 内核态页表是放在哪里的，如果工作的？swapper_pg_dir是怎么回事
* 出现内核态缺页异常如何处理

//TODO:???????

## 文件系统

新的系统并不是只为了做同样的事情比老的系统快一点，还应该允许用以前完全不可能的方法处理事情。

用以前完全不可能的方法来处理事情

元数据：作为文件系统，一定要提供存储、查询和处理数据的功能。文件系统就保存了一个内部数据结构（VFS）

，使得这些操作成为可能，为文件系统提供特定的身份和性能特征。元数据是专门交给文件驱动程序用的。

**fsck**:

确保文件系统驱动程序要用的元数据是干净的。生效的时机：

* 每次Linux启动，没有挂接任何文件系统的时候，启动fsck扫描下/etc/fstab文件中列出的所有本地文件系统
* 每次Linux关闭，要把还在内存中的被称之为页面缓存或磁盘中缓存中的数据转送到磁盘，还要保证把已经挂接的文件系统卸载干净

当遇到异常关机，重启后fsck会全面审查元数据（时间会很长），修正一切可以修复的数据（会丢弃不可修复的数据）

针对于fsck，日志是一个更好的解决方案，文件系统的日志记录了它对元数据都干了些什么。

​	元数据出现问题后，**fsck**在遇到有日志的文件系统时，由文件系统驱动负责按照日志里的记载去恢复元数据（更快）

**ReiserFS**

一个最好的文件系统，不单能够管理好用户的文件，还能适应环境干点别的，比如代替数据库。

关注小文件的性能。常见的ext2、ext3等文件系统一遇到小文件就傻了（TODO:为什么傻了？？？），迫使开发者处理比较零碎的数据时，不得不考虑采用数据库或其他手段获取想要的性能指标。“针对问题进行创作”

ext2分析：比较擅长存储大量大小在20K以上的文件。最小存储单元是1K或4K。**ReiserFS**在处理小于1K的文件时，比ext快8到15倍，处理大于1K的文件时，也不会有什么性能损失。

ReiserFS技术：

采用**B*树**的数据结构，一种全新的经过特殊优化的树形数据结构。ReiserFS用它组织元数据，相当于整个磁盘分区是一个**B*树**。

**B树**是针对磁盘或其他存储介质而设计的一种多叉平衡查找树。实际文件系统并不使用B树，大多使用**B+树**。**B+树**是**B树**的一个变形，在降低磁盘读写代价的同时，提高了查询效率的稳定性。B*树是B+树的变形，B\*树分配新节点的概率比B+树要低，空间利用率更高。

利用B*树的特性，ReiserFS允许一个目录下可以容纳10万个子目录。ReiserFS可以根据需要动态的分配索引，也省去了固定索引，没有附加空间，提高了存储效率。ReiserFS不适用固定大小的数据块分配存储空间，采用精确分配原则。ReiserFS还提供了一种以尾文件（比系统文件块小的文件或文件的结尾部分）为中心的特殊优化，ReiserFS可以利用**B\*树**的叶子节点存储文件。

ReiserFS实际做了两件事：

* 显著提高小文件性能，把文件数据和索引信息放在一起，大多数只需要一次磁盘IO就能完成。
* 压缩尾文件，就可以节省大量磁盘空间。尾文件压缩是以牺牲速度为代价

**进程文件系统procfs**

启动时动态生成的文件系统，**用于用户空间通过内核访问进程信息**。经过不断演变，**如今Linux提供的procfs已经不单单用于访问进程信息，还是一个用户空间与内核交换数据修改系统行为的接口**。这个文件系统通常被挂接到/proc目录。

**procfs**源自UNIX世界，几乎所有类UNIX系统都有提供。最早在UNIX第8版实现，后来又移植到SVR4，最后由一个称为“**9号计划**”的项目做大量改进，使得/proc成为文件系统真正的一部分。

**proc目录下文件**

| 名称        | 功能                                                      | 名称       | 功能                       |
| ----------- | --------------------------------------------------------- | ---------- | -------------------------- |
| apm         | 高级电源管理信息                                          | loadavg    | 负载均衡信息               |
| buddyinfo   | Buddy算法内存分配信息                                     | locks      | 内核锁                     |
| compline    | 内核的命令行参数                                          | mdstat     | 磁盘阵列状态               |
| config.gz   | 当前内核的.config文件                                     | meminfo    | 内存信息                   |
| cpuinfo     | cpu信息                                                   | misc       | 杂项信息                   |
| devices     | 可以用到的设备（块设备/字符设备）                         | modules    | 系统已经加载的模块文本列表 |
| diskstats   | 磁盘I/O统计信息                                           | mounts     | 已挂接的文件系统列表       |
| dma         | 使用的DMA通道                                             | partitions | 磁盘分区信息               |
| execdomains | 执行区域列表                                              | pci        | 内核识别的PCI设备列表      |
| fb          | Frame buffer信息                                          | self       | 访问proc文件系统的进程信息 |
| filesystems | 支持的文件系统                                            | slabinfo   | 内核缓存信息               |
| Interrupt   | 中断的使用情况，记录中断产生次数                          | splash     | splash信息                 |
| iomem       | I/O内存映射关系                                           | stat       | 全面统计状态表             |
| ioports     | I/O端口分配情况                                           | swaps      | 交换空间使用情况           |
| kcore       | 内核核心映像，GDB可以利用它查看当前内核的所有数据结构状态 | uptime     | 系统正常运行时间           |
| key-users   | 密钥保留服务文件                                          | version    | 内核版本                   |
| kmsg        | 内核消息                                                  | vmstat     | 虚拟内存统计表             |
| ksyms       | 内核符号表                                                | zoneinfo   | 内存管理区信息             |

**/proc下子目录**

| 名称     | 功能                 | 名称    | 功能                           |
| -------- | -------------------- | ------- | ------------------------------ |
| [number] | 进程信息             | irq     | 中断请求设置接口               |
| acpi     | 高级配置与电源接口   | net     | 网络各种状态信息               |
| asound   | ALSA声卡驱动接口     | scsi    | SCSI设备信息                   |
| bus      | 系统中已安装总线信息 | sys     | 内核配置接口                   |
| driver   | 驱动信息             | sysvipc | 中断使用情况，记录中断产生次数 |
| fs       | 文件系统特别信息     | tty     | tty驱动信息                    |
| ide      | IDE设备信息          |         |                                |

[number]这些目录，里面包含的文件，描述了一个进程的方方面面，**是procfs最初目的的体现**。这些文件都是只读的，top、ps就是依据这些目录中文件所提供的内容进行工作的。

sys目录，包含的文件大多都是可以写的，通过改写这些文件的内容，可以起到修改内核参数的目的。系统命令sysctl就是利用这个目录实现的全部功能。

TODO:实战？？？？

**tmpfs文件系统**

**RamDisk**，将一部分固定大小的内存当作分区来使用。这是一种非常古老的技术（上世纪80年代初），MS-DOS在2.0版本就加入了对RamDisk的支持。Linux将这个技术直接编译进内核。

**RamDisk**的缺点：浪费物理内存空间（即使一个字节没有使用，所有RamDisk都需要进行格式化）；在不断的生产实践过程中，大量临时文件很影响程序性能。于是有人把程序产生的临时文件放入RamDisk来提高整体性能

鉴于上述需求，在Linux2.4内核中，引入了**tmpfs**。

类似于RamDisk,既可以使用内存，又可以使用交互分区。tmpfs文件系统使用虚拟内存子系统的页面存储文件，tmpfs不关心这些页面存储在物理内存还是交换分区。

**tmpfs**跟其他文件系统如：ext2、ext3、ReiserFS等是完全不一致的，它们在Linux中被称为块设备。tmpfs直接建立在**VM**之上的。tmpfs刚被挂接时只有很小的空间。随着文件的复制和创建，tmpfs文件系统驱动程序会分配更多的**VM**，并按需求动态地增加文件系统的空间。

**devfs和sysfs文件系统**

**类UNIX系统**最“酷”的地方在于：设备不是简单的隐藏在晦涩的API之后，而是真正的与普通文件、目录、符号链接一样，存在于文件系统之上。

devfs:提供一个新的、更合理的方式管理那些位于dev目录下的所有块设备和字符设备。典型的Linux系统以一种不太理想，而且麻烦的方式管理这些特殊文件。

传统的Linux设备驱动程序，要向系统提供一个文件映射，需要 提供一个主设备号，而且这个主设备号必须保证唯一。早期，这个主设备号被设计的只有8位。

devfs给驱动开发人员提供一个devfs_register的内核API，这个API可以接受一个设备名称作为参数，调用成功后，/dev目录下就会出现与设备名相同的文件名。而且devfs_register也支持主设备号的策略，这样可以保持向下兼容性。

工作方式：一旦所有设备驱动程序启动并向内核注册适当的设备，内核就启动/sbin/init进程，系统初始化脚本开始执行。启动过程初期，rc脚本将devfs文件系统安装到/dev中，这样/dev就包含了devfs所表达的所有设备映射关系，所有注册的设备依然可以通过/dev目录进行访问。

优点：所有需要的设备映射关系都由内核自动创建，就不用写死设备文件，/dev目录就不会充斥大量的无用设备文件。

devfsd       自定义dev    TODO:???????

**sysfs的由来**

Liunx下设备管理方式的演进：

* 静态/dev文件，将设备通过设备节点放入/dev目录下，每个设备节点是/dev根目录下的一个文件。Linux通过**主次设备号**来指定不同的设备节点。TODO:早期设备管理是怎样的一个流程。
* devfs，linux kernel2.4版本后引入。允许使用自定义的设备名称来注册设备节点，同时兼容老的设备号；所有的设备都有内核在系统启动时期创建并注册到/dev目录下
* udev，devfs解决了静态/dev管理的很多问题。基于devfs的一些缺陷，在linux kernel2.6.x版本后，引入了udev对其进行改进。udev是一个对/dev下设备节点进行**动态管理**的**用户空间程序**，它通过**自身的守护进程**和**自定义的一系列规则**来处理设备的加载、移除和热插拔等功能。

| devfs                          | udev                                                     |
| ------------------------------ | -------------------------------------------------------- |
| 命名不够灵活，设备名称不可预知 | 支持设备的固定命名                                       |
|                                | 设备热插拔时，用户程序有办法得到通知，udev运行在用户空间 |
| 只显示存在的设备列表           |                                                          |
| major、minor快被分配光了       |                                                          |

* sysfs，Linux2.6引入的一种虚拟文件系统，挂载在/sys目录下，这个文件系统把实际链接到系统上的设备，总线及其对应的驱动程序组织成分级的文件。从而将设备的层次结构映射到用户空间中，用户空间可以通过修改sysfs中文件属性来修改设备属性，从而与内核设备交互

sysfs是对devfs改进，udev也是对devfs的改进。udev就是利用sysfs提供的信息来实现的：udev会根据sysfs里的设备信息创建/dev目录下的相应设备节点。

devfs的缺点：

* 不确定的设备映射，有时一个设备映射的设备文件可能不同；
* 没有足够的主/辅设备号，没有给主/辅设备号太多的扩展余地；
* dev目录下文件太多而且不能表示当前系统上的实际设备；
* 命名不够灵活，不能任意指定。

意识到procfs的复杂度之后，开始将procfs中有关设备的部分独立出来。最开始采用ramfs(可以看作RamDisk和tmpfs的中间产品)作为基础，名为ddfs，后来发现driverfs更为贴切。这些都是在2.5版本中内核鼓捣的。driverfs把实际连接到系统上的设备和总线组织成一个分级的文件，和devfs相同，用户空间的程序同样可以利用这些信息以实现和内核的交互，该系统是当前实际设备树的一个直观反映。到了2.6内核，也就是2.5的最终成型版本，新设计了一个kobject子系统，它就改变了实现策略抛弃ramfs，利用kobject子系统来建立这些信息。

因为本身源于procfs的设计思路，提供的也是用户空间和系统空间交换信息的接口。用户空间工具udev就是利用了sysfs提供的信息在用户空间实现了与devfs完全相同的功能。

**其他特种文件系统**

RelayFS,专门用来从内核空间向用户空间反馈大量数据。是通过mmap来完成的。

debugfs，调试内核。基于relay技术实现

规划文件系统时，需要考虑以下几点：

* 文件系统要有严格的组织形式，使得文件能够以块为单位进行存储
* 文件系统中也要有索引区，用来方便查找一个文件分成的多个块都存放在什么位置
* 如果文件系统中有的文件是热点文件，近期经常被读取和写入，文件系统应该有缓存层
* 文件应该用文件夹形式组织起来，方便管理和查询
* Linux内核要在自己的内存里面维护一套数据结构，来保存那些文件被那些进程打开和使用。

```c++
struct ext4_inode {
    __lel16 i_mode;//File mode
    __lel16 i_uid;//Low 16 bits of Owner Uid 
    __lel32 i_size_lo;//Size in bytes
    __lel32 i_atime;//Access time
    __lel32 i_ctime;//Inode Change time
    __lel32 i_mtime;//Modification time
    __lel32 i_dtime;//Deletion time
    __lel16 i_gid;//Low 16 bits of Group Id.
    __lel16 i_links_count;//Links count
    __lel16 i_blocks_lo;//Blocks count
    __lel32 i_flags;//File flags
    __lel32 i_block[EXT4_N_BLOCKS];//Pointers to blocks
    __lel32 i_generation;//File version(for NFS)
    __lel32 i_file_acl_lo;//File ACL
    __lel32 i_size_high;
}
```

每个inode，4个字节记录一个block号码，inode关于block的记录：12直接、1间接、1双间接、1三间接

12直接：12 * 4kb = 48kb

1间接：1024 * 4kb = 4096kb

1双间接：1024 * 1024 * 4kb = 4096mb

1三间接：1024 * 1024 *1024 * 4 = 4096gb

但是有一个显著的问题，对于大文件，访问速度慢，引入了一个新的概念**Extents**,其实会保存成一棵树

如果使用ext4的extents特性，必须在挂载时指定该特性

树有一个个的节点，有叶子节点，也有分支节点，每个节点都有一个头。ext4_extent_header可以用来描述某个节点

```c++
struct ext4_extent_header {
    //probably will support different formats
    __le16 eh_magic;
    //number of valid entries
    //节点里有多少项，这里的项分为两种，如果是叶子节点，这一项直接指向硬盘上连续块的地址，称为数据节点ext4_extent;
    //如果是分支节点，这一项指向下一层的分支节点或叶子节点，称为索引节点ext4_extent_idx。两种类型的项大小都为12byte
    __le16 eh_entries;
    //capacity of store in entries
    __le16 eh_max;
    //has tree real underlying blocks
    __le16 eh_depth;
    //generation of the tree
    __le16 eh_generation;
}

struct ext4_extent {
    __le32 ee_block;//first logical block extent covers
    __le32 ee_len;//number of blocks coverd by extent
    __le32 ee_start_hi;//high 16 bits of physical block
    __le32 ee_start_lo;//low 32 bits of physical block
}

struct ext4_extent_idx {
    //index covers logical blocks form 'block'
    __le32 ei_block;
    //pointer to the physical block of the next level.leaf or next index could be here.
    __le32 ei_leaf_lo;
    //high 16 bits of physical block
    __le16 ei_leaf_hi;
    __u16 ei_unused;
}
//TODO:具体表现形式
如果文件不大，inode的i_block,可以放的下一个ext4_extent_header和4项ext4_extent。此时eh_depth为0，也即叶子节点
如果文件比较大，4个extent放不下，就会分裂成一棵树，eh_depth>0的节点就是索引节点。
除了根节点，其他的节点都保存在一个块4k里，4k扣除ext_extent_header的12byte，剩下能放340项，每个extent最大能表示128MB的数据
```

```c++
struct inode *__ext4_new_node(handle_t *handle,struct inode *dir,
                             umode_t mode,const struct qstr *qstr,
                             __u32 goal,uid_t *owner,__u32 i_flags,
                             int handle_type,unsigned int line_no,
                             int nblocks){
    //读取inode位图，找到空闲的inode
    inode_bitmap_bh = ext4_read_inode_bitmap(sb,group);
    ino = ext4_find_next_zero_bit((unsigned long *)inode_bitmap_bh->b_data,
                                 EXT_INODES_PER_GROUP(sb),ino);
}
```

“一个块的位图 + 一系列的块”，外加“一个块的inode位图 + 一系列的inode结构”，最多能表示128M。把这一整个称为一个块组。有N多块组，就能表示N大的文件。

对于块组，用ext4_group_desc来表示，这里面对于一个块组的里的inode位图bg_inode_bitmap_lo、块位图bg_block_bitmap_lo、inode列表bg_inode_table_lo，都有相应的成员变量。

块组有多个，快组描述符也同样组成一个列表，称为**块组描述符表**

还需要一个数据结构，对整个文件系统进行描述，就是**超级块**ext4_super_block

超级块和快组描述符表都有副本保存在每一个**块组中。**

**Meta Block Groups**：将块组分为多个组，称为元块组，每个元块组里的块组描述符表仅仅包括自己的，一个元块组包含64个块组，这样一个元块组中的块组描述符表最多64项

进程要想往文件系统里写数据，需要和其他层的组件一起合作：

* 应用层，进程可通过系统调用如sys_open、sys_open
* 在内核，每个进程都需要为打开的文件，维护数据结构
* 在内核，整个系统打开的文件，也需要维护一定的数据结构
* Linux可支持多达数十种不同的文件系统，实现各不相同，因此Linux内核向用户空间提供了虚拟文件系统这个统一接口，来对文件系统进行操作。提供了常见的文件系统对象模型，例如inode、directory entry、mount等，以及操作这些对象的方法，如inode operations、directory operations、file operations等
* 为了读写ext文件系统，要通过块设备I/O层

![image-20220216223214077](os.assets/image-20220216223214077.png)

**挂载文件系统**

```c++
register_filesystem(&ext4_fs_type);

static struct file_system_type ext4_fs_type = {
    .owner = THIS_MODULE,
    .name = "ext4",
    .mount = ext4_mount,
    .kill_sb = kill_block_super,
    .fs_flags = FS_REQUIRES_DEV
}
```

mount系统调用链：do_mount->do_new_mount->vfs_kern_mount

```c++
struct mount {
    struct hlist_node mnt_hash;
    struct mount *mnt_parent;//装在点所在的父文件系统
    struct dentry *mnt_mountpoint;//装载点在父文件系统中dentry
    struct vfsmount mnt;
    union {
        struct rcu_head mnt_rcu;
        struct llist_node mnt_list;
    };
    struct list_head mnt_mounts;
    struct list_head mnt_child;
    struct list_head mnt_instance;
    const char *mnt_devname;
    struct list_head mnt_list;
} __randomize_layout
    
struct vfsmount {
    struct dentry *mnt_root;//当前文件系统根目录的dentry
    struct super_block *mnt_sb;//指向超级块的指针
    int mnt_flags;
} __randomize_layout

struct dentry * mount_fs(struct file_system_type *type,int flags,const char *name,void *data) {
    struct dentry *root;
    struct super_block *sb;
    
    root = type->mount(typee,flags,name,data);
    sb = root->d_sb;
}
```

在文件系统的实现中，每个在硬盘上的结构，在内存中也对应相同格式的结构。当所有的数据结构都读到内存里，内核就可以通过操作这些数据结构，来操作文件系统了。

**虚拟文件系统**

作为内核子系统，为**用户空间程序**提供了**文件和文件系统**相关的接口。系统中所有文件系统不但依赖VFS共存，而且也依靠VFS系统协同工作。通过虚拟文件系统，程序可以利用标准的Unix系统调用对不同的文件系统，甚至不同介质上的文件系统进行读写操作。

系统调用可以在这些不同的文件和介质之间执行。**老式的操作系统**（如DOS），是无力完成上述工作的，任何对非本地文件系统的访问都必须依靠特殊工具才能完成。正是由于现代操作系统引入抽象层，比如Linux通过虚拟接口访问文件系统，才使得这种协作性和泛型存取成为可能。

新的文件系统和新类型的存储介质都能找到进入linux之路。

VFS提供了一个通用文件系统模型，该模型囊括了**任何文件系统的常用功能集和行为**，该模型偏重于Unix风格的文件系。它定义了**所有文件系统**都支持的、**基本的、概念上的接口和数据结构**。同时，实际文件系统也将自身的诸如“如何打开文件”等概念在**形式上**与**VFS的定义**保持一致。因为实际文件系统的代码在统一的接口和数据结构下隐藏了具体的实现细节。

**Unix文件系统**

Unix使用了四种和文件系统相关的传统抽象概念：文件、目录项、索引节点和安装点。

从本质上讲，文件系统是**特殊的数据分层存储结构**，它包含文件、目录和相关的控制信息。**面向记录的文件系统**TODO:?????面向记录的文件系统提供更丰富、更结构化的表示，而简单的面向字节流抽象的Unix文件则以简单性和相当的灵活性为代价。

Unix系统将文件的相关信息和文件本身这两个概念加以区分，例如访问控制权限、大小、拥有者、创建时间等信息，这些数据被存储在一个单独的数据结构中，被称为索引节点inode

所有这些信息都和文件系统的控制信息密切相关。文本系统的控制信息存储在超级块中，超级块是一种包含文件系统信息的数据结构。

VFS其实采用面向对象的设计思路。使用一组数据结构来代表通用文件对象。这些对象包含数据的同时也包含操作这些数据的函数指针，其中的操作函数由具体文件系统实现。

* 超级块对象，代表一个具体的已安装文件系统；
* 索引节点对象，代表一个具体的文件；
* 目录项对象，代表一个目录项，是路径的一个组成部分；
* 文件对象，代表由进程打开的文件

VFS使用了大量结构体对象，除了上述主要对象，每个注册的文件系统都由file_system_type结构体来表示，描述了文件系统及其性能；每一个安装点也都用vfsmount结构体表示，包含安装点的相关信息，如安装位置和安装标志。

每种文件系统都必须实现超级块对象，该对象用于存储特定文件系统的信息。通常对应于存放在磁盘特定扇区中的文件系统超级块。对于并非基于磁盘的文件系统（如基于内存的文件系统，如sysfs），它们会在使用现场创建超级块对象并将其保存到内存中。

由super_block结构体表示，定义在<linux/fs.h>。创建、管理和撤销超级块对象的代码位于fs/super.c中。超级块对象通过alloc_super函数创建并初始化。**文件系统安装时**，文件系统会调用该函数以便从磁盘读取文件系统超级块，并且将其信息填充到内存的超级块中。

超级块对象中最重要的一个域就是s_op,指向超级块的操作函数表，由super_operations结构体表示，定义<linux/fs.h>中。超级快操作表中，文件系统可以将不需要的函数指针设置成NULL，如果VFS发现操作函数为null，要么会调用通用函数指向相应操作，要么什么也不做。

**索引节点对象包含了内核在操作文件或目录时需要的全部信息。对于Unix风格的文件系统，这些信息可以从磁盘索引节点直接读入。如果一个文件系统没有索引节点，那么不管这些相关信息在磁盘上如何存放，文件系统都必须从中提取这些信息。没有索引节点的文件系统通常将文件的描述信息作为文件系统的一部分存放。**这些文件系统没有将数据和控制信息分来存放。有些现代文件系统使用数据库来存储文件的数据（TODO:????）

一个索引节点代表文件系统中（索引节点仅当文件被访问时，才在内存中创建？？？TODO:）的一个文件，可以是设备或管道这样的特殊文件。因此索引节点结构体中有一些和特殊文件相关的项。比如i_pipe指向一个代表有名管道的数据结构，i_bdev指向块设备结构体，i_cdev指向字符设备结构体。

有时，某些文件系统可能并不能完整的包含索引节点结构体要求的所有信息。例如，有些文件可能并不记录文件的访问时间，这时，文件系统就可以在实现中选择任何合适的办法解决，例如 让i_atime=0

**目录项对象**。VFS把目录当成文件对待，在路径/bin/vi中，bin和vi都属于文件，路径中每个组成部分都由一个索引节点表示。虽然他们可以统一由索引节点表示，但是VFS经常需要执行目录相关的操作，比如路径名查找等。为了方便查找操作，引入目录项的概念dentry。

在路径中（包含普通文件），每一部分都是目录项对象，目录项也可以包含安装点。目录项对象没有对应的磁盘数据结构，VFS根据字符串形式的路径名现场创建。

目录项状态：被使用、未被使用和负状态

* 一个被使用的目录项对应一个有效的索引节点（即d_inode指向对应的索引节点）并且表明该对象存在一个或多个使用者（即d_count为正值）
* 一个未被使用的dentry对应一个有效的索引节点，但是VFS当前并未使用它。该对象被保留在缓存中以便需要时再使用它。
* 一个负状态的dentry没有对应的有效索引节点

**目录项缓存**

* “被使用的”目录项链表。该链表通过索引节点对象中的i_dentry项连接相关的索引节点。因为一个给定的索引节点可能有多个链接，所以就可能有多个目录项对象

* “最近被使用的”双向链表。该链表含有未被使用的和负状态的目录项对象。

* 散列表和相应的散列函数用来快速的将给定路径解析为相关目录项对象。

  散列表由数组dentry_hashtable表示，其中每一个元素都是一个指向具有相同键值的目录项对象链表的指针。实际的散列值由d_hash()函数计算，它是内核提供给文件系统的唯一的一个散列函数。查找散列表要通过d_lookup()函数。

而dcache在一定意义上也提供对索引节点的缓存，也就是icache。和目录对象相关的索引节点不会被释放，因为目录项会让相关索引节点的使用计数为正，这样就可以确保索引节点留在内存中。只要目录项被缓存，相应的索引节点也就被缓存了。

文件访问呈现空间和时间的局部性。

**文件对象**

文件对象没有对应的磁盘数据，文件对象通过f_dentry指针指向相关的目录项对象，目录项会指向相关的索引节点，索引节点会记录文件是否是脏的。因为多个进程可以同时打开和操作同一个文件，所以同一个文件也可能存在多个对应的文件对象。文件对象仅仅在进程观点上代表已打开文件，反过来指向目录项对象（反过来指向索引节点对象），其实只有目录项对象才表示已打开的实际文件。

**其他文件系统相关数据结构**

file_system_type 描述一个文件系统的功能和行为。每种文件系统不管有多少个实例安装到系统中，还是根本没有安装到系统中，都只有一个file_system_type结构。当文件系统被实际安装时，将有一个vfsmount结构体在安装点被创建。

```c++
struct vfsmount {
    struct list_head mnt_hash;//散列表
    struct vfsmount *mnt_parent;//父文件系统
    struct dentry *mnt_mountpoint;//安装点的目录项
    struct dentry *mnt_root;//该文件系统的根目录项
    struct super_block *mnt_sb;//该文件系统的超级块
    struct list_head mnt_mounts;
    struct list_head mnt_child;
    int mnt_flags;
    char *mnt_devname;
    struct list_head mnt_list;
    ......
}
```

理清文件系统和所有其他安装点间的关系，是维护所有安装点链表中最复杂的工作。所以vfsmount结构体中维护的各种链表就是为了能够跟踪这些关联信息。

**和进程相关的数据结构**

file_struct定义在<linux/fdtable.h>，由进程描述符中files指向，所有与单个进程相关的信息（如打开的文件及文件描述符）都包含在其中。

fs_struct定义在<linux/fs_struct.h>，由进程描述符中fs指向，包含文件系统和进程相关的信息，该结构包含了当前进程的当前工作目录和根目录。

namespace定义在<linux/mmt_namespace.h>，由进程描述符中mmt_namespace指向

系统能够随机访问固定大小数据片（chunks）的硬件设备称作块设备，最常见的是硬盘，除此之外，还有软盘驱动器、蓝光光驱和闪存等许多其他块设备，它们都是以安装文件系统的方式使用的---这也是块设备一般的访问方式。

另一种基本的设备类型是字符设备。字符设备按照字符流的方式被有序访问，像串口和键盘就属于字符设备。对于这两种设备。区别在于是否可以随机访问数据。

块设备中最小的可寻址单元是扇区，一般为2的整数倍，最常见的是512字节。扇区是所有块设备的基本单元---块设备无法对比它还小的单元进行寻址和操作。

```c++
SYSCALL_DEFINE3(open,const char __user,filename,int flags,umode_t,mode) {
    return do_sys_open(AT_FDCWD,filename,flags,mode);
}
long do_sys_open(int dfd,const char __user *filename,int flags,umode_t mdoe) {
    ....
    //task_struct->files->fd_array，默认情况下，0代表标准输入，1代表标准输出，2代表标准错误输出。
    //每一项都是指向struct file的指针
    fd = get_unsed_fd_flags(flags);
    if(fd >= 0){
        //首先初始化了struct nameidata这个结构，nameidata->path
        struct file *f = do_filp_open(dfd,tmp,&op);
        if(IS_ERR(f)){
            put_unused_fd(fd);
            fd = PTR_ERR(f);
        }else{
            fsnotity_open(f);
            fd_install(fd,f);
        }
    }
    putname(tmp);
    return fd;
}

struct file *do_filp_open(int dfd,struct filename *pathname,const struct open_flags *op) {
    ......
    set_nameidata(&nd,dfd,pathname);
    filp = path_openat(&nd,op,flags | LOOKUP_RCU);
    ......
    restore_nameidata();
    return filp;
}

static struct file *path_openat(struct nameidata *nd,const struct open_flags *op,unsigned flags) {
	//生成一个file结构
    file = get_empty_filp();
	//初始化nameidata
    s = path_init();
    //link_path_walk对路径名进行查找
    //do_last获取文件对应的inode对象，并且初始化file对象
    while(!(error = link_path_walk(s,nd))&&
         (error = do_last(nd,file,op,&opened)) > 0) {
        
    }
    terminate_walk(nd);
    return file;
}

static int do_last(struct nameidata *nd,struct file *file，const struct open_flags *op,int *opened) {
	//到dcache中找
    error =	lookup_fast(nd,&path,&inode,&seq);
    ........
        //如果缓存中没有，会创建一个新的dentry，并调用上级目录的inode->inode_operations->lookup
	    error = lookup_open(nd,&path,file,op,got_write,opened);
    ........
    //真正打开文件,最重要的一件事就是调用f_op->open,将文件信息填写到struct file这个结构
    error = vfs_open(&nd->path,file,current_cred());
}
```

![image-20220221000501099](os.assets/image-20220221000501099.png)

read系统调用

```c++
SYSCALL_DEFINE3(read,unsigned int,fd,char __user *,buf,size_t,count) {
    struct fd f = fdget_pos(fd);
    ....
    loff_t pos = file_pos_read(f.file);
    ....
    ret = vfs_read(f.file,buf,count,&pos);
}

ssize_t __vfs_read(struct file *file,char __user *buf,size_t count,loff_t *pos) {
    if (file->f_op->read)
      return file_op->read(file,buf,count,pos);
    else if (file->f_op->read_iter)
        return new_sync_read(file,buf,count,pos);
    else 
        return -EINVAL;
}
```

**ext4文件系统层**

```c++
const struct file_operations ext4_file_operations = {
......
    .read_iter = ext4_file_read_iter,
    .write_iter = ext4_file_write_iter
......
}
```

ext4_file_read_iter会调用generic_file_read_iter,ext4_file_write_iter会调用__generic_file_write_iter

```c++
ssize_t generic_file_read_iter(struct kiocb *iocb,struct iov_iter *iter) {
    if(iocb->ki-flags & IOCB_DIRECT) {
        struct address_space *mapping = file->f_mapping;
        //direct
        retval = mapping->a_pos->direct_IO(iocb,iter);
    }
    retval = generic_file_buffered_read(iocb,iter,retval);
}

ssize_t __generic_file_write_iter(struct kiocb *iocb,struct iov_iter * from) {
    if(iocb->ki_flags & IOCB_DIRECT) {
        written = generic_file_direct_write(iocb,from);
    }else{
        written = generic_perform_write(file,from,iocb->ki_pos);
    }
}
```

根据是否使用内存作为缓存，可以把文件I/O操作分为两种类型：

* 缓存I/O，大多数文件系统默认I/O操作都是缓存I/O。对于读，操作系统会先检查，内核的缓冲区有没有必要的数据，如果已经缓存了，直接从缓存返回，否则从磁盘读取，然后缓存；对于写，操作系统会先将数据从用户空间复制到内核空间的缓存中。
* 直接I/O，直接访问磁盘数据

**带缓存的写入操作**

```c++
ssize_t generic_perform_write(struct file *file,struct iov_iter *i,loff_t pos) {
    struct address_space *mapping = file->f_mapping;
    const struct address_space_operations *a_pos = mapping->a_pos;
    do{
        struct page *page;
        unsigned long offset;
        unsigned long bytes;
        status=a_ops->write_begin(file,mapping,pos,bytes,flags,&page,&fsdata);
		//将写入的内容从用户态拷贝到内核态的页中
        copied=iov_iter_copy_from_user_atomic(page,i,offset,bytes);
        flush_dcache_page(page);
        status=a_ops->write_end(file,mapping,pos,bytes,copied,page,fsdata);
        pos+=copied;
        written+=copied;
        //看脏页是否太多，是否需要写回到磁盘
        balance_dirty_pages_ratelimited(mapping);
    }while(iov_iter_count(i))
}
```

内核中，缓存以页为单位放到内存。file有个struct address_space用于关联文件和内存，就是在这个结构里，有一棵树，用于保存所有与这个文件相关的缓存页。 

* 块设备，将信息存储在固定大小的块中，
* 字符设备，发送接受的都是字节流，不用考虑任何块结构，没有办法寻址

由于块设备传输的数据量比较大，控制器往往有缓冲区，cpu与**设备控制器**的寄存器和数据缓冲区进行通信的方式：

* 每个控制寄存器被分配一个I/O端口，可以通过特殊的汇编指令（例如in/out，类似的指令）操作这些寄存器
* 数据缓冲区，可内存映射I/O，可以分配一段内存给它，就像读写内存一样读写数据缓冲区。ioremap

控制器的寄存器一般都会有状态标志位，可以通过检测状态标志位，来确定输入或者输出操作是否完成。第一种方式为轮询等待，第二种方式为中断。为了响应中断，一般会有一个**硬件的中断控制器**，当设备完成任务后触发中断到**中断控制器**，中断控制器就通知CPU。可分为**软中断**和**硬中断**。

有的设备需要读取或者写入大量数据，这种类型的设备就需要支持DMA功能。CPU只需要对DMA控制器下指令，说想要读取多少数据，放在内存的某个地方就可以了，接下来DMA控制器就会发指令给磁盘控制器，读取磁盘的数据到指定的内存位置，传输完成，DMA控制器发中断通知CPU指令完成，CPU就可以直接用内存里现成的数据。DMA区域

**设备控制器**不属于操作系统的一部分。但是设备驱动程序属于操作系统的一部分。操作系统的内核代码可以像调用本地代码一样调用设备驱动程序的代码，**而驱动程序的代码需要发出特殊的面向设备控制器的指令，才能操作设备控制器**。

一般的流程：设备驱动程序初始化的时候，要先注册一个该设备的中断处理函数。中断的时候，触发的函数是do_IRQ,这个函数是中断处理的统一入口。

对于块设备，在驱动程序之上，文件系统之下，还需要一层**通用设备层**，里面的逻辑和硬盘设备没有什么关系，是通用的逻辑。

**用文件系统接口屏蔽驱动程序的差异**

所有设备在/dev/下创建一个特殊的设备文件，这个特殊设备文件也有inode，它不关联到硬盘或其他任何存储介质上的数据，而是建立了与某个设备驱动程序的连接。

假设/dev/sdb,这是一个设备文件，这个文件本身和硬盘上的文件系统没有任何关系，本身也不对应硬盘的上的任何一个文件，/dev/sdb其实是在一个特殊的文件系统devtmpfs中

主设备号定位设备驱动程序，次设备号作为参数传递给启动程序，选择相应的单元

Linux的驱动程序已经被写成和操作系统有标准接口的代码，可以看成一个标准的内核模块。在linux里，安装驱动程序，其实就是加载一个内核模块。

lsmod   insmod  mknod可以手动加载驱动

sysfs和udev服务，当一个设备新插入系统时，内核会检测到这个设备，并会创建一个内核对象kobject。这个对象通过sysfs文件系统展现到用户层，同时内核还向用户空间发送一个热插拔消息。udevd会监听这些信息，在/dev中创建对应的文件。

**构建一个内核模块**：

第一，头文件部分，一般都有<linux/module.h>和<linux/init.h>

第二，定义一些函数，处理内核模块的主要逻辑，例如打开、关闭、中断

第三，定义一个file_operations结构，设备想被文件系统的接口操作就需要定义

第四，定义整个模块的初始化和退出函数

第五，调用module_init和module_exit

第六，声明license，调用MODULE_LICENSE

lp.c的初始化函数:

```c++
static int __init lp_init(void) {
    if(register_chrdev(LP_MAJOR,"lp",&lp_fpos)) {
        printk(KERN_ERR "lp:unable to get major %d\n",LP_MAJOR);
        return -EIO;
    }
}

int __register_chrdev(unsigned int major,unsigned int baseminor,
                      unsigned int count,const char *name,const struct file_operations *fops)
{
    struct char_device_struct *cd;
    struct cdev *cdev;
    int err = -ENOMEM;
    cd = __register_chrdev_region(major,baseminor,count,name);
    cdev = cdev_alloc();
    cdev->owner = fops->owner;
    cdev->ops = fops;
    kobject_set_name(&cdev->kobj,"%s",name);
    //将这个字符设备添加到内核中一个kobj_map的结构，来统一管理所有字符设备
    err = cdev_add(cdev,MKDEV(cd->major,baseminor),count);
    cd->cdev = cdev;
    return major? 0 : cd->major;
}
int cdev_add(struct cdev *p,dev_t dev,unsigned count){
    int error;
    p->dev = dev;
    p->count = count;
    error = kobj_map(cdev_map,dev,count,NULL,exact_match,exact_lock,p);
    kobject_get(p->kobj.parent);
    return 0;
}
```

**mknod系统调用**

```c++
SYSCALL_DEFINE3(mknod,const char __user *,filename,umode_t,mode,unsigned,dev){
    return sys_mknodat(AT_FDCWD,filename,mode,dev);
}
SYSCALL_DEFINE4(mknodat,int,dfd,const char __user *,filename,umode_t,mode,unsigned,dev){
    struct dentry *dentry;
    struct path path;
    dentry = user_path_create(dfd,filename,&path,lookup_flags);
    switch(mode & S_IFMT){
        case S_IFCHR:case S_IFBLK:
            error = vfs_mknod(path.dentry->d_inode,dentry,mode,new_decode_dev(dev));
            break;
    }
}
```

vfs_mknod会调用相应文件系统的inode_operations

```c++
/dev-devtmpfs
static struct dentry *dev_mount(struct file_system_type *fy_type,int flags,const char *dev_name,void *data)
{
#ifdef CONFIG_TMPFS
	return mount_single(fs_type,flags,data,shmem_fill_super);
#else
	return mount_single(fs_type,flags,data,ramfs_fill_super);
#endif
}

static struct file_system_type dev_fs_type = {
    .name = "devtmpfs",
    .mount = dev_mount,
    .kill_sb = kill_litter_super,
}

static const struct inode_operations ramfs_dir_inode_operations = {
    .mknod = ramfs_mknod,
}

static const struct inode_operations shmem_dir_inode_operations = {
    #ifdef CONFIG_TMPFS
    .mknod = shemem_mknod,
}
这两个实现都会调用init_specail_inode
void init_special_inode(struct inode *inode,umode_t mode,dev_t rdev){
    inode->i_mode = mode;
    if(S_ISCHR(mode)){
        inode->i_fop = &def_chr_fops;
        inode->i_rdev = rdev;
    }else if(S_ISBLK(mode)){
        inode->i_fop = &def_blk_fops;
        inodec->i_redv = rdev;
    }else if(S_ISFIFO(mode)){
        inode->i_fop = &pipefifo_fops;
    }else if(S_ISSOCK(mode));
}

static int chrddev_open(struct inode *inode,struct file *filp){
    const struct file_operations *fpos;
    struct cdev *p;
    struct cdev *new = NULL;
    int ret = 0;
    p = inode->i_cdev;
    if(!p){
        struct kobject *kobj;
        int idx;
        kobj = kobj_lookup(cdev_map,inode->i_rdev,&idx);
        new = container_of(kobj,struct cdev,kobj);
        p = inode->i_cdev;
        if(!p){
            inode->i_cdev = p = new;
            list_add(&inode->i_devices,&p->list);
            new = NULL;
        }
    }
    fops = fops_get(p->ops);
    replace_fops(filp,fops);
    if(filp->f_op->open){
        ret = filp->f_op->open(inode,filp);
    }
}
```

**使用IOCTL控制设备**

ioctl是一个系统调用，可以通过这个调用做一些特殊的I/O操作

```c++

SYSCALL_DEFINE3(ioctl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
{
  int error;
  struct fd f = fdget(fd);
......
  error = do_vfs_ioctl(f.file, fd, cmd, arg);
  fdput(f);
  return error;
}


int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
       unsigned long arg)
{
  int error = 0;
  int __user *argp = (int __user *)arg;
  struct inode *inode = file_inode(filp);


  switch (cmd) {
......
  case FIONBIO:
    error = ioctl_fionbio(filp, argp);
    break;


  case FIOASYNC:
    error = ioctl_fioasync(fd, filp, argp);
    break;
......
  case FICLONE:
    return ioctl_file_clone(filp, arg, 0, 0, 0);


  default:
    if (S_ISREG(inode->i_mode))
      error = file_ioctl(filp, cmd, arg);
    else
      //最终会调用file_operations的unlocked_ioctl
      error = vfs_ioctl(filp, cmd, arg);
    break;
  }
  return error;
```

注册中断和处理中断：

```c++
static int logibm_open(struct input_dev) {
	//注册中断
    if(request_irq(logbim_interrupt,0,"logibm",NULL)) {
        return -EBUSY;
    }
}

static irqreturn_t logibm_interrupt(int irq,void *dev_id) {
    //进行一些处理
    return IRQ_HANDLED;
}

static request _irq(....) {
    return request_threaded_irq(...);
}

int request_threaded_irq(unsigned int irq,irq_handler_t handler,irq_handler_t thread_fn,unsigned long irqflags,const char *devname,void *dev_id) {
    struct irqaction *action;
    struct irq_desc *desc;
    int retval;
    //根据中断号查找中断描述结构
    desc = irq_to_desc(irq);
    action = kzalloc(sizeof(struct irqaction),GFP_KERNEL);
    action->handler=handler;
    action->thread_fn;
    action->flags=irqflags;
    action->name=devname;
    action->dev_id=dev_id;
    retval=__setup_irq(irq,desc,action);
}

struct irq_desc {
    struct irqaction *action;/**irq action list*/
    struct module *owner;
    const char *name;
}

struct irqaction {
    irq_handler_t handler;
    void *dev_id;
    void __percpu *percpu_dev_id;
    struct irqaction *next;
    //如果中断函数在单独的线程执行，thread_fn,thread
    irq_handler_t thread_fn;
    struct task_struct *thread;
    struct irqaction *seconfary;
    unsigned int irq;
    unsigned int flags;
    unsigned long thread_flags;
    unsigned long thread_mask;
    const char *name;
    struct proc_dir_entry *dir;
}

#idef CONFIG_SPARSE_IRQ
static RADIX_TREE(irq_desc_tree,GFP_KERNEL);
struct irq_desc *irq_to_desc(unsigned int irq){
    return radix_tree_lookup(&irq_desc_tree,irq);
}
#else
struct irq_desc irq_desc[NR_IRQS] __cacheline_aligned_in_smp = {
    [0...NR_IRQS-1]={}
}
struct irqdesc *irq_to_desc(unsigned int irq){
    return (irq < NR_IRQS) ? irq_desc + irq : NULL;
}
#endif

static int _setup_irq(unsigned int irq,struct irq_desc *desc,struct irqaction *new) {
    struct irqaction *old,**old_ptr;
    unsigned long flags,thread_mask = 0;
    int ret,nested,shared = 0;
    new->irq=irq;
   	//create a handler when a thread function is supplied and the interrupt does not nest into another interrupt thread
    if(new->threads_fn && !nested) {
        ret = setup_irq_thread(new,irq,false);
    }
    old_ptr = &desc->action;
   	old = *old_ptr;
    if(old){
        do{
            thread_mask |=old->thread_mask;
            old_ptr = &old->next;
            old = *old_ptr;
        }while(old)
    }
    *old_ptr=new;
    if(new->thread){
        wake_up_process(new->thread);
    }
}

static int setup_irq_thread(struct irqaction *new,unsigned int irq,bool secondary) {
    struct task_struct *t;
    struct sched_param param = {
        .sched_priority = MAX_USER_RT_PRIO/2;
    }
    t = kthread_create(irq_thread,new,"irq/%d-%s",irq,new->name);
    sched_setscheduler_nocheck(t,SCHED_FIFO,&param);
    get_task_struct(t);
    new->thread=t;
    return 0;
}
```

中断发生的流程：

* 外部设备给中断控制器发送**物理中断信号**
* 中断控制器将**物理中断信号**转换为中断向量**interrupt vector**，发给CPU
* CPU都会有个中断向量表，根据**interrupt vector**调用**IRQ**函数
* **IRQ**函数中，将**interrupt vector**转化为**抽象中断层的中断信号irq**

数据结构**interrupt vector**的解析

```css
Linux IRQ vector layout.

There are 256 IDT entires(per CPU - each entry is 8 bytes)which can be defined by Linux.They are used as a jump table by the CPU
when a gived vector is triggered - by a CPU-external,CPU-internal or software-triggered event.

Linux sets the kernel code address each entry jumps to early during bootup,and never changes them.This is the general layout of the IDT entries:
Vectors 0...  31:system traps and exceptions - hardcoded events
Vectors 32...127:device interrupts
Vectors 128     :legacy int80 syscall interface
Vectors 129...  :INVALIDATE_TLB_VECTOR_START-1 except 204:device interrupts
Vectors INVALIDATE_TLB_VECTOR_START...255:special interrupts

64-bit x86 has per CPU IDT tables,32-bits has one shared IDT table.

arch/x86/kernel/traps.c中
gate_desc_idt_table[NR_VECTORS] __page_aligned_bss;

start_kernel->trap_init，其中有很多set_intr_gate,其最终都会调用到_set_gate,在其中设置中断处理函数并放到中断向量表中
设置好前32位中断后，会单独设置IA32_SYSCALL_VECTOR,也即128
最后会把idt_table放到一个固定的虚拟地址
start_kernel调用完trap_init后，还会调用init_IRQ->native_IRQ来初始化其他设备中断
void __init native_init_IRQ(void){
    int i;
    i=FIRST_EXTERNA_VECTOR;
    #ifndef CONFIG_X86_LOCAL_APIC
    #define first_system_vector NR_VECTORS
    #endif
    for_each_clear_bit(i,used_vectors,first_system_vector) {
        set_intr_gate(i,irq_entries_start + 8*(i-FIRST_EXTERNAL_VECTOR));
    }
}

irq_entires_start是个表，定义了FIRST_SYSTEM_VECTOR - FIRST_EXTERNAL_VEXTOR项。每一项都是中断处理函数，会跳到common_interrupt执行，调用完毕后，就从中断返回，调用完毕后，会从中断返回，这里会区分返回用户态还是内核态

//do_IRQ hadles all normal device IRQ's(the special SMP cross-CPU interrupts have their own specific hadlers)
__visible unsigned int __irq_entry do_IRQ(struct pt_regs *regs) {
    struct pt_regs *old_regs = set_irq_regs(regs);
    struct irq_desc *desc;
    unsigned vector = ~regs->orig_ax;
    desc = __this_cpu_read(vector_irq[vector])
    if(!handle_irq(desc,regs)){
        
    }
    set_irq_regs(old_regs);
    return 1;
}
vector_irq 这个Per CPU变量负责维护每个CPU对应中断控制器传递的物理中断号与全局统一的虚拟中断号的对应关系（在系统初始化调用_assign_irq_vector,将虚拟中断号分配到某个CPU上的中断向量）

do_IRQ->handle_irq->generic_handle_irq_desc,然后会调用irq_desc的handle_irq->__handle_irq_event_percpu
irqreturn_t __handle_irq_event_percpu(struct irq_desc *desc,unsigned int *flags) {
    irqreturn_t retval = IRQ_DONE;
    unsigned int irq = desc->irq_data.irq;
    struct irqaction *action;
    record_irq_time(desc);
    for_each_action_of_desc(desc,action) {
        irqreturn_t desc;
        res = action->handler(irq,action->dev_id);
        switch(res){
            case IRQ_WAKE_THREAD:
                __irq_wake_thread(desc,action);
            case IRQ_HANDLED:
                *flags|=action->flags;
            	break;
            default:
                break;
        }
        retval |= res;
    }
}
```

块设备在mknod命令会根据主/次设备号创建一个特殊inode，其中打开设备文件用的是blkdev_open,里面调用blkdev_get打开这个设备

将一个块设备mount成ext4文件系统：

```c++
ext_mount->mount_bdev {
    //找到设备并打开它
    block_device bdev=blkdev_get_by_path();
	//根据打开的设备文件，填充ext4文件系统
    s=sget(bdev);   
}
blkdev_get_by_path{
    block_device bdev = lookup_dev();
    blkdev_get(bdev);
}

blkdev_get_by_path->lookup_dev{
    kern_path(pathname,LOOKUP_FOLLOW,&path);
    bdev=bd_acquire(inode);
}
//bd根据传进来的dev_t在blockdev_superblock中找到bdev中的inode（根据devtmpfs中inode找到bdev中inode）
bd_acquire->bdget(inode->i_rdev);
```

block_device结构：

```c++
struct block_device {
    dev_t bd_dev;
    int bd_openers;
    struct super_block * bd_super;
    struct block_device * bd_contains;
    unsigned bd_block_size;
    struct hd_struct * bd_part;
    unsigned bd_part_count;
    int bd_invalidated;
    struct gendisk *bd_disk;
    struct request_queue * bd_queue;
    struct backing_dev_info *bd_bdi;
    struct list_head bd_list;
}
```







































































































































































































































#### 任务2.熟悉linux命令行操作

[Vmware虚拟化概念原理_曹世宏的博客-CSDN博客_vmware虚拟化](https://blog.csdn.net/qq_38265137/article/details/80370524)



























