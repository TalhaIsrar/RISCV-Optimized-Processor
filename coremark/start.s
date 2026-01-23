.section .text
.align 2
.global _start
.extern main

_start:
    # Set stack pointer
    la sp, _stack_top

    # Zero out .bss section
    la a0, __bss_start       # start of .sbss
    la a1, __bss_end    # end of .bss
_init_bss:
    bgeu a0, a1, _init_reg   # If _sbss >= _ebss, stop
    sw zero, 0(a0)           # Clear the word at _sbss = 0
    addi a0, a0, 4           # Move to the next word
    j _init_bss

_init_reg:
	/* zero-initialize all registers except x2 because stack pointer */
	addi x1, zero, 0
    addi x3, zero, 0
    addi x4, zero, 0
    addi x5, zero, 0
    addi x6, zero, 0
    addi x7, zero, 0
    addi x8, zero, 0
    addi x9, zero, 0
    addi x10, zero, 0
    addi x11, zero, 0
    addi x12, zero, 0
    addi x13, zero, 0
    addi x14, zero, 0
    addi x15, zero, 0
    addi x16, zero, 0
    addi x17, zero, 0
    addi x18, zero, 0
    addi x19, zero, 0
    addi x20, zero, 0
    addi x21, zero, 0
    addi x22, zero, 0
    addi x23, zero, 0
    addi x24, zero, 0
    addi x25, zero, 0
    addi x26, zero, 0
    addi x27, zero, 0
    addi x28, zero, 0
    addi x29, zero, 0
    addi x30, zero, 0
	addi x31, zero, 0

    #li t0,0xCAFEBEEF
    call main
    
HALT:
    li t0,0xDEADC0DE
    nop
    nop
    j HALT