.include "const/font.s"

PSF1_FONT_MAGIC = 0x0436
PSF_FONT_MAGIC = 0x864ab572

font_load:
#[ci [ void* font_binary ] -> FONT/ERROR 
        save an=1,sn=1

        li a0,sizeof_FONT
        call malloc
        bnez a0,1f
        ebreak
        
1:      li a1,0x0
        li a2,sizeof_FONT
        call memset
        mv s1,a0



        ld t0,_a0(sp)
        lhu t1,(t0)
        li t2,PSF1_FONT_MAGIC
        bne t1,t2,1f

        mv a1,t0
        call font_load_psf1
        j 2f

1:      lwu t1,(t0)
        li t2,PSF_FONT_MAGIC
        bne t1,t2,1f

        mv a1,t0
        call font_load_psf
        j 2f

1:      li a0,0x0
        j 9f


2:      mv a0,s1
        ld t0,FONT__utf8_map(a0)
        beqz t0,1f

        call font_sort_utf8_table
        mv a0,s1
        li a1,' '
        call font_get_glyph
        sh a0,FONT__space(s1)        

1:      mv a0,s1


9:      restore
        ret

font_get_glyph:
#[ci [ Font font, utf8 ]
        save an=2,sn=4

        ld s1,FONT__utf8_map(a0)
        li s2,0x0
        lwu s3,FONT__utf8_map_size(a0)

1:      add s4,s2,s3
        srli s4,s4,0x1
        li t0,sizeof_UTF8MAP
        mul t0,s4,t0
        add t0,t0,s1
        lwu t1,UTF8MAP__utf8(t0)

        bne t1,a1,2f
        lhu a0,UTF8MAP__glyph(t0)
        j 9f

2:      ble t1,a1,2f
        mv s3,s4
        j 3f

2:      mv s2,s4
        addi s2,s2,0x1
3:      blt s2,s3,1b

        li a0,0xEFBFBF

9:      restore
        ret

font_write_glyph:
#[ci [ Font font, void* args] args = ( glyph, buffer, w,offset,fg,bg )
_glyph = 0x0
_buffer = 0x2
_w = 0xA
_offset = 0x12
_fg = 0x1A
_bg = 0x1E
        save an=2,sn=11

        lwu t0,FONT__size(a0)
        lhu t1,_glyph(a1)
        mul t1,t1,t0
        ld t0,FONT__glyphs(a0)
        add s1,t0,t1 # glyph

        ld s11,_w(a1)
        
        ld t0,_offset(a1)
        slli t0,t0,0x2

        addi t3,s11,0x0
        divu t1,t0,t3
        lwu t2,FONT__h(a0)
        mul t1,t1,t2
        mul t1,t1,t3
        remu t0,t0,t3
        add t0,t0,t1
        
        ld t1,_buffer(a1)
        add s2,t0,t1 # buffer[offset]

        li s3,0x0
        li s4,0x0
        lwu s5,FONT__h(a0)
        lwu s7,FONT__w(a0)
        lwu s9,_fg(a1)
        lwu s10,_bg(a1)

1:      li s6,0x0

        mv t0,s2

2:      li t1,0x8
        remu t1,s6,t1
        bnez t1,3f
        
        lbu s8,(s1)
        addi s1,s1,0x1
        
3:      andi t1,s8,0x80
        slli s8,s8,0x1
        beqz t1,3f
        
        sw s9,(t0)
        j 4f
        
3:      sw s10,(t0)

4:      addi t0,t0,0x4
        addi s6,s6,0x1
        blt s6,s7,2b

        add s2,s2,s11
        addi s4,s4,0x1
        blt s4,s5,1b

        restore
        ret

