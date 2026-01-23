# Minimal Makefile for RV32I CoreMark simulation
PORT_DIR = barebones

# CoreMark run configuration
ITERATIONS     = 1000
CLOCKS_PER_SEC = 75000000
FLAGS_STR      = ""

# Compiler flags
CFLAGS = -O2 -Wall -Wextra -march=rv32i -mabi=ilp32 -fno-builtin
XCFLAGS = \
	-g \
	-DITERATIONS=$(ITERATIONS) \
	-DCLOCKS_PER_SEC=$(CLOCKS_PER_SEC) \
	-DPERFORMANCE_RUN=1 \
	-DDEFAULT_EXEC_MASK=ID_LIST \
	-I ./ \
	-I $(PORT_DIR) \
	-DFLAGS_STR=\"$(FLAGS_STR)\"

# Linker flags
LDFLAGS = -nostartfiles -static

# Source files
CORE_SRC = \
	core_list_join.c \
	core_main.c \
	core_matrix.c \
	core_state.c \
	core_util.c

PORT_SRC = \
	$(PORT_DIR)/core_portme.c \
	$(PORT_DIR)/ee_printf.c

STARTUP = start.s
SRC = $(STARTUP) $(CORE_SRC) $(PORT_SRC)

# Toolchain
RISCV-GCC = riscv32-unknown-elf-gcc
RISCV-OBJDUMP = riscv32-unknown-elf-objdump

# Build ELF
core.elf: $(SRC) link.ld
	$(RISCV-GCC) $(CFLAGS) $(XCFLAGS) $(SRC) $(LDFLAGS) -T link.ld -o ../core.elf
	$(RISCV-OBJDUMP) -D ../core.elf > ../core.dump

clean:
	rm -f *.o $(PORT_DIR)/*.o core.elf core.dump
