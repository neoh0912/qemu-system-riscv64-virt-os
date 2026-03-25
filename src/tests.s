test_blk:
    save

    li a0,512
    call malloc
    li a2,512
    mv a1,zero
    call memset
    mv s11,a0

    mv a0,s11
    call print_int_hex

    li a0,0x0
    call blk_dev_open 
    mv s10,a0
    li a1,0 
    mv a2,s11
    call blk_dev_read 

    ebreak

    li t0,'N'
    sb t0,0x0(s11)
    li t0,'e'
    sb t0,0x1(s11)
    li t0,'o'
    sb t0,0x2(s11)
    li t0,'h'
    sb t0,0x3(s11)
    li t0,'.'
    sb t0,0x4(s11)
    li t0,'0'
    sb t0,0x5(s11)
    
    mv a0,s10
    li a1,0
    mv a2,s11
    call blk_dev_write



1:
wfi
j 1b
    restore
    ret
