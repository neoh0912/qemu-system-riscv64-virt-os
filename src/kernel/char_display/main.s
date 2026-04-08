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
        ld a0,_a0(sp)
        call display_open
        break_on_error
        sd a0,CHAR_DISPLAY__device_handle(s1)

        ld t0,_a1(sp)
        lwu t1,FONT__w(t0)
        ld t2,_a2(sp)
        sd t2,CHAR_DISPLAY__w(s1)
        mul a1,t1,t2
        lwu t1,FONT_h(t0)
        ld s2,_a3(sp)
        sd s2,CHAR_DISPLAY__h(s1)
        mul a2,t1,s2
        mul s2,s2,t2
        
        call display_set_resolution

        ld t0,_a1(sp)
        sd t0,CHAR_DISPLAY__font(s1)

        sw zero,CHAR_DISPLAY__state__cursor__x(s1)
        sw zero,CHAR_DISPLAY__state__cursor__y(s1)

        li t0,CHAR_DISPLAY_DEFAULT_FG
        sw t0,CHAR_DISPLAY__state__fg(s1)
        li t0,CHAR_DISPLAY_DEFAULT_BG
        sw t0,CHAR_DISPLAY__state__bg(s1)

        li t0,0x4
        sb t0,CHAR_DISPLAY__state__tab_size(s1)

        sb zero,CHAR_DISPLAY__state__ansi__video(s1)

        slli s3,s2,0x1
        mv a0,s3
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__glyph_buffer
        li a1,0x0
        mv a2,s3
        call memset

        slli s3,s2,0x2
        mv a0,s3
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__fg_buffer
        li a1,0x0
        mv a2,s3
        call memset

        mv a0,s3
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__bg_buffer
        li a1,0x0
        mv a2,s3
        call memset

        mv a0,s2
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,CHAR_DISPLAY__attribute_buffer
        li a1,0x0
        mv a2,s2
        call memset

        mv a0,s1

        restore
        ret
