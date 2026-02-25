.equ UART_RHR, 0x0
.equ UART_THR, 0x0
.equ UART_IER, 0x1
.equ UART_ISR, 0x2
.equ UART_FCR, 0x2
.equ UART_LCR, 0x3
.equ UART_MCR, 0x4
.equ UART_LSR, 0x5
.equ UART_MSR, 0x6

.equ PLIC_BASE,      0x0c000000
.equ UART_PLIC_ID,        10
.equ UART_QUEUE_SIZE, 32

uart_init:
        salloc 0
        #[ci [ Init Queue ]
        li a0,UART_QUEUE_SIZE
        call malloc
        la t0,uart_queue_start
        sd a0,(t0)
        la t0,uart_queue_head
        sd a0,(t0)
        la t0,uart_queue_tail
        sd a0,(t0)

        #[ci [ Enable interupt ]
        li t0,  UART_ADDRESS
        
        lbu t1, UART_IER(t0)
        ori t1,t1,0x1
        sb t1,  UART_IER(t0)

        li  t1, 0x3
        sb  t1, UART_LCR(t0)

        li  t1, 0x1
        sb  t1, UART_FCR(t0)

        li a0,UART_PLIC_ID
        call plic_enable
        li a1,0x1
        call plic_set_prio
        mv a0,zero
        mv a1,zero
        call plic_set_prio_thres
        sfree 0
        ret

uart_queue_push:
        li t0,UART_QUEUE_SIZE
        la t1,uart_queue_start
        ld t2,(t1)
        add t3,t0,t2
        la t0,uart_queue_tail
        ld t1,(t0)
        sb a0,(t1)
        addi t1,t1,0x1
        blt t1,t3,1f
        mv t1,t2
1:      sd t1,(t0)
        ret

uart_queue_pop:
        li t0,UART_QUEUE_SIZE
        la t1,uart_queue_start
        ld t2,(t1)
        add t3,t0,t2
        la t0,uart_queue_head
        ld t1,(t0)
        lbu a0,(t1)
        addi t1,t1,0x1
        blt t1,t3,1f
        mv t1,t2
1:      sd t1,(t0)
        ret

