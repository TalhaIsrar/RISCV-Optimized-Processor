# Convert .elf file to .dump for easy debugging
core.dump: core.elf
	riscv32-unknown-elf-objdump -D ../core.elf > ../core.dump

# Use GCC to generate .elf file
core.elf: link.ld start.s test.c
	riscv32-unknown-elf-gcc -nostdlib -nostartfiles -O -march=rv32im -mabi=ilp32 -T link.ld start.s test.c -o ../core.elf
