1. nasm boot.asm -o boot.bin
2. bximage创建一个1_44硬盘
3. dd if=./boot.bin of=./boot.img bs=512  count=1 conv=notrunc
4. mount ./boot.img /media/ -t vfat -o loop ; cp loader.bin /media/ ; sync

TODO:

conv=notrunc编译项是什么意思？