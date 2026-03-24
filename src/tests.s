test_blk:
    save

    call blk_dev_open 
    li a1,0 
    li a2,0 
    call blk_dev_read 

1: 
    wfi 
    j 1b     

    restore
    ret
