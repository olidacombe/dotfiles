.DEFAULT_GOAL := build-and-test
.PHONY: build-and-test test burn e2e e2e-build e2e-install e2e-pre e2e-bootstrap e2e-post e2e-shell e2e-stop

BUILD_DIR := ./archiso

clean: #nvim_map(c)
	@sudo rm -rf $(BUILD_DIR)
	# @rm -f test.qcow2

build-and-test:
	@make clean
	@./build-and-test.sh $(BUILD_DIR) true

test:
	@./build-and-test.sh $(BUILD_DIR)

# Unattended end-to-end test (see e2e/run.sh). Uses the latest ISO if it has the
# e2e hook, otherwise builds one (sudo for mkarchiso).
e2e:
	@./e2e/run.sh all

e2e-build:
	@./e2e/run.sh build

e2e-install:
	@./e2e/run.sh install

e2e-pre:
	@./e2e/run.sh pre

e2e-bootstrap:
	@./e2e/run.sh bootstrap

e2e-post:
	@./e2e/run.sh post

# make e2e-shell [SNAPSHOT=installed|bootstrapped]
e2e-shell:
	@./e2e/run.sh shell $(SNAPSHOT)

burn:
	export SOURCE_IMG="$$( \
		ls -t ./archiso/out/archlinux-*.iso | \
		fzf --prompt="Select source image: " --height 10 --reverse --border \
	)"; \
	[ -f "$$SOURCE_IMG" ] || { echo "Invalid image"; exit 1; }; \
	echo "Selected source image: $$SOURCE_IMG"; \
	export DISK_NAME="$$(lsblk -dn -o NAME,TYPE | awk '$$2=="disk"{print $$1}' | \
		fzf --prompt="Select target disk: " --height 10 --reverse --border)"; \
	export DISK="/dev/$$DISK_NAME"; \
	[ -b "$$DISK" ] || { echo "Invalid disk: $$DISK"; exit 1; }; \
	export SIZE=$$(stat -c%s "$$SOURCE_IMG"); \
	echo "Image size: $$SIZE bytes"; \
	echo "Selected disk: $$DISK"; \
	if grep -q "^$${DISK_NAME}" <(lsblk -nr -o NAME,MOUNTPOINT | awk 'NF>1 { print; }'); then \
		echo "ERROR: $${DISK_NAME} has mounted partitions — aborting"; \
		exit 1; \
	fi; \
	pv -s "$$SIZE" "$$SOURCE_IMG" | sudo dd of="$$DISK" bs=4M iflag=fullblock oflag=direct conv=fsync; \
	sync ; \
	echo "Burn complete."

e2e-stop:
	@./e2e/run.sh stop
