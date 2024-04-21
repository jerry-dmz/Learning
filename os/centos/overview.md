## 基础

### 虚拟化技术

#### Linux虚拟化

##### Qemu

**完全虚拟化**，模拟出硬件，Guest OS同模拟出的硬件交互，Qemu将指令转译后交给真正的硬件。

##### KVM

基于内核的虚拟机，一种用于Linux内核中的虚拟化基础设施，可以将Linux内核转换为一个**虚拟机监视器**。

只提供抽象的设备，不模拟处理器，开放**/dev/kvm**接口，供用户模式的主机使用。

##### Qemu-kvm

Qemu将kvm整合，通过**ioctl调用/dev/kvm接口**，将有关**CPU**指令的部分交由内核模块做。但是还会模拟其他设备，为了解决性能问题，采取半虚拟化的方式，让Guest OS加载特殊驱动，指令发给驱动，经过特殊处理，例如排队、缓存、批量处理等性能优化方式，最终发给真正的硬件。

##### vrish

属于`libvirt`工具，是目前使用最广泛的对`KVM`虚拟机进行管理的工具和API。

`libvirt`分服务端和客户端，libvirtd调用qemu-kvm操作虚拟机。

[Linux云计算底层技术之网络虚拟化 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/74634285)

[Linux虚拟网络技术学习 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/373091228)

### 磁盘

linux中，一切皆文件，几乎所有硬件装置文件都在**/dev**目录。以下是常见的装置名。

| 装置              | 文件名                                                       |
| ----------------- | ------------------------------------------------------------ |
| SCSI/SATA/USB硬盘 | **/dev/sd[a-p]**                                             |
| Virtl/O           | **/dev/vd[a-p] **用于虚拟机内                                |
| 软盘              | **/dev/fd[0-7]**                                             |
| 打印机            | /dev/lp[0-2]（25针打印机）、/dev/usb/lp[0-15]（usb界面）     |
| 鼠标              | /dev/input/mouse[0-15]（通用）、/dev/psaux（ps/2界面）、/dev/mouse（当前鼠标） |
| CDROM/DVDROM      | /dev/scd[0-1]（通用）、/dev/sr[0-1]（通用）、/dev/cdrom（当前CDROM） |
| 磁带机            | /dev/ht0（IDE界面）、/dev/st0（SATA/SCSI界面）、/dev/tape（当前磁带） |
| IDE硬盘机         | /dev/hd[a-d]（旧系统）                                       |

#### 分区

分区就是**对分区表进行设定**。

##### MSDOS

* **MBR**，开机关机程序，446bytes

* **分区表**，记录磁盘分区状态，**64bytes**

  最能记录**四组**分区记录，每组记录**开始/结束磁柱号码**。

  **延伸分区**目的就是使用额外的扇区记录分区信息，本身并不能被拿来格式化，可以透过延伸分区所指向的那个区块继续做分区的记录（**逻辑分区**）。

  * 主要分区与延伸分区最多有四笔（**64**bytes限制）
  * 延伸分组最多有**一个**
  * 逻辑分区是由延伸分区持续切割出的分区槽
  * 能够被格式化的，作为数据存取的，只有**主要分区**和**逻辑分区**
  * 逻辑分区数量依操作系统而不同。

  **sd[1-4]预留给主要分区和延伸分区**