font_load_psf:
#[ci [ FONT font, void* font_binary ]
        save an=2,sn=1

        lwu t0,PSF_FONT_HEADER__Width(a1)
        sw t0,FONT__w(a0)
        lwu t0,PSF_FONT_HEADER__Height(a1)
        sw t0,FONT__h(a0)

        lwu t0,PSF_FONT_HEADER__Glyph_size(a1)
        sw t0,FONT__size(a0)
        lwu s1,PSF_FONT_HEADER__Length(a1)
        sw s1,FONT__length(a0)

        mul s1,t0,s1

        mv a0,s1
        call malloc
        bnez a0,1f
        ebreak

1:      ld t0,_a0(sp)
        sd a0,FONT__glyphs(t0)
        ld a1,_a1(sp)
        lwu t0,PSF_FONT_HEADER__Header_Size(a1)
        add a1,a1,t0
        mv a2,s1
        call memcpy

        ld t0,_a1(sp)
        lwu t1,PSF_FONT_HEADER__Flags(t0)
        ori t1,t1,0x1
        beqz t1,1f

        ld a0,_a0(sp)
        ld a1,_a1(sp)
        mv a2,s1

        call font_parse_psf_utf8_table
        
1:      restore
        ret

font_parse_psf_utf8_table:
#[ci [ FONT font, void* font_binary, u_size glyph_size ]
        save an=3,sn=8

        lwu t0,FONT__length(a0)
        sw t0,FONT__utf8_map_size(a0)
        li s1,sizeof_UTF8MAP
        mul s1,t0,s1
        mv a0,s1
        call malloc
        bnez a0,1f
        ebreak

1:      ld t0,_a0(sp)
        sd a0,FONT__utf8_map(t0)
        
        ld t0,_a1(sp)
        lwu s1,PSF_FONT_HEADER__Header_Size(t0)
        add t0,t0,s1
        ld s1,_a2(sp)
        add s1,t0,s1

        li s2,0x0
        li s3,0x0

        ld s5,_a0(sp)

1:      lwu t0,FONT__length(s5)
        bge s3,t0,1f

        lbu s4,(s1)
        addi s1,s1,0x1

        li t0,0xFF
        bne s4,t0,2f
        addi s3,s3,0x1
        j 1b
        
2:      li t0,0x7F
        ble s4,t0,2f

        slli t0,s4,0x8
        lbu s4,(s1)
        addi s1,s1,0x1
        or s4,t0,s4

        li t0,0xDFBF
        ble s4,t0,2f

        slli t0,s4,0x8
        lbu s4,(s1)
        addi s1,s1,0x1
        or s4,t0,s4

        li t0,0xEFBFBF
        ble s4,t0,2f

        slli t0,s4,0x8
        lbu s4,(s1)
        addi s1,s1,0x1
        or s4,t0,s4

2:      ld s8,FONT__utf8_map(s5)
        li t1,sizeof_UTF8MAP
        mul t1,t1,s2
        add t0,s8,t1

        sw s4,UTF8MAP__utf8(t0)
        sh s3,UTF8MAP__glyph(t0)

        addi s2,s2,0x1
        lwu s6,FONT__utf8_map_size(s5)
        blt s2,s6,1b 

        slli s6,s6,0x1
        sw s6,FONT__utf8_map_size(s5)
        li t0,sizeof_UTF8MAP
        mul s6,s6,t0
        mv a0,s6
        call malloc
        bnez a0,3f
        ebreak
        
3:      mv a1,s8
        srli a2,s6,0x1
        call memcpy

        sd a0,FONT__utf8_map(s5)
        mv a0,s8
        call free

        j 1b



1:      li t0,sizeof_UTF8MAP
        mul s1,s2,t0
        mv a0,s1
        call malloc
        bnez a0,1f
        ebreak

1:  
        mv a2,s1
        ld a1,FONT__utf8_map(s5)
        sd a0,FONT__utf8_map(s5)
        mv s1,a1
        call memcpy

        sw s2,FONT__utf8_map_size(s5)
        mv a0,s1
        call free

        restore
        ret

font_sort_utf8_table:
#[ci [ FONT font ]
        save an=1,sn=1

        lwu s1,FONT__utf8_map_size(a0)
        li t1,sizeof_UTF8MAP
        mul a0,s1,t1
        call malloc
        bnez a0,1f
        ebreak
        
