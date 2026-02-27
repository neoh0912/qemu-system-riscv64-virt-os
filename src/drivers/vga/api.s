vga_flush:
        salloc 64

        sd t0,(sp)
        sd t1,8(sp)
        sd t2,0x10(sp)
        sd t3,0x18(sp)
        
        la t0,vga_frame_buffer_ptr
        ld t0,(t0)
        ld t1,vga_buffer

        li t2,0x0
        li t3,1280*1080

1:      ld t4,(t1)
        sd t4,(t0)

        addi t0,t0,0x8
        addi t1,t1,0x8

        addi t2,t2,0x2
        blt t2,t3,1b

        ld t0,(sp)
        ld t1,8(sp)
        ld t2,0x10(sp)
        ld t3,0x18(sp)

        sfree

        ret


vga_write_rect:
#[ci [ a0 = color, a1 = x, a2 = y, a3 = w, a4 = h ]
        salloc 58
        
        sd s1,(sp)
        sd s2,8(sp)
        sd s3,0x10(sp)
        
        sd s4,0x18(sp)
        sd s5,0x20(sp)
    
        li s1,0x0
        ld s3,vga_buffer
        li s4,1280

1:      li s2,0x0
        add s5,s1,a2
        mul s5,s5,s4
        add s5,s5,a1
        slli s5,s5,0x2
        add s5,s5,s3
        
2:      sw a0,(s5)
        addi s5,s5,0x4

        addi s2,s2,0x1
        blt s2,a3,2b
        
        addi s1,s1,0x1
        blt s1,a4,1b

        ld s1,(sp)
        ld s2,8(sp)
        ld s3,0x10(sp)        

        ld s4,0x18(sp)
        ld s5,0x20(sp)
        
        sfree
        ret