[Extended boot record - Wikipedia](https://en.wikipedia.org/wiki/Extended_boot_record)

##### GPT

4k设计的扇区，因此在扇区定义，现在常采用**LBA**(Logical Block Address)来处理。GPT将所有区块以**LBA**来规划。和MBR仅用第一个512bytes扇区记录不同，GPT使用**34**个LBA区块来记录分区信息。整个磁盘的最后**33个LBA**也被拿来做另一个备份。

* **LBA0（MBR兼容区块）**，保留了446bytes的MBR记录，而原来分区表则放入特殊标志，用来表示是GPT格式磁盘。
* **LBA1（GPT表头记录）**，记录了**分区表本身的位置和大小**，同时记录了**备份用GPT分区放置的位置**，还记录了分区表的检验机制码(CRC32)。如果不对，则从备份恢复。
* **LBA2-33(实际记录分区信息处)**，每个LBA可以有**4笔分区记录**。每笔记录用到了**128bytes空间**,除了记录相关标识符，剩余的64bits来记录开始/结束的扇区号码

要使用**gdisk或parted**指令来操作这个格式的分区，**grub2**才识别GPT分区。

#### 开机启动

##### BIOS

读取MBR,MBR主要功能：

* 提供选单，不同的开机项目
* 加载核心文件
* **转交其他loader**，将开机管理功能转交给其他loader
  * 每个分区**都可以有**自己的启动扇区
  * loader只知道自己分区的核心，以及其他loader
  * loader可直接指向或间接将管理权转交

linux安装时，可以选择将开机管理程序安装在MBR或别的分区槽

windows安装时，会主动覆盖MBR以及自己所在分区槽的启动扇区（**现在好像已改善**）

##### UEFI

**Unified Extensile Firmware Interface**,以下是与BIOS的区别：

| 比较项                 | 传统BIOS                                | UEFI               |
| ---------------------- | --------------------------------------- | ------------------ |
| 语言                   | 汇编                                    | C                  |
| 硬件资源控制           | BIOS中断、不可变内存存取、不可变I/O存取 | 使用驱动程序与协议 |
| 运作环境               | 实模式                                  | 保护模式           |
| 扩充方式               | IRQ                                     | 加载驱动           |
| 三方厂商支持           | 较差                                    | 较佳可支持多平台   |
| 图形化能力             | 较差                                    | 较佳               |
| 内建简化操作系统前环境 | 不支持                                  | 支持               |

[优化Linux bootloader速度的究极之路：从GRUB到EFI Stub - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/28708585)

## 基本概念

### 语系

```shell
locale #查看语系
LANG=en_US.utf8 #只与输出信息有关
export LC_ALL=en_US.utf8 #其他不同的信息
```

## 快捷键

* Tab，连续两次，命令补全、文件补全、参数补全（安装bash-completion）
* shift + pageup/pagedown,查看上一页/下一页

## 帮助

### --help

 简单用法展示

### man

* 1，用户在shell可以操作的指令或可执行文件
* 2，系统核心可调用的函数与工具
* 3，常用的函数和库
* 4，设备文件的说明，/dev
* 5，配置文件或者某些文件的格式
* 6，游戏
* 7，惯例和协议，例如linux文件系统、网络协议、ASCLL码等的说明
* 8，系统管理员可使用的管理指令
* 9，根kernel相关的文件

/关键字，向下搜索

？关键字，向上搜索

### info

## 文件权限与目录配置

### 文件权限

/etc/passwd 账户信息

/etc/shadow 密码信息

/etc/group 组信息

```shell
-rwxrw-r-- 2 root root 1864 May 4 18:01 /root/test.txt
# 第一栏依次为所有者、组内账号、其他账号具备权限
# 第二栏表示有多少文件使用此inode
# 第三栏、第四栏分别代表文件所有者、所属群组
# 第5栏表示文件大小，默认bytes
# 文件创建时间或最后修改时间
```

```shell
# 添加用户
adduser 
# 添加用户组
groupadd
# 改变所属群组
chgrp 
# 改变所有者
chown 
# 改变文件权限，SUID,SGID,SBIT等特性
chmod 
chmod -R 777 test.txt
chmod u=rwx,go=rx text.txt
chmod a+x
chmod a-x
```

文件的x权限代表该文件是否能执行，目录的x权限代表是否能进入该目录

设定的权限对于root来说是不生效的

文件类型：

* -正规文件，纯文本（ASCLL码）、二进制文件、数据格式文件
* d目录
* l链接
* c设备文件
* s数据接口文件sockets
* p特殊文件类型FIFO？？？

### 目录配置(FHS)

**Filesystem Hierarchy Standard**

规范每个特定的目录下应该放置什么样子的数据。针对目录架构仅定义出三层目录下应该放置什么数据：

* **/** （根目录）:与开机系统有关
* **/usr** （**Unix software resource**）：与**软件安装/执行**有关
* **/var** （**Variable**）:与**系统运作**有关 

#### 根目录/的意义

与**开机/还原/系统修复**有关。

建议：根目录所在分区**越小越好**、应用程序安装软件最好**不要与根目录在同一个分区**。

| 目录(加粗必须)        | 内容                                                         |
| --------------------- | ------------------------------------------------------------ |
| **/usr**              | **单人模式**还能被操作的指令，可以被root和一般账号使用       |
| **/boot**             | **开机用到文件**，linux核心文件、开机配置文件等              |
| **/dev**              | **装置、接口设备**对应的文件。                               |
| **/etc**              | 配置文件。/etc/opt(**必须**)                                 |
| **/lib**              | **开机**会用到的函式库，以及**/bin、/sbin**底下指令用到的函式库。/lib/modules/（**必须**） |
| **/media**            | **可移除的装置**，包括软盘、光盘、dvd等装置挂载于此。        |
| **/mnt**              | **临时挂载**额外的装置。                                     |
| **/opt**              | 外部或第三方软件（通常**不会被包含在发行版的存储库**中）     |
| **/run**              | **系统开机后产生的各项信息**，以前是**/usr/run**             |
| **/sbin**             | 设定系统环境，只有root才能使用。放在/sbin下是开机、修复、还原所需要的。<br /><br />某些服务器软件程序，一般放置在/usr/sbin，本机自行安装的软件，则放置在**/usr/local/sbin**. |
| **/srv**              |                                                              |
| **/tmp**              | 用户或正在执行程序**暂时放置**文件的位置。建议开机时清空这个目录。 |
| **/usr**              |                                                              |
| **/var**              |                                                              |
| /home(非必须)         | 系统默认家目录，**cd ~** 代表回家                            |
| /lib\<qual\>          | 用来存放与**/lib**不同格式的二进制函式库，例如支持64位的**lib64函式库** |
| /root                 | 系统管理员家目录。                                           |
| */lost+found*(没规定) | **ext文件系统**才会产生，文件系统错误时，记录遗失片段        |
| **/proc               | 本身是一个虚拟文件系统，放置的数据都在内存，例如系统核心、进程信息、网路状态等。 |
| /*sys*                | 类似/proc,有什么区别呢？？？                                 |

#### /usr的意义

**属于可分享、不可变动的**

建议软件开发者将它们的数据合理分布到这个目录的次目录

所有系统默认的软件(**distribution发布者提供的软件**)都会放置到这里。

| 目录(加粗必须)      | 内容                                                         |
| ------------------- | ------------------------------------------------------------ |
| **/usr/bin/**       | 一般用户能使用的指令，**此目录不要再有子目录**。             |
| **/usr/lib/**       | 与/lib功能类似                                               |
| **/use/local/**     | 系统管理员在本机自己下载安装的软件（**非distribution默认提供者**） |
| **/usr/sbin/**      | 非系统正常运作需要的系统指令                                 |
| **/usr/share/**     | **主要放置只读架构的数据文件，也包括共享文件**。放置的数据几乎是部分硬件架构均可读取的数据。/usr/share/man:联机帮助文件。/usr/share/doc:软件杂项的文件说明。/usr/share/zoneinfo:与时有关的时区文件 |
| /usr/games/(非必须) |                                                              |
| /usr/include/       | c/c++头文件                                                  |
| /usr/libexec        | 被程序使用的二进制文件或脚本                                 |
| /usr/lib\<qual\>/   | 与/lib/\<qual\>/功能相同                                     |
| /usr/src/           | 源码，核心源码则放在/usr/src/linux/目录                      |

#### /var的意义

常态性变动的文件，包括缓存、log file等。

| 目录（加粗必须） | 内容                                                         |
| ---------------- | ------------------------------------------------------------ |
| **/var/cache/**  | 缓存                                                         |
| **/var/lib/**    | 程序本身需要使用到的**数据文件**，例如mysql的数据目录        |
| **/var/lock/**   | 某些装置或要控制并发访问的锁，移动到了/run /lock/            |
| **/var/log/**    | 登录信息                                                     |
| **/var/mail/**   | 邮箱，移动到**/var/spool/mail/**                             |
| **/var/run/**    | 链接到/run                                                   |
| **/var/spool/**  | 放置一些队列数据，排队等待其他程序使用，被使用后通常被删除。 |

#### LSB

Linux Standard Base

yum inatll redhat-lsb

lsb_release -a

## 文件目录管理

* ls
* cp，复制文件目录，建立链接，对比两文件新旧而予以更新
  * 是否需要完整保留来源文件的信息，要保留就加-a参数
  * 来源文件是否为链接文件，此时可以加参数控制是否真实文件的属性
  * 来源文件是否为特殊文件、目录
* rm
* mv,移动文件与目录，或更名
* rename
* basename,取得路径的文件名
* dirname，取路径的目录名称

#### 文件内容查阅

* cat,由第一行开始显示
* tac，从最后一行开始显示
* nl，输出时显示行号
* more，一页页显示内容
* less，与more类似，但是可以向前翻页
* head，只看头几行
* tail，只看尾几行
* od，以二进制方式读取内容
* file，查看文件的基本数据，比如是ascll或二进制

#### 文件时间

* mtime,文件内容数据变化，更新这个时间，文件属性或权限变更时不会更新
* ctime,文件状态变化时时，比如属性或权限，更新这个时间
* atime,文件被读取时，更新这个时间

touch可以用来建立新文件，也可以修正文件时间

#### 默认权限、隐藏权限

在ext文件系统下，还可以设定其他系统隐藏属性

* chatrr

  A,存取文件或目录时，atime不会改变

  S，文件修改同步写入磁盘

  a,只能增加数据，不能修改、删除

  c,会自动文件压缩，读取时解压缩

  d,dump执行时，设定d属性可使得文件不被备份

  i,让一个文件**不能被删除、改名、设定链接、新增/修改数据**

  s,文件被删除，完全移出硬盘空间

  u，与s相反

* lsattr

* unmask,新建文件或目录时，默认权限，分数为需要减去权限

##### SUID(4)

s出现在文件拥有者的x权限上时，Set UID

* 仅对二进制程序有用，对shell script、目录无效
* 执行本身对于该程序要有x的权限
* 本权限仅在执行该程序过程有效
* 执行者**将具有该程序拥有者**的权限，passwd

##### SGID(2)

**s**出现在文件拥有者的x权限上时，Set GID

可以针对文件或目录来设定，如果只是对文件，则：

* 对二进制有用
* 程序执行者有x权限,如果没有也可以设置，但是会是**S**
* 执行过程会获得该程序群组支持，**locate /var/lib/mlocate/mlocate.db**

##### SBIT(1)

只针对目录有效

* 用户对此目录有w、x权限
* 用户在该目录下建立文件或目录时，仅有自己或root有权力删除文件。tmp目录

#### 指令/文件搜索

* which，查找指令的完整路径名，找不到内置指令，如history，只能找PATH下可执行文件

* whereis,在一些特定的目录中寻找文件，主要针对/bin/sbin,以及/usr/share/man等，-l可以列出搜索路径

* locate，-S列出查询使用数据库，upatedb更新数据库，默认应该是每天更新一次

* find [PATH] [option] [action]

  ```shell
  find /home -user dmzc;
  find / -nouser;
  find / -name passwd;
  find / -name "*passwd*";
  find /run -type s;
  find / -perm /7000;
  find /usr/bin /usr/sbin -perm /6000;
  find /usr/bin /usr/sbin -perm /7000 -exec ls -l {}\;
  ```

## 磁盘与文件系统管理

传统磁盘与文件系统，一个分区只能被格式化成一个文件系统。但是由于新技术的应用，LVM、磁盘阵列这些技术可以**将一个分区槽格式化多个文件系统，也能将多个分区槽合成一个文件系统**。

因此，称呼**一个可被挂载的数据为一个文件系统**。

文件系统通常将实际数据和文件属性分为两部分存储：

* 权限和属性放在到inode中，同时记录此文件的数据所在block号码
* 实际数据放到data block区块
* 还有一个superblock记录整个文件系统的整体信息，包括inode与block的总量、使用量、剩余量等。

### **索引式文件系统**

FAT文件系统没有inode存在，链表形式存储一个文件所有区块。文件系统**一开始就将inode与block规划好了**，除非重新格式化（或利用resize2fs等指令变更大小）。

将所有inode、block放在一起，可能太大了，因此ext2文件系统在格式化时划分多个**区块群组**，每个区块群组都有独立的**inode/block/superblock**系统。一个区块群组的组成：

**Supeblock  =>  FileSystem Description  =>  block bitmap  =>  Inode bitmap  =>  Inode Table  =>  Data Block**

#### data block

放置文件内容数据，ext2支持的大小有1K、2K及4K三种，**格式化时大小就固定**。每个block都有编号，以方便inode的记录。**每个block最多只能放置一个文件的数据**。

#### Inode Table

* 每个inode固定128bytes（ext4可设定到256bytes）
* 每个文件仅占用一个inode

inode只花4byte记录block号码，记录大文件采用：

* 12直接，直接存储放数据的block号

* 一个间接，用一个block记录号码

* 一个双间接，...

* 一个三间接,...

以block为1k为例：

12\*1K  + 256\*1K + 256\*256\*1K + 256 * 256 * 256 * 1K =16GB

2K、4K大小计算中，block受到Ext2文件系统限制？？？TODO：什么限制

#### Inode bitmap

记录inode使用情况

#### block bitmap

记录block使用情况

#### FileSystem Description

描述每个block group的开始、结束号码，以及说明每个区段分别介于哪一个block号码之间。

#### Superblock

* block、inode总量
* 未使用和已使用的inode/block数量
* block/inode的大小
* 文件系统的挂载时间、最近一次写入数据的时间、最后一次校验磁盘的的时间等
* valid bit数值，表示文件系统是否被挂载

大小为1024bytes

每个block group都可能含有superblock，**后续含有的superblock主要是作为第一个的备份**

#### dumpe2fs

查询ext系列文件系统的元数据

#### blkid

列出目前系统被格式化的装置。

#### 目录

分配至少一个**inode与至少一块block**。block记录整个目录下的**文件名和其对应的inode号码**

当目录下文件太多，一个block记录不下时，Linux会给与多一个block来继续记录。

#### 文件

分配一个inode与相对于该文件大小的block给该文件。

#### 数据不一致状态

各种原因导致系统中断，数据和元数据没有同时写入，最早的ext2，在系统重启时，会根据super block中记录的valid bit与filesystem state等状态判断是否强制进行数据一致性检查，**e2fsck**。这样性能很慢。

#### 日志式文件系统

在filesytem中专门规划一个区块，**专门记录写入或修订文件的步骤**。

* **预备**：系统要写入一个文件时，先在日志记录区记录某个文件要写入的信息
* **实际写入**：开始写入文件的权限和数据，开始更新metadata
* **结束**：完成数据和元数据的更新后，在日志记录块中完成该文件的记录。

#### 查询支持的文件系统

```shell
ls -l /lib/modules/${uname -r}/kernel/fs;
cat /proc/filesystems;
```

整个linux系统通过**Virtual FileSystem Switch**的核心功能去读取filesystem。

#### XFS文件系统

适合高磁盘容量与巨型文件效能较佳。日志式文件系统，

##### data section

类似block group,也分为多个**allocation group**,存储了整个文件系统的super block、剩余空间的管理机制、inode的追踪与分配。inode、block的分配都是用到时才**动态配置产生**。

xfs的block与inode有多种不同容量供设定。

##### log section

记录文件系统变化，知道变化完整的写入到数据区，可以指定**外部磁盘作为xfs文件系统的日志区块**。

##### realtime section

文件建立时，在这个区段找**一个到数个extent区块**，将文件放置，等到分配完毕后，在写入到data section的inode和block中。**这个extent区块的大小要在格式化时就指定，最小4K,最大1G**。

**xfs_info**

#### 文件系统操作

##### df

列出文件系统的整体磁盘使用量

##### du

评估文件系统的磁盘使用量

##### ln

**Hard link**只是在某个目录下新增一笔档名链接到某inode号码的关联记录。

**Hard link**不能跨文件系统，不能link目录

**Symbom Link**建立一个独立文件，这个文件记录内容为它**link的文件完整路径名**。

#### 磁盘分区、格式化、校验与挂载

##### lsblk

列出系统上所有磁盘列表

##### parted

列出磁盘分区表类型与分区信息

##### **gdisk**

新增分区槽

**cat /proc/partitions**

**partprobe**,在不重启情况下，将磁盘分区同步到核心

这里直接gdisk将vhdx给分区了，导致整个根目录都没了，这其实有些不友好，**/mnt/wsl/distro的分区竟然是loop**TODO:？？？这里要了解下，有点搞人

##### mkfs

将分区格式化为对应的文件系统

#### 文件系统挂载/卸载

* 单一文件系统不应该被重复挂载到不同挂载点
* 单一目录不应该重复挂载多个文件系统
* 要作为挂载点的目录，理论上应该都是空目录

##### mount

```shell
-a 根据/etc/fstab的数据将所有未挂载磁盘都挂载
-t 要挂载的文件系统类型，
-n 默认情况，系统会将实际挂载情况写入/etc/mtab,使用-n就不会（例如单一救援模式）
-o 接一些挂载时额外加的参数，比如账号、密码、读写权限等。
```

如果不指定t，会测试挂载，因为文件系统基本都有superblock,可以分析出来

* /etc/filesystems,系统指定的测试挂载文件系统类型的优先级
* /proc/filesystems,已经加载的文件系统类型

**/lib/module/$(uname -r)/kernel/fs/**  存放所有支持的文件系统驱动

推荐使用**uuid**来挂载对应的装置文件，唯一标识。

```shell
mount -o remount,rw,auto / #重新挂载，加入一些参数
mount --bind /var/data/var #将一个挂载到另一个目录
```

##### umount

卸载装置文件

#### 磁盘/文件系统参数修订

##### mknod

linux中通过文件的**major**与**minor**来区分装置文件，这两个数字是有规定的、有特殊意义的。基本上，2.6版本之后，硬件文件名已经可以被系统自动实时产生，根本不用手动建置。可以通过mknod修改这个（**TODO:场景**？？？）

##### xfs_admin

**修改xfs文件系统的uuid与labelname**

##### tune2fs

**修改ext4文件系统的uuid与labelname**

#### 设定开机挂载

系统挂载限制：

* /必须挂载，先于其他mount point
* 其他mout point必须为已建立目录
* 所有mount point在同一时间，只能挂载一次
* 所有partition在同一时间只能挂载一次

**/etc/fstab**，其内格式：

**UUID/LABEL/装置文件名  ==>  挂载点  ==>  文件系统  ==> 文件系统参数**  **==>**  **dump**   **==>**  **fsck**

文件系统可取：

| 参数            | 意义                                       |
| --------------- | ------------------------------------------ |
| **async**/sync  | 设定磁盘是否以异步方式运作。               |
| **auto**/noauto | mount -a时，此文件系统是否被主动测试挂载。 |
| **rw**/ro       | 可读还是可写                               |
| **exec**/noexec | 此文件系统内是否可以进行“**执行**”         |
| user/**nouser** | 是否允许用户使用mount指令挂载              |
| **suid**/nosuid | 是否允许suid的存在                         |
| defaults        | async,auto,rw,exec,nouser,suid的组合       |

#### 特殊装置loop

光盘映像文件或使用文件作为磁盘时，可以使用loop挂载，而不用刻录。

```shell
#挂载iso文件
mount -o loop /**/*.iso /data/tmp
#建立大文件，并将其转换为loop
dd if=/dev/zero of=/srv/loopdev bs=1M count=512
```

##### **loop**

伪设备，使用文件来模拟设备的一种技术，linux中会有8个loop设备，一般是/dev/loop0~loop7,

**losetup**:*set up and control loop devices*

#### swap

mkswap

swapon

除了单独分区，也可以将一个大文件作为swap使用

## 文件压缩、打包、备份

### 压缩指令

| 后缀名    | 意义                                                |
| --------- | --------------------------------------------------- |
| *.Z       | compress程序压缩的文件                              |
| *.zip     | zip压缩的文件                                       |
| *.gz      | gzip压缩的文件，GNU，**替代compress**，更好的压缩比 |
| *.bz2     | bzip2压缩的文件                                     |
| *.xz      | xz压缩的文件                                        |
| *.tar     | tar打包的文件，没有被压缩过                         |
| *.tar.gz  | 经tar打包，gzip压缩                                 |
| *.tar.bz2 | 经tar打包，bzip2压缩                                |
| *.tar.xz  | 经tar打包，xz压缩                                   |

#### gzip

可以解开compress,zip与gzip等压缩的文件

zcat  zless zmore zgrep可以读取压缩文件的内容

#### bzip2

bzip2是为了取代gzip，提供更优的压缩比，用法差不多

bzcat bzmore ...

#### xz

压缩比更高

### 打包指令

tar可以将多个目录或文件打包成一个大文件，同时可以借助gzip/bzip2/xz的支持，将文件同时进行压缩。

```shell
#压缩
tar -jcv -f filename.tar.bz2
#查询
tar -jtv -f filename.tar.bz2
#解压缩
tar -jxv -f filename.tar.bz2 -C
如果不加[-z|-j|-J]，则只打包，不压缩

#查看tar文件中数据内容
tar -jtv -f *.bz2
#将文件解压缩到指定目录
tar -jxv -f *.bz2 -C tmp
#仅将shadow文件解压缩
tar -jxv -f *.bz2 etc/shadow
#打包时排除某些文件
tar -jcv -f *.bz2 --exclude=/root/etc* /etc /root
#仅备份比某个时刻还要新的文件
tar -jcv -f *.bz2 --newer-mtime="2015/06/17" /etc/*
#利用管线命令和数据流
tar -cvf - /etc | tar -xvf -

#备份系统
tar -jcv -f /backups/backup-system-20150701.tar.bz2\
--exclude=/root/*.bz2 --exclude=/root/*.gz --execlude=/home/loop*\
/etc /home /var/spool/mail /var/spool/cron /root
```

备份解压缩后可能存在SELinux设置被更改的问题。

### 文件系统备份

#### xfsdump/xfsrestore

除了可以进行完整备份，还能进行累积备份

#### 光盘写入工具

* 将备份的数据变成iso，利用**mkisofs**
* 将iso刻录至光盘或DVD,利用**cdrecord**或**wodim**

#### dd

一个个扇区去读/写

#### cpio

可以备份任何东西，包括装置设备文件。

## vim

emacs，pico，nano， joe，vim等编辑器，之所以选择vim：

* 所有Unix like系统都会构建vi
* 很多软件会调用vi，例如crontab
* vim具备程序编辑的能力，编辑速度快

vi分为三种模式：

* 一般模式（默认）
* 编辑模式（一般模式下按下i,I,o,O,a,A,r,R）等字母中任意一个
* 指令列命令模式（一般模式下输入:/?）任何一个时

**按Esc即可回到一般模式**

### 一般模式

| 按键         | 作用                             |
| ------------ | -------------------------------- |
| hjkl或方向键 | 移动光标，可以用20j,代表向下20行 |
| ctrl+f       | page down                        |
| ctrl+b       | page up                          |
| n\<space\>   | 向右移动多少个字符               |
| 0或home      | **移到一行最前**                 |
| $或end       | **移到一行最后**                 |
| G            | **移到文件最后一行**             |
| nG           | 移到第n行                        |
| gg           | 相当于lG                         |
| n\<Enter\>   | **向下移动几行**                 |
| /word        | 向下查找                         |
| ?word        | 向上查找                         |
| n            | 重复前一个搜寻动作               |
| N            | 反向重复前一个搜索动作           |
| x,X          | 删除                             |
| dd           | **删除整行**                     |
| yy           | **复制整行**                     |
| nyy          | 复制n行                          |
| p,P          | **黏贴**                         |
| J            | 将下一行合并到此行               |
| u            | **撤销前一个动作**               |
| ctrl+r       | **重做前一个动作**               |
| .            | 重复做前一个动作                 |

### 编辑模式

| 按键 | 作用                        |
| ---- | --------------------------- |
| i    | 进入插入模式,从当前光标开始 |
| a    | 进入插入模式，...           |
| o    | 进入插入模式,...            |
| r    | 进入替换模式                |

### 指令列模式

| 按键              | 作用                               |
| ----------------- | ---------------------------------- |
| :w                | 编辑数据写入硬盘                   |
| :q                | 离开                               |
| :w filename       | 将编辑数据存储为另一个文件         |
| :r filename       | 在编辑数据中，插入另一个文件的内容 |
| :n1,n2 w filename | 将n1~n2的内容存储为单个文件        |
| :! command        | 暂时离开vi到指令列模式执行command  |
| set nu            | 显示行号                           |

## shell

**/etc/shells**,记录可用shell，**/etc/passwd**记录具体用户使用的是哪一个shell

bash的特点：

* 记录使用的指令。~/.bash_history，记录前一次登入以前所执行过的指令。
* 命令与文件补全功能。
* 命令别名设定，alias。
* 工作控制、前景背景控制。
* 程序化脚本。
* 通配符。

### type

查询bash内建指令。

### 变量

**echo $PATH**   读取系统变量PATH

直接使用=号即可赋值

#### 变量设定规则

* 变量与变量内容用=连接。

* 等号两边不能有空格。

* 变量名称只能是**英文字母与数字**，**开头字符不能是数字**。

* 变量内容若有空格符，可使用”或‘将其结合起来。**双引号内特殊字符保留原本特性，单字符串则不保留**。

  ```shell
  var="lang is $LANG" => lang is zh.CN.UTF-8
  var='lang is $LANG' => lang is $LANG
  ```

* 可使用\来跳脱特殊字符，比如换行、空格等
* version=**$(uname -r)**或version=**\`uname -r\`**,可以指令中执行另一个指令
* 可使用${PATH}追加，PATH=**${PATH}**:/home/bin
* **export**使变量变成环境变量。
* **unset**取消变量

#### 环境变量

**env**,查看所有环境变量

**set**,查看所有变量，包含环境变量和自定义变量

其中，**PS1**可以设定提示字符（**man bash**）。**$**表示本shell的id，**?**表示上个指令的回传值。

**export**,自定义变量转换成环境变量

子进程会继承父进程的环境变量，不会继承父进程的自定义变量

#### 语系变量

locale  /usr/lib/locale  /etc/locale.conf

#### 定义变量

**read**   等待用户输入

declare/typeset，设定变量的类型，默认情况下：

* 默认为字符串
* 数值运算仅能达到整数形态

```shell
declare -x sum #声明为环境变量
declare +x sum #取消其环境变量
declare -p sum #单独列出变量类型
```

被声明为readonly的变量是不可逆的

#### 资源限制

ulimit，限制用户的某些系统资源，包括可以开启的文件数量，可以使用的CPU时间。

#### 变量内容删除、取代与替换

| 设定方式                                                  | 含义                               |
| --------------------------------------------------------- | ---------------------------------- |
| ${变量#关键词}<br />${变量##关键词}                       | 从头删除，分别为删除最短、最长匹配 |
| ${变量%关键词}<br />${变量%%关键词}                       | 从尾删除，分别为删除最短、最长匹配 |
| ${变量/旧字符串/新字符串}<br />${变量//旧字符串/新字符串} | 替换，分别为替换第一个、替换全部   |

| 设定方式             | str不存在          | str为空串          | str非空串     |
| -------------------- | ------------------ | ------------------ | ------------- |
| var=${str**-**expr}  | var=expr           | var=               | var=$str      |
| var=${str**:-**expr} | var=expr           | var=expr           | var=$str      |
| var=${str**+**expr}  | var=               | var=expr           | var=expr      |
| var=${str**:+**expr} | var=               | var=               | var=expr      |
| var=${str**=**expr}  | str=expr  var=expr | str=$str  var=     | str=$str var= |
| var=${str**:=**expr} | str=expr var=expr  | str=$str  var=expr | str=var=$str  |
| var=${str**?**expr}  | expr输出到stderr   | var=               | var=$str      |
| var=${str**:?**expr} | expr输出到stderr   | expr输出到stderr   | var=$str      |

#### 设定别名



## 账号管理

id 查询是否有某一个账户

### /etc/passwd

```
用户名称:密码(弃用):UID:GID:用户信息说明:家目录:所用shell
```

UID使用惯例

| id范围     | 说明                                                         |
| ---------- | ------------------------------------------------------------ |
| 0          | 系统管理员                                                   |
| 1~999      | 保留给系统使用。1~200为由系统自行建立的，201~999则为用户需求建立 |
| 1000~60000 | 一般使用者使用                                               |

### /etc/shadow

```
账号名称:密码:最近更改密码日期:密码不可被更改的天数:密码需要重新变更的天数:密码需要变更期限前警告天数:密码过期后账号宽限时间:账号失效日期:保留
authconfig --test | grep hashing #查询密码加密算法
```

### /etc/group

```
组名:群组密码:GID:群组支持的账号
```

初始群组：/etc/passwd中GID，表示用户一登入系统，旧拥有此群组的相关权限

有效群组：























