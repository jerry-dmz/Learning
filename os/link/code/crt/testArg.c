#include<stdio.h>

int sum(unsigned num,...){
	int* p=&num+1;
	int ret=0;
	while(num--){
		printf("%d\n",*p);
		p++;
	}
	return ret;
}

int main(){
	int ret=sum(3,16,38,53);
	printf("\nsum %d\n",ret);
	return 0;
}
