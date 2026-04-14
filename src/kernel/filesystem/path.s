fs_path_next:
#[ci [ path, buffer ]
        save

        mv t0,a0
        mv t1,a1

1:      lbu t2,(t0)
        li t3,'/'
        bne t2,t3,1f
        addi t0,t0,1
        j 1b
        
1:      lbu t2,(t0)
        beqz t2,1f
        li t3,'/'
        beq t2,t3,1f

        sb t2,(t1)
        addi t0,t0,0x1
        addi t1,t1,0x1
        j 1b
        
1:      sb zero,(t1)
        mv a0,t0
        restore
        ret
