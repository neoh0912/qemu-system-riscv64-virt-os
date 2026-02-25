printf:
        salloc 64
        sd   s3,   0(sp)
        sd   s4,   8(sp)
        sd   s5,  16(sp)
                
        mv s3,a0
        mv s4,zero
        mv s5,zero

9:      sd zero,40(sp)
        li t0,' '
        sd t0,48(sp)

        add t0,s4,s3 #load char
        lbu a0,(t0)

        beqz a0,9f # jump to end if null
        li t0,'%'
        beq a0,t0,1f
2:      call uart_putc # print normal char
        addi s4,s4,0x1
        j 9b
        
1:      addi s4,s4,0x1
        add t0,s4,s3
        lbu a0,(t0)
        beqz a0,9f # jump to end if null
        li t0,'%'
        beq a0,t0,2b
        
#[ci    [   Flags   ]

        li t0,'0'
        bne a0,t0,1f
        sb t0,48(sp)
        
2:      addi s4,s4,0x1
        add t0,s4,s3
        lbu a0,(t0)
        beqz a0,9f # jump to end if null

#[ci    [ Width ]

1:      li t0,'0'
        blt a0,t0,1f
        li t0,'9'+1
        bge a0,t0,1f

        ld t0,40(sp)
        li t1,10
        mul t0,t0,t1
        add t0,t0,a0
        addi t0,t0,-0x30
        sd t0,40(sp)
        j 2b        

#[ci    [ Specifier ]

1:      li t0,'u'
        beq a0,t0,2f
        li t0,'x'
        beq a0,t0,2f
        li t0,'X'
        bne a0,t0,1f
#[yi    [     Integer     ]

2:      sd a1,24(sp)
        sd a2,32(sp)    # Save regs    

        mv t0,a1
        mv a1,a0
        
        add t0,t0,s5 # arg addr + offset
        ld a0,(t0)
        
        ld a2,40(sp)
        lbu a3,48(sp)

        call print_number
        
        ld a2,32(sp)    # Restore regs  
        ld a1,24(sp)    #               
        
        addi s5,s5,0x8
        addi s4,s4,0x1
        j 9b
        
#[yi    [                 ]

1:      li t0,'c'
        bne a0,t0,1f

#[yi    [ Character ]

        add t0,a1,s5 # arg addr + offset
        lb a0,(t0)
        call uart_putc
        addi s5,s5,0x1
        addi s4,s4,0x1
        j 9b

#[yi    [           ]
        
1:      li t0,'s'
        bne a0,t0,1f

#[yi    [   String   ]

        add t0,a1,s5 # arg addr + offset
        ld a0,(t0)
        call print_string
        addi s5,s5,0x8
        addi s4,s4,0x1
        j 9b

#[yi    [            ]
        
1:      call uart_putc
        ecall
        

9:      ld   s5,  16(sp)
        ld   s4,   8(sp)
        ld   s3,   0(sp)
        sfree 64
        ret        
