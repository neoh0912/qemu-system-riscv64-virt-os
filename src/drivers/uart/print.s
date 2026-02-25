print_string:
    salloc 16
    sd s2, 0(sp)
    sd s3, 8(sp)

    mv s2, a0
    mv s3, zero

1:  add t0,s2,s3
    lbu a0, (t0)
    beqz a0, 1f
    call uart_putc
    addi s3,s3,1
    j 1b
1:
    ld s3, 8(sp)        
    ld s2, 0(sp)
    sfree 16
    ret

print_newline:
    salloc 0
    
    li a0,0xa
    call uart_putc
    li a0,0xd
    call uart_putc

    sfree 0    
    ret

print_int_hex:
    addi sp,sp,-72
    sd fp, 56(sp)
    sd ra, 64(sp)
    addi fp,sp,72
    sd s3,40(sp)
    sd s4,32(sp)
    sd s5,24(sp)
    sd s6,48(sp)
    
    mv s3,a0
    li s4,0x10
    li s6,0x0

    bnez s3,1f

    la t0,HEX
    lbu t1,(t0)
    add t0,sp,s6
    sb t1,(t0)
    addi s6,s6,1
    j 2f
    
1:  remu s5,s3,s4
    divu s3,s3,s4

    la t0,HEX
    add t0,t0,s5
    lbu t1,(t0)
    add t0,sp,s6
    sb t1,(t0)
    addi s6,s6,1
    
    bnez s3,1b
2:
    li a0,0x30
    call uart_putc
    li a0,0x78
    call uart_putc

1:  addi s6,s6,-1
    add t0,sp,s6
    lb a0, (t0)
    call uart_putc
    bnez s6,1b

    ld s6,48(sp)
    ld s5,24(sp)
    ld s4,32(sp)
    ld s3,40(sp)
    ld fp, 56(sp)
    ld ra, 64(sp)
    addi sp,sp,72

    
    ret

print_int_dec:
    addi sp,sp,-72
    sd fp, 56(sp)
    sd ra, 64(sp)
    addi fp,sp,72
    sd s3,40(sp)
    sd s4,32(sp)
    sd s5,24(sp)
    sd s6,48(sp)

    
    mv s3,a0
    li s4,10
    li s6,0x0

    bnez s3,1f

    la t0,HEX
    lbu t1,(t0)
    add t0,sp,s6
    sb t1,(t0)
    addi s6,s6,1
    j 2f

1:  remu s5,s3,s4
    divu s3,s3,s4
    
    la t0,HEX
    add t0,t0,s5
    lb t1,(t0)
    add t0,sp,s6
    sb t1,(t0)
    addi s6,s6,1
    
    bnez s3,1b

2:  addi s6,s6,-1
    add t0,sp,s6
    lb a0, (t0)
    call uart_putc
    bnez s6,2b

    ld s6,48(sp)
    ld s5,24(sp)
    ld s4,32(sp)
    ld s3,40(sp)
    ld fp, 56(sp)
    ld ra, 64(sp)
    addi sp,sp,72
    
    ret
