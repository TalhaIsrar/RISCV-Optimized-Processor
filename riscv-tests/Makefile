# Toolchain
RISCV_GCC    ?= riscv32-unknown-elf-gcc
OBJDUMP      ?= riscv32-unknown-elf-objdump

# Architecture
ARCH  = rv32im   # rv32im for m unit
ABI   = ilp32

# Test directories (ADD MORE HERE)
TEST_DIRS := rv32ui rv32um # M unit

# Includes & flags
INCLUDES += -I./headers
ASFLAGS  += $(INCLUDES)
CFLAGS   := -march=$(ARCH) -mabi=$(ABI) -ffreestanding -nostdlib
LDFLAGS  := -Wl,-Bstatic,-T,link.ld

# Collect test sources
TEST_SOURCES := $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)/*.S))
TEST_OBJECTS := $(TEST_SOURCES:.S=.o)

# Default target
all: core.elf test.dump

# Link
core.elf: start.o $(TEST_OBJECTS) link.ld
	$(RISCV_GCC) $(CFLAGS) -Os -o ../core.elf \
		start.o $(TEST_OBJECTS) $(LDFLAGS)

# Start file
start.o: start.S
	$(RISCV_GCC) -c -O0 -march=$(ARCH) -mabi=$(ABI) start.S -o start.o

# Compile all tests
%.o: %.S
	$(RISCV_GCC) $(ASFLAGS) -c -march=$(ARCH) -mabi=$(ABI) \
		-DTEST_FUNC_NAME=$(notdir $*) \
		-DTEST_FUNC_TXT='"$(notdir $*)"' \
		-DTEST_FUNC_RET=$(notdir $*)_ret \
		$< -o $@

# Dump
test.dump: core.elf
	$(OBJDUMP) -D ../core.elf > ../core.dump
	$(MAKE) clean


# Clean
clean:
	rm -f start.o
	rm -f $(TEST_OBJECTS)
