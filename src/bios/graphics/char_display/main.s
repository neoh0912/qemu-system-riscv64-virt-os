.include "const/font.s"
.include "const/char_display.s"

char_display_create:
#[ci [ device_id ]
        save an=1,sn=1

        li a0,sizeof_CHAR_DISPLAY
        call malloc
        bnez a0,1f
        ebreak

1:      mv s1,a0
        ld a0,_a0(sp)
        call display_open
        break_on_error

        sd a0,char_display__device_handle(s1)
        sd zero,char_display__font(s1)

        mv a0,s1
        restore
        ret

char_display_get_char_buffer:
#[ci [ char_display ]
        ld a0,char_display__char_buffer(a0)
        ret

char_display_get_fg_buffer:
#[ci [ char_display ]
        ld a0,char_display__fg_buffer(a0)
        ret

char_display_get_bg_buffer:
#[ci [ char_display ]
        ld a0,char_display__bg_buffer(a0)
        ret

char_display_flush:
#[ci [ char_display ]
        save an=1,sn=11,dn=5
_fb = _d0

        ld a0,char_display__device_handle(a0)
        call display_get_frame_buffer
        sd a0,_fb(sp)

        ld a0,_a0(sp)
        ld a0,char_display__device_handle(a0)
        call display_get_resolution

        sd a0,_d1(sp)
        sd a1,_d2(sp)

        ld t0,_a0(sp)
        ld t1,char_display__font(t0)
        lwu s7,font__w(t1)
        lwu s8,font__h(t1)
        ld s9,char_display__char_buffer(t0)
        ld s10,char_display__fg_buffer(t0)
        ld s11,char_display__bg_buffer(t0)
        lwu s5,char_display__w(t0)
        lwu s6,char_display__h(t0)

        li s1,0x0

1:      li s2,0x0

2:      mul t0,s2,s7
        sd t0,_d3(sp)
        mul t0,s1,s8
        sd t0,_d4(sp)

        lhu a2,(s9)
        lwu a3,(s10)
        lwu a4,(s11)

        ld t0,_a0(sp)
        ld a0,char_display__font(t0)
        addi a1,sp,_d0
        call graphics_font_write

        addi s9,s9,0x2
        addi s10,s10,0x4
        addi s11,s11,0x4
        addi s2,s2,0x1
        addi t0,s2,0x1
        blt s2,s5,2b

        addi s1,s1,0x1
        blt s1,s6,1b

        ld t0,_a0(sp)

        lbu s1,char_display_state_cursor__y(t0)
        lbu s2,char_display_state_cursor__x(t0)

        ld s9,char_display__char_buffer(t0)
        ld s10,char_display__fg_buffer(t0)
        ld s11,char_display__bg_buffer(t0)

        mul t0,s2,s7
        sd t0,_d3(sp)
        mul t0,s1,s8
        sd t0,_d4(sp)

        mul t0,s2,s5
        add t0,t0,s1
        slli t0,t0,0x1
        add s9,s9,t0
        slli t0,t0,0x1
        add s10,s10,t0
        add s11,s11,t0

        lhu a2,(s9)
        lwu a4,(s10)
        lwu a3,(s11)

        ld t0,_a0(sp)
        ld a0,char_display__font(t0)
        addi a1,sp,_d0
        call graphics_font_write

        restore
        ret

char_display_init:
#[ci [ char_display, font, w, h ]
        save an=4,sn=1

        ld t0,_a0(sp)

        li t1,0xFFFFFFFF
        sw t1,char_display_state__fg(t0)
        li t1,0x2
        sb t1,char_display_state__tab_size(t0)
        sw zero,char_display_state__bg(t0)

        sh zero,char_display_state_cursor__x(t0)

        ld t1,_a2(sp)
        sw t1,char_display__w(t0)
        ld t1,_a3(sp)
        sw t1,char_display__h(t0)
        ld t1,_a1(sp)
        sd t1,char_display__font(t0)

        ld a0,char_display__device_handle(t0)
        lwu a1,font__w(t1)
        lwu a2,font__h(t1)
        ld t0,_a2(sp)
        mul a1,a1,t0
        ld t0,_a3(sp)
        mul a2,a2,t0
        call display_set_resolution

        ld t0,_a2(sp)
        ld t1,_a3(sp)
        mul a0,t0,t1
        slli a0,a0,0x1
        mv s1,a0
        
        call malloc
        bnez a0,1f
        ebreak

1:      ld t0,_a0(sp)
        sd a0,char_display__char_buffer(t0)

        add t0,a0,s1
        li t1,0x20
1:      sh t1,(a0)

        addi a0,a0,0x2
        blt a0,t0,1b
        

        slli s1,s1,0x1
        mv a0,s1
        call malloc
        bnez a0,1f
        ebreak

1:      ld t0,_a0(sp)
        sd a0,char_display__fg_buffer(t0)

        li a1,0xFF
        mv a2,s1
        call memset

        mv a0,s1
        call malloc
        bnez a0,1f
        ebreak

1:      ld t0,_a0(sp)
        sd a0,char_display__bg_buffer(t0)
        li a1,0x00
        mv a2,s1
        call memset
        
        restore
        ret
