bounce:


    call uart_get

1:  li t0,'d'
    bne a0,t0,1f
    addi s1,s1,0x1
    j 2f
1:  li t0,'a'
    bne a0,t0,1f
    beqz s1,2f
    addi s1,s1,-0x1
    j 2f
1:  li t0,'s'
    bne a0,t0,1f
    addi s2,s2,0x1
    j 2f
1:  li t0,'w'
    bne a0,t0,1f
    beqz s2,2f
    addi s2,s2,-0x1
    j 2f
1: 
2:

    mv a0,s5
    la a1,image
    mv a2,s1
    mv a3,s2
    lbu a4,image_w
    lbu a5,image_h
    call display_write_sprite
    break_on_error
j bounce
