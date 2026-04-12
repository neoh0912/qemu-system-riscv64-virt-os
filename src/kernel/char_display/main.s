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

        ld t0,_a1(sp)
        sd t0,CHAR_DISPLAY__font(s1)

        li t0,CHAR_DISPLAY_DEFAULT_FG
        sw t0,CHAR_DISPLAY__state__fg(s1)
        li t0,CHAR_DISPLAY_DEFAULT_BG
        sw t0,CHAR_DISPLAY__state__bg(s1)

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

        mv a0,s1

        restore
        ret

char_display_flush:
#[ci [ char_display ]
        save an=1,sn=11,bn=42
_args = _b0
_glyph = _args + 0x0
_buffer = _glyph + 0x2
_w = _buffer + 0x8
_x = _w + 0x8
_y = _x + 0x8
_fg = _y + 0x8
_bg = _fg + 0x4

        ld s7,CHAR_DISPLAY__glyph_buffer(a0)
        ld s8,CHAR_DISPLAY__fg_buffer(a0)
        ld s9,CHAR_DISPLAY__bg_buffer(a0)
        ld s11,CHAR_DISPLAY__attribute_buffer(a0)

        ld s10,CHAR_DISPLAY__font(a0)

        lwu s2,CHAR_DISPLAY__h(a0)
        lwu s5,CHAR_DISPLAY__w(a0)
        
        ld s1,CHAR_DISPLAY__device_handle(a0)
        mv a0,s1
        call display_get_resolution
        slli a0,a0,0x2
        sd a0,_w(sp)
        mv a0,s1
        call display_get_frame_buffer
        sd a0,_buffer(sp)

        lwu s3,FONT__h(s10)
        mul s2,s2,s3
        lwu s6,FONT__w(s10)
        mul s5,s5,s6

        li s1,0x0

1:      bge s1,s2,1f
        li s4,0x0
        sd s1,_y(sp)

2:      bge s4,s5,2f

        sd s4,_x(sp)

        lhu t0,(s7)
        addi s7,s7,0x2
        sh t0,_glyph(sp)

        lhu t2,(s11)
        addi s11,s11,0x1
        
        lwu t0,(s8)
        lwu t1,(s9)
        addi s8,s8,0x4
        addi s9,s9,0x4

        andi t3,t2,(CURSOR_FLAG)
        beqz t3,3f

        sw t1,_fg(sp)
        sw t0,_bg(sp)
        j 4f

3:      sw t0,_fg(sp)
        sw t1,_bg(sp)
4:
        mv a0,s10
        addi a1,sp,_args
        call font_write_glyph

        add s4,s4,s6
        j 2b

2:      add s1,s1,s3
        j 1b

1:      restore
        ret

