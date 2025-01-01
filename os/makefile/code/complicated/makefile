.PHONY:all clean
override dir_objs=objs
override dir_exes=exes
override dir_deps=deps
override dirs=$(dir_objs) $(dir_exes) ${dir_deps}
cc=gcc
exe=complicated
exe:=$(addprefix $(dir_exes)/,$(exe))
srcs=$(wildcard *.c)
objs=$(srcs:.c=.o)
objs:=$(addprefix $(dir_objs)/,$(objs))
deps=$(srcs:.c=.dep)
deps:=$(addprefix $(dir_deps)/,$(deps))


all:${dirs} $(deps) ${exe}

include $(deps)

$(dirs):
	mkdir $@

$(exe):$(objs)
	$(cc) -o $@ $^

$(dir_objs)/%.o:%.c foo.h
	${cc} -o $@ -c $<

$(dir_deps)/%.dep:%.c
	@echo "Making $@..."
	set -e;\
	rm -rf $@.tmp;\
	$(cc) -E -MM $^>$@.tmp;\
	sed 's,\(.*\)\.o[ :]*,objs/\1.o: ,g'<$@.tmp>$@;\
	rm -rf $@.tmp

clean:
	rm -rf ${dirs}
