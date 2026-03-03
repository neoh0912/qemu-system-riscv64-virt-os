print_string:
    save sn=2
    mv s1, a0
    mv s2, zero

1:  add t0,s1,s2
    lbu a0, (t0)
    beqz a0, 1f
    call uart_putc
    addi s2,s2,1
    j 1b
1:
    restore
    ret

print_newline:
    save
    
    li a0,0xa
    call uart_putc
    li a0,0xd
    call uart_putc

    restore    
    ret

print_int_hex:
    li a1,'x'
    li a2,0
    li a3,' '
    tail print_number

print_int_dec:
    li a1,'u'
    li a2,0
    li a3,' '
    tail print_number

