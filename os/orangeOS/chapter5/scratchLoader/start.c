#include "types.h"
#include "const.h"
#include "protect.h"

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
     */
    // disp_str("\n\n\n\n\n\n\n-----\"cstart\" begins------\n");
    disp_str("------cstart begins");
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
    disp_str("cstart ends");
}