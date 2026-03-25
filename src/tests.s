test_blk:
    save

    li a0,512
    call malloc
    li a2,512
    mv a1,zero
    call memset
    mv s11,a0

    li a0,0x0
    call blk_dev_open 
    li a1,0 
    mv a2,s11
    call blk_dev_read 

    mv a0,s11
    call print_int_hex


1:
wfi
j 1b
    restore
    ret
