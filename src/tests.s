.include "const/font.s"
.include "const/char_display.s"

test_font:
        save

        la a0,VGA_FONT_DATA
        call font_load

        ebreak

        restore
        ret


test_char_display:
        save sn=9

        la a0,VGA_FONT_DATA
        call font_load
        bnez a0,1f
        ebreak

1:      mv a1,a0
        li a0,0x0
        li a2,80
        li a3,30
        call char_display_create

        mv s1,a0

        li s3,0x0
        li s4,50
        li s6,30
        li s8,80

        li s9,0x0
        
1:      li s5,0x0

2:      li s7,0x0

3:      mv a0,s1
        la a1,test__test_string
        call char_display_write
        addi s9,s9,1

        addi s7,s7,0x1
        blt s7,s8,3b

        mv a0,s1
        la a1,test__test_string_2
        call char_display_write  

        addi s5,s5,0x1
        blt s5,s6,2b

        li s5,0x0

        mv a0,s1
        la a1,test__test_string_4
        call char_display_write  

2:      li s7,0x0

3:      mv a0,s1
        la a1,test__test_string_3
        call char_display_write
        addi s9,s9,1

        addi s7,s7,0x1
        blt s7,s8,3b

        mv a0,s1
        la a1,test__test_string_2
        call char_display_write  

        addi s5,s5,0x1
        blt s5,s6,2b

        mv a0,s1
        la a1,test__test_string_4
        call char_display_write  

        addi s3,s3,0x1




blt s3,s4,1b

        mv a0,s9
        call print_int_dec

        restore
        ret

.macro test_rrip_read tag
    mv a0,s1
    li a1,(\tag)
    call rrip_get
    beqz a1,1f
    db 'h'
    j 2f
    
1:  db 'm'
    li a1,(\tag)
    li a2,0xFACE
    call rrip_set
2:
.endm    


test_rrip:
    save sn=1

    li a0,0x4
    call rrip_create
    mv s1,a0

    test_rrip_read 0
    test_rrip_read 1
    test_rrip_read 1
    test_rrip_read 0
    test_rrip_read 2
    test_rrip_read 3
    test_rrip_read 4
    test_rrip_read 5
    test_rrip_read 0
    test_rrip_read 1
    
    call print_newline
    mv a0,s1
    call free
   
    restore
    ret


test_ext2:
    save sn=1

    li a0,0x0
    call ext2_mount
    mv s1,a0
    call fs_mount_get_root_inode
    mv a1,a0
    mv a0,s1
    call ext2_get_inode
    call print_int_hex
    
    ebreak
    
    restore
    ret

test_blk:
    save dn=1

    li a0,1024
    call malloc
    li a2,1024
    mv a1,zero
    call memset
    mv s11,a0

    mv a0,s11
    call print_int_hex
    call print_newline

    li a0,0x0
    call blk_dev_open 
    mv s10,a0

    call blk_dev_get_total_blocks
    sd a0,_d0(sp)
    addi a1,sp,_d0
    la a0,test__blk_sectors_str
    call printf

    mv a0,s10
    call blk_dev_get_block_size
    sd a0,_d0(sp)
    addi a1,sp,_d0
    la a0,test__blk_block_size_str
    call printf
    call print_newline

    mv a0,s10
    li a1,0 
    mv a2,s11
    call blk_dev_read 

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

    restore
    ret


