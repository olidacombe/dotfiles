.DEFAULT_GOAL := build-and-test
.PHONY: build-and-test

BUILD_DIR := ./archiso

clean:
	@sudo rm -rf $(BUILD_DIR)
	# @rm test.qcow2

build-and-test:
	@make clean
	@./build-and-test.sh $(BUILD_DIR) true

test:
	@./build-and-test.sh $(BUILD_DIR)
