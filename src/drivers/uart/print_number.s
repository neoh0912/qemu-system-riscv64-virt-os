                                    # a0 = number       
                                    # a1 = specifier    
                                    # a2 = width        
                                    # a3 = flags        
print_number:
        salloc 32
        sd   s3,   -0(sp)
        sd   s4,   8(sp)
        sd   s5,  16(sp)
        sd   s6,  24(sp)
        
        mv s3,a0
        mv s6,sp

        la t2,HEX
        li t0,0x10
        li t1,'u'
        bne a1,t1,1f
        li t0,10
1:      li t1,'x'
        bne a1,t1,1f
        la t2,hex
        
1:      remu s4,s3,t0
        divu s3,s3,t0
        
        add t1,t2,s4
        lbu t1,(t1)
        
        addi sp,sp,-1
        sb t1,(sp)
        bnez s3,1b
        
        sub s3,s6,sp
        blt s3,a2,1f
        li s3,0
        j 3f
1:      sub s3,a2,s3
        li t1,'x'
        beq a1,t1,2f
        li t1,'X'
        bne a1,t1,3f
        
2:      li t1,2
        bge s3,t1,2f
        li s3,2
2:      addi s3,s3,-2

3:      li t0,'0'
        bne a3,t0,2f
        li t0,'x'
        beq a1,t0,1f
        li t0,'X'
        bne a1,t0,2f
        
1:      li a0,'0'
        call uart_putc
        mv a0,a1
        call uart_putc
        
2:      mv a0,a3

1:      beqz s3,1f
        call uart_putc
        addi s3,s3,-1
        j 1b

1:      li t0,'0'
        beq a3,t0,1f
        li t0,'x'
        beq a1,t0,2f
        li t0,'X'
        bne a1,t0,1f
        
2:      li a0,'0'
        call uart_putc
        mv a0,a1
        call uart_putc

1:      ble sp,s6,1f                # illegal if sp not le s6
        ecall

1:      lbu a0,(sp)
        call uart_putc
        addi sp,sp,1
        bne sp,s6,1b
                        

        ld   s6,  24(sp)
        ld   s5,  16(sp)
        ld   s4,   8(sp)
        ld   s3,   0(sp)
        sfree
        ret