1:      mv a1,a0
        mv a3,s1
        addi a3,a3,-1
        mv s1,a1
        ld a0,_a0(sp)
        ld a0,FONT__utf8_map(a0)
        li a2,0x0
        call font_sort_utf8_table_rec

        restore
        ret

font_sort_utf8_table_rec:
#[ci [ arr, temp, low, high ]
        save an=4,sn=1

        bge a2,a3,9f

        sub s1,a3,a2
        srli s1,s1,0x1
        add s1,s1,a2

        mv a3,s1
        call font_sort_utf8_table_rec

        ld a0,_a0(sp)
        ld a1,_a1(sp)

        mv a2,s1
        addi a2,a2,0x1

        ld a3,_a3(sp)
        call font_sort_utf8_table_rec

        ld a0,_a0(sp)
        ld a1,_a1(sp)
        ld a2,_a2(sp)
        mv a3,s1
        ld a4,_a3(sp)

        call font_sort_utf8_table_merge

9:      restore
        ret

font_sort_utf8_table_merge:
#[ci [ arr, temp, low, mid, high ]
        save an=2,sn=6

        mv s1,a2
        mv s2,a3
        mv s3,a4
        mv s4,s1        # i
        addi s5,s2,0x1  # j
        mv s6,s1        # k


1:      bgt s4,s2,1f
        bgt s5,s3,1f

        li t6,sizeof_UTF8MAP
        mul t0,s4,t6
        add t0,t0,a0

        lwu t1,UTF8MAP__utf8(t0)

        mul t2,s5,t6
        add t2,t2,a0
        lwu t3,UTF8MAP__utf8(t2)

        mul t4,s6,t6
        add t4,t4,a1
        addi s6,s6,0x1

        bgt t1,t3,3f

        lwu t1,UTF8MAP__utf8(t0)
        lhu t0,UTF8MAP__glyph(t0)
        addi s4,s4,0x1
        j 4f

3:      lwu t1,UTF8MAP__utf8(t2)
        lhu t0,UTF8MAP__glyph(t2)
        addi s5,s5,0x1

4:      sw t1,UTF8MAP__utf8(t4)
        sh t0,UTF8MAP__glyph(t4)
        j 1b




1:      li t6,sizeof_UTF8MAP
1:      bgt s4,s2,1f

        mul t0,s6,t6
        add t0,t0,a1
        mul t1,s4,t6
        add t1,t1,a0

        lwu t2,UTF8MAP__utf8(t1)
        sw t2,UTF8MAP__utf8(t0)
        lhu t2,UTF8MAP__glyph(t1)
        sh t2,UTF8MAP__glyph(t0)

        addi s6,s6,0x1
        addi s4,s4,0x1

        j 1b

1:      bgt s5,s3,1f

        mul t0,s6,t6
        add t0,t0,a1
        mul t1,s5,t6
        add t1,t1,a0

        lwu t2,UTF8MAP__utf8(t1)
        sw t2,UTF8MAP__utf8(t0)
        lhu t2,UTF8MAP__glyph(t1)
        sh t2,UTF8MAP__glyph(t0)

        addi s6,s6,0x1
        addi s5,s5,0x1

        j 1b

1:      mv s4,s1

        li t0,sizeof_UTF8MAP
        mul t0,s4,t0
        add t1,t0,a1
        add t0,t0,a0

1:      bgt s4,s3,1f

        lwu t2,UTF8MAP__utf8(t1)
        sw t2,UTF8MAP__utf8(t0)
        lhu t2,UTF8MAP__glyph(t1)
        sh t2,UTF8MAP__glyph(t0)

        addi t0,t0,sizeof_UTF8MAP
        addi t1,t1,sizeof_UTF8MAP
        addi s4,s4,0x1
        j 1b

1:

        restore
        ret

        

font_load_psf1:
