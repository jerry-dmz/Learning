# 《驾驭makefile》

## 概念

```makefile
ECHO=@echo
all:test
	$(ECHO) "hello world"
test aliatest:
	${ECHO} "hello world"
```

#### 目标（target）

放到“:”前，名字可以由字母和下划线组成，比如：“all”

一个makefile中可以定义多目标，比如：“all”、“test”

调用make命令时需要给出目标，否则就是**第一个定义的目标（默认目标）**

如果目录有与目标同名的文件，此时文件优先目标，此时要使用假目标

#### 假目标（phony target）

使用关键字**.PHONY**定义，只能写大写目标

#### 命令

@echo "hello world"

命令前加@，就可以让makefile执行命令不输出命令本身（只输出命令结果）

每一行命令前都必须有至少一个Tab

对于规则的每一个命令，make都是在一个新的shell上运行的。

#### 先决条件（prerequisites）

all目标依赖test，test被称为all目标的先决条件

make会按从左到右的顺序执行每一个先决条件

#### 规则（rule）

```makefile
targets:prerequisites
	command
```

makefile中基本单元

一条规则中可以定义多个目标, 比如第二条规则中，test、aliatest

make在检查一个规则时，采用的方法：如果先决条件中相关文件的文件时间戳大于目标的时间戳，则有变化

#### 变量

* 内置变量，直接引用，如$@、MAKEFILE
* makefile中自定义变量，通过${}或$()使用
* make命令行定义的变量，可以覆盖makefile中自定义变量
* 来源于shell环境

##### 内置变量

* **$@**表示一个规则中的目标，如果有多个目标，取决于别的地方用那个目标引用
* **$^**表示规则中所有**先决条件**
* **$<**表示规则中第一个先决条件

##### 递归扩展变量

用=定义，递归展开式赋值，变量的值在使用时才会展开

```makefile
bar=value
foo=$(bar) -fooValue
test=$(foo) -o $(bar)
# 最后test为：value -fooValue -o value
# 定义的变量可以递归引用
```

##### 简单扩展变量

用:=定义，只对其一次扫描和替换，立即赋值，变量的值在定义的时候就被确定了下来，后续依赖变量变化都不会影响。举例：

```makefile
x=before
y=${x}
x=after
xx=before
yy=$(xx)
xx=after
all:
	@echo ${y}
	@echo ${yy}
# make输出
# after
# before
```

##### 定义方式

* = 递归扩展变量
* := 简单扩展变量
* ?=,当变量以前没有定义时，就定义它并将右边的值赋给它，如果已经定义了则不再改变其值
* +=，类似其他编程语言

##### override变量修饰词

被此关键词修饰的变量不会被命令行中变量覆盖

#### 模式

目标、先决条件文件名都可以用通配符匹配，%，但是不能只有一方用通配符

```makefile
# 编译所有c文件
*.o:*.c
	gcc -o $@ -c $<
```

#### 函数

参考手册

#### include

# 《跟我一起学makefile》

## 概述





































