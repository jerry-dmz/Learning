freedos中使用com启动流程：
1. bximage创建pm.img
2. 将其设置位b盘，用a盘启动然后格式化b盘
3. 编译pmtest.com(0x07c00要替换位0x0100),在linux中挂在pm.img,使用文件命令将pm.com复制到pm.img

直接使用创建可启动盘调试