.equ PLIC_BASE,      0x0c000000
.equ UART_ID,        10

uart_init:
.cfi_startproc

#    li t0, PLIC_BASE
#    li t1, 1
#    sw t1, (UART_ID * 4)(t0)
#    li t1, (1 << UART_ID)
#    li t2, 0x2000
#    add t2, t2, t0
#    lw t3, 0(t2)
#    or t3, t3, t1
#    sw t3, 0(t2)
#    li t1, 0x200000
#    add t1, t1, t0
#
    sw x0, 0(t1)

    li  t0, UART_ADDRESS

    # 0x3 -> 8 bit word length
    li  t1, 0x3
    sb  t1, LINE_CONTROL_REGISTER(t0)

    # 0x1 -> enable FIFOs
    li  t1, 0x1
    sb  t1, LINE_CONTROL_REGISTER(t0)

    # 0x1 -> enable reciever interrupts
    sb  t1, INTERRUPT_ENABLE_REGISTER(t0)

    ret
.cfi_endproc

uart_getc:
.cfi_startproc
    li      t0, UART_ADDRESS

    lbu     t1, LINE_STATUS_REGISTER(t0)
    andi    t1, t1, LINE_STATUS_DATA_READY

    bnez    t1, _uart_read

    # otherwise, return 0
    mv      a0, zero
    j       _uart_get_end

_uart_read:
    lbu     a0, (t0)
    j       _uart_get_end

_uart_get_end:
    ret
.cfi_endproc

uart_putc:
.cfi_startproc
    li  t0, UART_ADDRESS

    sb  a0, (t0)
    ret
.cfi_endproc
