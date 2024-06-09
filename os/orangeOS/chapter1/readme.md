1.nasm编译boot.asm为boot.bin。nasm boot.asm -o boot.bin
2.使用bximage创建boot.img。bximage boot.img
3.使用dd工具将boot.bin写到boot.img。dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
4.bochsdbg以调试模式启动