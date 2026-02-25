MEMORY {
  text (rwx) : ORIGIN = 0x80000000 , LENGTH = 8M
  RAM (rw) : ORIGIN = 0x80080000 , LENGTH = 504M
  
}

SECTIONS {
  .text : {
    *(.text.start)
    *(.text.drivers)
    *(.text.print)
    *(.text.memory)
    *(.text.machine)
    *(.text.bios)
    *(.text .text.*)
  } > text
  .data : {
    *(.data)
    *(.data*)
  } > RAM
  .bss (NOLOAD) : {
    . = ALIGN(16);
    _bss_start = .;
    *(.bss)
    *(.bss.*)
    . = ALIGN(16);
    _bss_end = .;
  } > RAM
}
