.macro db char
    addi sp,sp,-16
    sd a0,(sp)
    sd t0,8(sp)
    li a0,\char
    call uart_putc
    ld t0,8(sp)
    ld a0,(sp)
    addi sp,sp, 16
.endm
