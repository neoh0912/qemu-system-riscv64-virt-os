                                    # a0 = number       
                                    # a1 = specifier    
                                    # a2 = width        
                                    # a3 = flags        
print_number:
        save sn=4
        
        mv s1,a0
        mv s4,sp

        la t2,HEX
        li t0,0x10
        li t1,'u'
        bne a1,t1,1f
        li t0,10
1:      li t1,'x'
        bne a1,t1,1f
        la t2,hex
        
1:      remu s2,s1,t0
        divu s1,s1,t0
        
        add t1,t2,s2
        lbu t1,(t1)
        
        addi sp,sp,-1
        sb t1,(sp)
        bnez s1,1b
        
        sub s1,s4,sp
        blt s1,a2,1f
        li s1,0
        j 3f
1:      sub s1,a2,s1
        li t1,'x'
        beq a1,t1,2f
        li t1,'X'
        bne a1,t1,3f
        
2:      li t1,2
        bge s1,t1,2f
        li s1,2
2:      addi s1,s1,-2

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

1:      beqz s1,1f
        call uart_putc
        addi s1,s1,-1
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

1:      ble sp,s4,1f                # illegal if sp not le s4
        ecall

1:      lbu a0,(sp)
        call uart_putc
        addi sp,sp,1
        bne sp,s4,1b
                        

        restore
        ret
