freedos中使用com启动流程：
1. bximage创建pm.img
2. 将其设置为b盘，用a盘启动然后格式化b盘
3. 编译pmtest.com(0x07c00要替换位0x0100),在linux中挂在pm.img,使用文件命令将pm.com复制到pm.img

直接使用创建可启动盘调试

不借助freedos启动的话，需要在扇区最后写上0xaa55

现freedos已经有A、B盘，且B盘已经被格式化，故操作为：
将com文件移动到freedos目录，然后：
1. mount -o loop pm.img /mnt/floppy  ;pm.img已经是被格式为fat32格式的虚拟磁盘
2. cp pmtest.com /mnt/floppy/
3. umount /mnt/floppy