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
    sfree
    ret

print_newline:
    salloc 0
    
    li a0,0xa
    call uart_putc
    li a0,0xd
    call uart_putc

    sfree    
    ret

print_int_hex:
    salloc 0

    li a1,'x'
    li a2,0
    li a3,' '
    call print_number

    sfree
    ret

print_int_dec:
    salloc 0

    li a1,'u'
    li a2,0
    li a3,' '
    call print_number

    sfree
    ret
