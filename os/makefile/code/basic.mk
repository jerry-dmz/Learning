bar=bar
override bar1=bar1
all:test
	@echo "hello world"
	@echo ${bar}
	@echo ${bar1}
test aliatest:
	@echo "hello test"
