test1 test2:
	@echo $@

test3:test1 test2
	@echo $^
