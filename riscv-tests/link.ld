ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 64K
  DMEM (rw) : ORIGIN = 0x10000000, LENGTH = 16K
}

SECTIONS
{
  . = 0x0000000;
    .text : {
        *(.text.start)
        *(.text .text.*)
    }> IMEM

  .data : {
    *(.data*)
    *(.rodata*)
  } > DMEM

  .bss : {
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
} > DMEM

  _stack_top = .;  
}