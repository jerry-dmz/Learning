extern int shared;
void swap(int* a,int* b);

int aaa;

int main(){
	int a=100;
	swap(&a,&shared);
}
