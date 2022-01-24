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

<img src="C:\Users\dmzc\Desktop\Learing\os\images\1.webp" alt="img" style="zoom: 33%;" />

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

![image-20220112230956774](C:\Users\dmzc\Desktop\Learing\os\images\os\image-20220112230956774.png)

![image-20220112235605391](C:\Users\dmzc\Desktop\Learing\os\images\os\image-20220112235605391.png)

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
    void (*task_fork) (struct task_struct *p);
    void (*task_dead) (struct task_struct *p);
    
    void (*switched_from) (struct rq *this_rq,struct task_struct *task);
    void (*switched_to) (struct rq *this_rq,struct task_struct *task);
    void (*prio_changed) (struct rq *this_rq,struct task_struct *task,int oldprio);
    unsigned int(*get_rr_interval) (struct rq *rq,struct task_struct *task);
    void (*update_curr) (struct rq *rq);
}
```

此结构定义了很多方法,用于在队列上操作任务



#### 任务2.熟悉linux命令行操作

[Vmware虚拟化概念原理_曹世宏的博客-CSDN博客_vmware虚拟化](https://blog.csdn.net/qq_38265137/article/details/80370524)



























