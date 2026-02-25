TCPREFIX = riscv64-unknown-elf-
ISA = rv64im_zicsr_zbb
ABI = lp64

bin: main.s linkers/main.ld
	$(TCPREFIX)as -march=$(ISA) -mabi=$(ABI) -almsg=main.lst --warn -o main.o main.s
	$(TCPREFIX)ld -T linkers/main.ld -m elf64lriscv main.o -o bin

clean:
	rm bin main.o
