memcpy:
    mv t0,a0
    mv t1,a1
    li t2,0x1
    
1:
    lbu t3,(t1)
    sb t3,(t0)
    beq t2,a2,1f
    addi t0,t0,0x1
    addi t1,t1,0x1
    addi t2,t2,0x1
    j 1b
1:  ret
