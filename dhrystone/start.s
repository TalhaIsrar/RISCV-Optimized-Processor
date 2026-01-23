.section .text
.global _start

_start:
    la sp, _stack_top

    li t0, 0xCAFEBEEF
    call main

HALT:
    li t0,0xDEADC0DE
    j HALT
    nop
    nop
