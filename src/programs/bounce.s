bounce:
    salloc 0

    beqz s3,1f
    addi s1,s1,1
    blt s1,s5,3f
    li s3,0x0
3:  j 2f
1:  addi s1,s1,-1
    bnez s1,2f
    li s3,0x1
2:  beqz s4,1f
    addi s2,s2,1
    blt s2,s6,3f
    li s4,0x0
3:  j 2f
1:  addi s2,s2,-1
    bnez s2,2f
    li s4,0x1
2:  li a0,0x0000FF00
    mv a1,s1
    mv a2,s2
    li a3,0x1
    li a4,0x1
    call vga_write_rect
    call vga_flush

    sfree 0
    ret
