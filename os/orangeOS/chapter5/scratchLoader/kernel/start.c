#include "./include/types.h"
#include "./include/const.h"
#include "./include/protect.h"

public
void *memcpy(void *pDst, void *pSrc, int iSize);

public
void disp_str(char *pszinfo);

public
u8 gdt_ptr[6]; /**1~15:Limit 16~47:Base */

public
DESCRIPTOR gdt[GDT_SIZE];

public
void cstart()
{

    asm("xchg %bx,%bx");
    /**
     * 这里用到换行会报错，还没搞懂原因TODO:
     *
     *
     * 解答：disp_str函数中有\n时会用到bl寄存器，没有对其入栈处理，导致修改了ebx，
     *
     * 而disp_str被翻译成了：
     *
     * gcc高版本对ebx使用可能不同。在gcc11.4.0中，ebx被作为字符串常量池的索引
     * 比如 disp_str("ddss"）被翻译成:
     * sub  esp 0x0c
     * lea  eax, [ebx-8192]
     * push eax
     * call .112
     * add  esp 0x10
     *
     * 这就导致后续的调用全都乱了，所以出现了非法的描述符
     */
    disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n------cstart begins------\n\n");
    /**
     * 将gdt复制到新的位置
     */
    memcpy(&gdt,                              /* New GDT */
           (void *)(*((u32 *)(&gdt_ptr[2]))), /* Base  of Old GDT */
           *((u16 *)(&gdt_ptr[0])) + 1        /* Limit of Old GDT */
    );
    /**
     * 将新gdt的信息回写到gdt_ptr
     */
    u16 *p_gdt_limit = (u16 *)(&gdt_ptr[0]);
    u32 *p_gdt_base = (u32 *)(&gdt_ptr[2]);
    *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
    *p_gdt_base = (u32)&gdt;
    disp_str("-------cstart ends-----");
}