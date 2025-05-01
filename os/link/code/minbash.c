#include<stdio.h>
#include<sys/types.h>
#include<unistd.h>
#include<stdbool.h>
int main(){

	char buf[1024]={0};
	pid_t pid;
	bool flag=true;
	while(flag){

		printf("minibash$");
		scanf("%s",buf);
		pid=fork();
		if(pid==0){
			if(execlp(buf,0)<0){
				flag=false;	
			}
		}else if(pid>0){
			int status;
			waitpid(pid,&status,0);
		}else{
			printf("fork error %d\n",pid);
		}
	}
	return 0;
}
