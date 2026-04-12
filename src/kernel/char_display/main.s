.include "const/char_display.s"
.include "const/font.s"

char_display_create:
#[ci [ device_id, font, w,h ]
        save an=4,sn=3

        li a0,sizeof_CHAR_DISPLAY
        call malloc
        bnez a0,1f
        ebreak

1:      mv s1,a0
        li a2,sizeof_CHAR_DISPLAY
        li a1,0x0
        call memset
        
        ld a0,_a0(sp)
        call display_open
        break_on_error
        sd a0,CHAR_DISPLAY__device_handle(s1)

        ld t0,_a1(sp)
        lwu t1,FONT__w(t0)
        ld t2,_a2(sp)
        sd t2,CHAR_DISPLAY__w(s1)
        mul a1,t1,t2
        lwu t1,FONT__h(t0)
        ld s2,_a3(sp)
        sd s2,CHAR_DISPLAY__h(s1)
        mul a2,t1,s2
        mul s2,s2,t2

        call display_set_resolution

        mv a0,s1

        call char_display_update_cursor_absolute_position

        ld t0,_a1(sp)
        sd t0,CHAR_DISPLAY__font(s1)

        li t0,CHAR_DISPLAY_DEFAULT_FG
        sw t0,CHAR_DISPLAY__state__fg(s1)
        li t0,CHAR_DISPLAY_DEFAULT_BG
        sw t0,CHAR_DISPLAY__state__bg(s1)

        li t0,(1<<ANSI_MODE__line_feed)
        sb t0,CHAR_DISPLAY__state__ansi_mode(s1)
        li t0,(1<<PRIVATE_MODE__text_cursor_enable)
        sb t0,CHAR_DISPLAY__state__private_mode(s1)
        
        li t0,0x4
        sb t0,CHAR_DISPLAY__state__tab_size(s1)

        slli s3,s2,0x1
        mv a0,s3
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__glyph_buffer(s1)
        mv t0,a0
        mv t1,s3
        add t1,t1,t0

1:      bge t0,t1,1f

        li t2,' '
        sh t2,(t0)

        addi t0,t0,0x2
        j 1b
        

1:      slli s3,s2,0x2
        mv a0,s3
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__fg_buffer(s1)
        li a1,CHAR_DISPLAY_DEFAULT_FG
        mv a2,s3
        call memset

        mv a0,s3
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__bg_buffer(s1)
        li a1,CHAR_DISPLAY_DEFAULT_BG
        mv a2,s3
        call memset

        mv a0,s2
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__attribute_buffer(s1)
        li a1,0x0
        mv a2,s2
        call memset

        li t0,0x8
        remu t0,s2,t0
        sub s2,s2,t0
        srli s2,s2,0x3
        beqz t0,1f
        addi s2,s2,0x1
1:      mv a0,s2
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__buffer_mask(s1)
        li a1,0x0
        mv a2,s2
        call memset

        sh s2,CHAR_DISPLAY__sizeof_buffer_mask(s1)

        mv a0,s1

        restore
        ret

char_display_flush:
#[ci [ char_display ]
        save an=1,sn=11,bn=42,dn=2
_args = _b0
_glyph = _args + 0x0
_buffer = _args + 0x2
_w = _args + 0xA
_offset = _args + 0x12
_fg = _args + 0x1A
_bg = _args + 0x1E


        ld s5,CHAR_DISPLAY__glyph_buffer(a0)
        ld s6,CHAR_DISPLAY__fg_buffer(a0)
        ld s7,CHAR_DISPLAY__bg_buffer(a0)
        ld s8,CHAR_DISPLAY__attribute_buffer(a0)

        ld s2,CHAR_DISPLAY__buffer_mask(a0)
        ld s3,CHAR_DISPLAY__font(a0)

        lwu t0,CHAR_DISPLAY__w(a0)
        lwu t1,CHAR_DISPLAY__h(a0)
        mul s10,t0,t1


        lwu t0,FONT__w(s3)
        mul s9,s10,t0

        lwu s11,FONT__w(s3)
        lwu t0,CHAR_DISPLAY__w(a0)
        mul t0,t0,s11
        lbu t1,CHAR_DISPLAY__state__scroll(a0)
        mul t0,t0,t1
        sd t0,_offset(sp)


        ld s1,CHAR_DISPLAY__device_handle(a0)
        mv a0,s1
        call display_get_resolution
        slli t0,a0,0x2
        sd t0,_w(sp)
        
        mv a0,s1
        call display_get_frame_buffer
        sd a0,_buffer(sp)

        mv a0,s3

        li s1,0x0
        li s4,0x0
1:      lbu s3,(s2)
        sb zero,(s2)
        addi s2,s2,0x1
3:      andi t0,s3,0x1
        srli s3,s3,0x1
        beqz t0,2f

        ld t1,_offset(sp)
        mul t0,s4,s11
        add t1,t1,t0
        mv s4,zero
        remu t1,t1,s9
        sd t1,_offset(sp)

        lhu t0,(s5)
        sh t0,_glyph(sp)

        lwu t1,(s6)
        lwu t2,(s7)
        lbu t0,(s8)
        andi t0,t0,CURSOR_FLAG
        bnez t0,6f

        sw t1,_fg(sp)
        sw t2,_bg(sp)
        j 7f
6:      sw t1,_bg(sp)
        sw t2,_fg(sp)
7:      addi a1,sp,_args
        call font_write_glyph

2:      addi s1,s1,1
        addi s5,s5,0x2
        addi s6,s6,0x4
        addi s7,s7,0x4
        addi s8,s8,0x1
        addi s4,s4,0x1
        bge s1,s10,1f
        andi t0,s1,0x7
        bnez t0,3b
        j 1b



1:      restore
        ret

