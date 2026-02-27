uart_interrupt:
        salloc 8
        sd a0,(sp)
1:      call uart_getc
        beqz a0,1f
        call uart_queue_push
        j 1b

1:      ld a1,(sp)
        li a0,0x0

        call plic_complete_interrupt
        sfree
        j External_Interrupt_Handler_end
