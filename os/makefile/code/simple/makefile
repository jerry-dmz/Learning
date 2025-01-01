# gcc会自动拍好序，如果使用ld就要自己排序
# -c表示只编译，不链接

.PHONY:all test debug
override objs=$(patsubst %.c,%.o,$(wildcard *.c))
CC=gcc

all: ${objs}
	$(CC) -o simple $^
%.o:%.c
	${CC} -o $@ -c $^
clean:
	@sudo rm simple *.o
test:
	@echo $(wildcard *.c)
