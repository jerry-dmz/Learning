extern int fff;
int ddd;
int printf(const char* format,...);
int global_init_var=84;
int global_uninit_var;
void func1(int i){
	printf("%d\n",i);
}
int main(void){
	static int static_init_var=85;
	static int static_uninit_var;
	//这里会被优化到bbs段，0可以看作未初始化
	static int c=0;
	int a=1;
	int b;
	func1(static_init_var + static_uninit_var+a+b);
	return a;
}
