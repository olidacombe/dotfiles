.DEFAULT_GOAL := build-and-test
.PHONY: build-and-test

BUILD_DIR := ./archiso

clean:
	@sudo rm -rf $(BUILD_DIR)
	# @rm -f test.qcow2

build-and-test:
	@make clean
	@./build-and-test.sh $(BUILD_DIR) true

test:
	@./build-and-test.sh $(BUILD_DIR)

burn:
	@export SOURCE_IMG="$$( \
		ls -t ./archiso/out/archlinux-*.iso | fzf --prompt="Select source image: " --height 10 --reverse --border --preview-window=right:60%:wrap \
	)"; \
	echo "Selected source image: $$SOURCE_IMG"; \
	export DISK="/dev/$$( \
		lsblk -l | grep '^sd[a-z]\s' \
		| fzf --prompt="Select target disk: " --height 10 --reverse --border --preview-window=right:60%:wrap \
		| awk '{print $$1}' \
	)"; \
	if [ -b "$$DISK" ]; then \
		echo "Selected disk: $$DISK"; \
	else \
		echo "Error: No disk selected or invalid selection."; \
		exit 1; \
	fi; \
	sudo dd if="$$SOURCE_IMG" of="$$DISK" bs=4M status=progress conv=fsync;


