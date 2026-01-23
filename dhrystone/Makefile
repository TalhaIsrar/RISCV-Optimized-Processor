DHRY-CFLAGS := -O1 -DNOENUM -Wno-implicit
DHRY-CFLAGS += -fno-builtin-printf -fno-common -falign-functions=4 -nostartfiles 

GCC-FLAGS = -march=rv32i -mabi=ilp32

DHRY-CFLAGS += -DDHRY_ITERS=2000 # Set iterations
DHRY-CFLAGS += -DCPU_FREQ_HZ=75000000 # SET CLOCK FREQUENCY

SRC = start.s dhry_1.c dhry_2.c strcmp.S malloc.c div.c
HDR = dhry.h
RISCV-GCC = riscv32-unknown-elf-gcc

override CFLAGS += $(DHRY-CFLAGS)
core.elf: $(SRC) $(HDR) link.ld
	$(RISCV-GCC) $(GCC-FLAGS) $(CFLAGS) $(SRC) -T link.ld -o ../core.elf
	 riscv32-unknown-elf-objdump -D ../core.elf > ../core.dump
clean:
	rm -f *.i *.o 

