
/**
 * 测试自定义链接脚本。
 *
 * 通过命令行传递参数：
 * gcc -c -fno-builtin TinyHelloWorld.c -m32
 *
 * ld -static -m elf_i386  -e nomain -o TinyHelloWorld TinyHelloWorld.o
 *
 * -fno-builtin禁用内置函数。因为编译器提供很多内置函数，会把一些常用的c库函数替换成编译器的内置函数，以达到
 *  优化的目的。比如gcc会将只有字符串参数的printf函数替换为puts，以节省格式解析的时间。
 *
 * 通过链接脚本:
 */
char* str="Hello world!\n";

void print(){
	asm("movl $13,%%edx \n\t"
	    "movl %0,%%ecx \n\t"
	    "movl $0,%%ebx \n\t"
	    "movl $4,%%eax \n\t"
	    "int $0x80	\n\t"
	    ::"r"(str):"edx","ecx","ebx");
}

void exit(){
	asm("movl $42,%ebx \n\t"
	    "movl $1,%eax \n\t"
	    "int $0x80 \n\t");
}

void nomain(){
	print();
	exit();
}
