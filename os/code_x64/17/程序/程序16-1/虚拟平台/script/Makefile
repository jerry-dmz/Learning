

all:
	gcc -o kallsyms kallsyms.c
	nm -n system | ./kallsyms > kallsyms.S
	gcc -c kallsyms.S

clean:
	rm -rf kallsyms kallsyms.o kallsyms.S
