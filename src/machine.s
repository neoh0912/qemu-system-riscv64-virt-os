machine_init:
    la t0, Exception_vector
    li t1,0x2
    andn t0,t0,t1
    ori t0,t0,0x1
    csrw mtvec, t0

    csrr t0,mstatus
    ori t0,t0,0x8
    csrw mstatus,t0

    csrr t0,mie

    li t1,0x800
    or t0,t0,t1
    
    csrw mie,t0
    
    ret
    
.align 3
Exception_vector:
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j External_Interrupt_Handler
    j Exception_handler
    j Exception_handler
    j Exception_handler
    j Exception_handler

Exception_handler:
    save_all
    call print_newline
#[ci [                  Print Regs                  ]

    la a0,machine_fault_cause_str
    call print_string

    csrr t1,mcause
1:  li t0,1
    bne t0,t1,1f
    la a0,machine_fault_E1_str
    j 2f
1:  li t0,2
    bne t0,t1,1f
    la a0,machine_fault_E2_str
    j 2f
1:  li t0,3
    bne t0,t1,1f
    la a0,machine_fault_E3_str
    j 2f
1:  li t0,5
    bne t0,t1,1f
    la a0,machine_fault_E5_str
    j 2f
1:  li t0,7
    bne t0,t1,1f
    la a0,machine_fault_E7_str
    j 2f
1:  li t0,8
    bne t0,t1,1f
    la a0,machine_fault_E8_str
    j 2f
1:  li t0,11
    bne t0,t1,1f
    la a0,machine_fault_E11_str
    j 2f
1:  li t0,24
    bne t0,t1,1f
    la a0,machine_fault_E24_str
    j 2f
1:  li t0,25
    bne t0,t1,1f
    la a0,machine_fault_E25_str
    j 2f
1:  li t0,0x800000000000000B
    bne t0,t1,1f
    la a0,machine_fault_uart_interupt_str
    j 2f
1:
2:
    call print_string
    call print_newline

    csrr a0,mepc
    addi sp,sp,-8
    sd a0,(sp)
    mv a1,sp
    la a0,machine_fault_mepc_fstr
    call printf
    addi sp,sp,8

    la a0,machine_fault_register_str
    call print_string    

    li s1,0
    li s2,31
    
1:  slli s3,s1,0x3 
    add s4,sp,s3
    ld a0,(s4)
    beqz a0,2f
    addi sp,sp,-24

    la t0,machine_regs
    add t0,t0,s3
    
    sd t0,(sp)
    sd a0,8(sp)
    sd a0,16(sp)
    
    la a0,machine_fault_register_fstr
    mv a1,sp

    call printf

    addi sp,sp,24
    
2:  addi s1,s1,1
    blt s1,s2,1b

    call print_newline

    la a0,machine_fault_heap_str
    call print_string

    call machine_print_heap
    call print_newline

    la a0,machine_fault_stack_str
    call print_string

    mv a0,sp
    call machine_print_stack


    csrr t0,mepc
    addi t0,t0,0x4
    csrw mepc,t0

    csrr t0,mcause
    li t1,0x3
    bne t0,t1,2f

1:  call uart_getc
    beqz a0,1b
    li t0,''
    bne a0,t0,1b
    call print_newline
    
2:  load_all
    mret

External_Interrupt_Handler:
    save_all
    li a0,0x0
    call plic_claim_interrupt
    li t0,0x20
    blt a0,t0,1f
    li t0,0x24
    bgt a0,t0,2f
    call pci_dispatch_interrupt
2:  j External_Interrupt_Handler_end
1:  slli t1,a0,0x2
    la t0,1f
    add t0,t0,t1
    jalr zero,t0,0x0
    
1:  j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    
    j uart_interrupt
    
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end
    j External_Interrupt_Handler_end

External_Interrupt_Handler_end:
    load_all
    mret


machine_print_heap:
    salloc 24
    sd s1,(sp)
    sd s2,8(sp)
    sd s3,16(sp)

    la s1,heap_start

1:  addi sp,sp,-24
    
    la a0,machine_heap_fstr
    mv a1,sp

    lwu t1,0x4(s1)
    beqz t1,3f
    la t6,machine_heap_alloc_str
    j 4f
3:  la t6,machine_heap_free_str
4:  sd t6,(sp)
    addi t6,s1,0x18
    li t2,0x2
    bne t1,t2,5f
    addi t6,t6,0x8  
5:  sd t6,8(sp)
    lwu t0,0x0(s1)
    sd t0,16(sp)
    
    call printf
    
    addi sp,sp,24
    
2:  mv t1,s1
    ld s1,0x8(t1)
    bge s1,t1,1b
    

    ld s1,(sp)
    ld s2,8(sp)
    ld s3,16(sp)
    sfree
    ret

machine_wfi:
    salloc 0

    sfree
    ret

machine_print_stack:
    salloc 0


    ld s1,0x8(a0)
    ld s2,0x38(a0)
    li s3,0x0

1:  ld t0,(s1)
    addi sp,sp,-0x10
    sd s3,(sp)
    sd t0,0x8(sp)
    la a0,machine_stack_val_fstr
    mv a1,sp
    call printf
    addi sp,sp,0x10

    addi s1,s1,0x8
    addi s3,s3,0x8
    blt s1,s2,1b

    sfree
    ret
    
