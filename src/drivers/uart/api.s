uart_getc:
    li      t0, UART_ADDRESS

    lbu     t1, LINE_STATUS_REGISTER(t0)
    andi    t1, t1, LINE_STATUS_DATA_READY

    bnez    t1, 1f

    mv      a0, zero
    j       2f

1:
    lbu     a0, (t0)
2:
    ret

uart_putc:
    li  t0, UART_ADDRESS

    sb  a0, (t0)
    ret

uart_get:
        salloc 0
1:      la t0,uart_queue_head
        ld t1,(t0)
        la t2,uart_queue_tail
        ld t2,(t2)
        bne t1,t2,1f

        wfi

        j 1b
1:      call uart_queue_pop
        sfree
        ret
