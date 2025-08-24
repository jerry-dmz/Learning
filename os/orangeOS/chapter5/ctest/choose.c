/**
 * 外部函数，位于test2.asm中
 */
void myprint(char *msg, int len);

int choose(int a, int b)
{
    if (a >= b)
    {
        myprint("the one\n", 8);
    }
    else
    {
        myprint("the two\n", 8);
    }
    return 0;
}