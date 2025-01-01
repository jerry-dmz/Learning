
BOOT:=boot/boot.asm
LOADER:=boot/loader.asm
KERNEL:=kernel/kernel.asm

KERNEL_LIB=$(wildcard ./lib/*.asm)

IMG:=a.img
FLOPPY:=/mnt/floppy/
IMAGE_DEPEND:=$(patsubst %.asm,%.bin,$(BOOT) $(LOADER) $(KERNEL))

ASM:=nasm
CC:=gcc
LD:=ld
# -I 指定依赖的头文件
ASM_FLAGS:=-I boot/include/
CC_FLAGS:=-c -m32 -fno-builtin -I.
LD_FLAGS:=-m elf_i386 -s -Ttext 0x30400

.PHONY : default image clean

default : image

debug:
	@echo $(KERNEL_LIB)

image : $(IMAGE_DEPEND)
	dd if=$(BOOT:.asm=.bin) of=$(IMG) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(IMG) $(FLOPPY)
	sudo cp $(LOADER:.asm=.bin) $(FLOPPY) -v
	sudo cp $(KERNEL:.asm=.bin) $(FLOPPY) -v
	sudo umount $(FLOPPY)

$(BOOT:.asm=.bin): $(BOOT)
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(LOADER:.asm=.bin): $(LOADER)
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(KERNEL:.asm=.bin):kernel/start.o $(KERNEL_LIB:.asm=.o)
	set -e;
	$(ASM) -f elf -o $(KERNEL:.asm=.o) $(KERNEL);
	$(LD) $(LD_FLAGS) -o $@ $(KERNEL:.asm=.o) $^

lib/%.o:lib/%.asm
	$(ASM) -f elf -o $@ $<

kernel/start.o:kernel/start.c
	$(CC) $(CC_FLAGS) -o $@ $<

clean :
	find ./ -type f \( -name "*.bin" -o -name "*.o" \) | xargs rm -rf