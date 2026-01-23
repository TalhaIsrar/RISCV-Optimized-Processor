OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf32-littleriscv)

ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 64K
  DMEM (rw) : ORIGIN = 0x10000000, LENGTH = 128K
}

SECTIONS
{
  /* Code in IMEM */
  .text : {
    *(.text.start)
    *(.text .text.*)
  } > IMEM

  /* Data in DMEM */
  . = ORIGIN(DMEM);

  .data  : {
      __data_start = .;
      *(.data*)
      *(.rodata*)
      __data_end = .;
  } > DMEM

  .sdata : {
      __sdata_start = .;
      *(.sdata*)
      __sdata_end = .;
  } > DMEM

  .sbss : {
      __sbss_start = .;
      *(.sbss*)
      __sbss_end = .;
  } > DMEM

  .bss   : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > DMEM
  .stack (NOLOAD) : {
      . = . + 16K;
  } > DMEM

  /* Define heap and stack boundaries */
  _stack_top = .;  
}
