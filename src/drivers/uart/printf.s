printf:
        save sn=3,dn=4
                
        mv s1,a0
        mv s2,zero
        mv s3,zero

9:      sd zero,_d0(sp)
        li t0,' '
        sd t0,_d1(sp)

        add t0,s2,s1 #load char
        lbu a0,(t0)

        beqz a0,9f # jump to end if null
        li t0,'%'
        beq a0,t0,1f
2:      call uart_putc # print normal char
        addi s2,s2,0x1
        j 9b
        
1:      addi s2,s2,0x1
        add t0,s2,s1
        lbu a0,(t0)
        beqz a0,9f # jump to end if null
        li t0,'%'
        beq a0,t0,2b
        
#[ci    [   Flags   ]

        li t0,'0'
        bne a0,t0,1f
        sb t0,_d1(sp)
        
2:      addi s2,s2,0x1
        add t0,s2,s1
        lbu a0,(t0)
        beqz a0,9f # jump to end if null

#[ci    [ Width ]

1:      li t0,'0'
        blt a0,t0,1f
        li t0,'9'+1
        bge a0,t0,1f

        ld t0,_d0(sp)
        li t1,10
        mul t0,t0,t1
        add t0,t0,a0
        addi t0,t0,-0x30
        sd t0,_d0(sp)
        j 2b        

#[ci    [ Specifier ]

1:      li t0,'u'
        beq a0,t0,2f
        li t0,'x'
        beq a0,t0,2f
        li t0,'X'
        bne a0,t0,1f
#[yi    [     Integer     ]

2:      sd a1,_d2(sp)
        sd a2,_d3(sp)    # Save regs    

        mv t0,a1
        mv a1,a0
        
        add t0,t0,s3 # arg addr + offset
        ld a0,(t0)
        
        ld a2,_d0(sp)
        lbu a3,_d1(sp)

        call print_number
        
        ld a2,_d3(sp)    # Restore regs  
        ld a1,_d2(sp)    #               
        
        addi s3,s3,0x8
        addi s2,s2,0x1
        j 9b
        
#[yi    [                 ]

1:      li t0,'c'
        bne a0,t0,1f

#[yi    [ Character ]

        add t0,a1,s3 # arg addr + offset
        lb a0,(t0)
        call uart_putc
        addi s3,s3,0x1
        addi s2,s2,0x1
        j 9b

#[yi    [           ]
        
1:      li t0,'s'
        bne a0,t0,1f

#[yi    [   String   ]

        add t0,a1,s3 # arg addr + offset
        ld a0,(t0)
        call print_string
        addi s3,s3,0x8
        addi s2,s2,0x1
        j 9b

#[yi    [            ]
        
1:      call uart_putc
        ecall
        

9:      restore
        ret        
