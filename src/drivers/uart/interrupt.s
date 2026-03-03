uart_interrupt:
        save an=1
1:      call uart_getc
        beqz a0,1f
        call uart_queue_push
        j 1b

1:      ld a1,_a0(sp)
        li a0,0x0

        call plic_complete_interrupt
        restore
        j External_Interrupt_Handler_end
