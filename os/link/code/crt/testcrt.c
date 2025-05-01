void foo(){
	printf("bye!\n");
}

int main(){

	atexit(&foo);
	printf("endof main\n");
}
