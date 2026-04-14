ext2_init:
    save

    li a0,sizeof_OPERATIONS
    call malloc
    bnez a0,1f
    ebreak  
    
1:  la t0,ext2_operations
    sd a0,(t0)

    restore
    ret
