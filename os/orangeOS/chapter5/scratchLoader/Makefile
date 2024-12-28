##################################################
# Makefile
##################################################

BOOT:=boot.asm
LDR:=loader.asm
KERNEL:=kernel.asm
STRING:=string.asm
KLIBA:=kliba.asm
START:=start.c
BOOT_BIN:=$(subst .asm,.bin,$(BOOT))
LDR_BIN:=$(subst .asm,.bin,$(LDR))
KERNEL_BIN:=$(subst .asm,.bin,$(KERNEL))
STRING_O:=$(subst .asm,.o,$(STRING))
KLIBA_O:=$(subst .asm,.o,$(KLIBA))
START_O:=$(subst .c,.o,$(START))

IMG:=a.img
FLOPPY:=/mnt/floppy/

.PHONY : everything

everything : $(BOOT_BIN) $(LDR_BIN) isLD
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(IMG) $(FLOPPY)
	sudo cp $(LDR_BIN) $(FLOPPY) -v
	sudo cp $(KERNEL_BIN) $(FLOPPY) -v
	sudo umount $(FLOPPY)

clean :
	rm -f $(BOOT_BIN) $(LDR_BIN) $(KERNEL_BIN) $(START_O) $(STRING_O) $(KLIAB_O) *.o

$(START_O):$(START)
	gcc -c -m32 -fno-builtin -o $@ $<

$(STRING_O):$(STRING)
	nasm -f elf -o $@ $<

$(KLIBA_O):$(KLIBA)
	nasm -f elf -o $@ $<

# nasm boot.asm -o boot.bin
$(BOOT_BIN) : $(BOOT)
	nasm $< -o $@

# nasm loader.asm -o loader.bin
$(LDR_BIN) : $(LDR)
	nasm $< -o $@

# nasm -f elf -o kernel.o kernel.asm
# ld -m  elf_i386 -s -Ttext 0x30400 -o kernel.bin kernel.o string.o start.o kliba.o
# $(KERNEL_BIN) : $(KERNEL)
# 	nasm -f elf -o $(subst .asm,.o,$(KERNEL)) $<
	
# 这里不能把kernel.o挪到最后,不然_start就不在0x304000这个位置了。

isLD : $(STRING_O) $(START_O) $(KLIBA_O) 
	nasm -f elf -o $(subst .asm,.o,$(KERNEL)) $(KERNEL)
	ld -m elf_i386 -s -Ttext 0x30400 -o $(KERNEL_BIN) $(subst .asm,.o,$(KERNEL)) $(STRING_O) $(START_O) $(KLIBA_O) 