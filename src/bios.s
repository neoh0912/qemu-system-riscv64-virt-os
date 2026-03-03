bios_handle_input:
    save
    
    call uart_get

    li t0,0x8
    bne a0,t0,2f
    ebreak
    j 1f
2:  li t0,0x1B
    bne a0,t0,2f
    call bios_escape_sequence
2:  call uart_putc    
    restore
    ret

bios_escape_sequence:
    save
        
    call uart_get
    li t0,0x4F #[ri [O]
    bne a0,t0,2f
    call uart_get
    li t0,0x50 #[ri [P]
    bne a0,t0,1f
    call bios_write_disk
1:  li t0,0x51 #[ri [R]
    bne a0,t0,2f
    call bios_read_disk
2:    
    restore
    ret

bios_write_disk:
    save dn=1
    
    la a0,bios_store_str
    call print_string
    la a0,bios_addr_str    
    call print_string
    call bios_input_hex
    sd a0,_d0(sp)
    la a0,bios_input_buffer
    call bios_input_string
    mv a2,a0
    ld a0,_d0(sp)
    la a1,bios_input_buffer
    call ivshmem_sb
    call print_newline

    restore
    ret

bios_read_disk:
    save dn=1

    la a0,bios_load_str
    call print_string
    la a0,bios_addr_str 
    call print_string
    call bios_input_hex
    sd a0,_d0(sp)
    la a0,bios_len_str
    call print_string
    call bios_input_int
    mv a2,a0
    ld a0,_d0(sp)
    la a1,bios_input_buffer
    call ivshmem_lbu

    add t0,a2,a1
    sb zero,(t0)
    
    la a0,bios_input_buffer
    call print_string    
    call print_newline
    restore
    ret


bios_input_hex:
    save sn=2

    mv s1,zero
1:  call uart_get
    
    mv s2,a0

    li t0,0x8
    bne a0,t0,5f
    srli s1,s1,0x4
    la a0,bios_del_char
    call print_string
    j 1b
    
5:  li t0,0xd
    beq a0,t0,2f
    li t0,0xa
    beq a0,t0,2f

    li t0,0x30
    blt a0,t0,1b
    li t0,0x3a
    blt a0,t0,3f
    li t0,0x41
    blt a0,t0,1b
    li t0,0x47
    blt a0,t0,4f
    j 1b    
4:  addi a0,a0,-7
3:  addi a0,a0,-0x30
    slli s1,s1,0x4
    add s1,s1,a0
    mv a0,s2
    call uart_putc
    j 1b
    
2:  call print_newline
    mv a0,s1

    restore
    ret

bios_input_int:
    save sn=2

    mv s1, zero
1:  call uart_get

    mv s2,a0

    li t0,0x8
    bne a0,t0,5f
    li t0,10
    div s1,s1,t0
    la a0,bios_del_char
    call print_string
    j 1b
    
5:  li t0,0xd
    beq a0,t0,2f
    li t0,0xa
    beq a0,t0,2f

    li t0,0x30
    blt a0,t0,1b
    li t0,0x3a
    blt a0,t0,3f
    j 1b    
3:  addi a0,a0,-0x30
    li t0,10
    mul s1,s1,t0
    add s1,s1,a0
    mv a0,s2
    call uart_putc
    j 1b
    
2:  call print_newline
    mv a0,s1

    restore
    ret

bios_input_string:
    save sn=2
    mv s1,a0
    mv s2,zero

1:  call uart_get
    li t0,0xD
    beq a0,t0,2f
    li t0,0x8
    bne a0,t0,3f
    addi s2,s2,-1
    la a0,bios_del_char
    call print_string
    j 1b
    
3:  add t0,s1,s2
    sb a0,(t0)
    addi s2,s2,0x1
    call uart_putc
    j 1b

2:  mv a0,s2

    restore
    ret
