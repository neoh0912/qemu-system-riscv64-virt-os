memset:
#[ci [ a0 = *ptr, a1 = c, a2 = n ]
        mv t0,a0
        li t1,0x0
        
1:      bge t1,a2,1f        
        sb a1,(t0)
        addi t0,t0,1
        addi t1,t1,1
        j 1b

1:      ret
