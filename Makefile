TCPREFIX = riscv64-unknown-elf-
ISA = rv64im_zicsr_zbb
ABI = lp64

VPATH = src:res
BUILD_DIR = build

.PHONY: build all clean run

run:
	exec ./.build/run

all: clean build run

build: $(BUILD_DIR)/bin

$(BUILD_DIR)/bin: main.s main.ld
	mkdir -p $(BUILD_DIR)
	$(TCPREFIX)as -march=$(ISA) -mabi=$(ABI) -Isrc -Ires -almsg=$(BUILD_DIR)/main.lst --warn -o $(BUILD_DIR)/main.o $<
	$(TCPREFIX)ld -T $(filter %.ld,$^) -m elf64lriscv $(BUILD_DIR)/main.o -o $@

clean:
	rm -rf $(BUILD_DIR)
