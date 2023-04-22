1. 编译汇编程序
    nasm boot.asm -o boot.bin
2. bximage创建一个1_44硬盘(boot.img)
3. 使用dd将编译的二进制码赋值到硬盘第一个区块
    dd if=./boot.bin of=./boot.img bs=512  count=1 conv=notrunc
4. 以vfat分区格式挂在硬盘，并将文件拷贝
   其中讲boot.bin写入到引导扇区就和磁盘格式化fat12文件系统的操作类似。
    mount ./boot.img /media/ -t vfat -o loop ; cp loader.bin /media/ ; sync

TODO:

conv=notrunc编译项是什么意思？