.include "const/font.s"
.include "const/char_display.s"

CHAR_DISPLAY_MAX_CSI_PARAMS = 0x200

.macro char_display_write_tab
        lbu t1,char_display_state_cursor__x(a0)
        lbu t2,char_display_state__tab_size(a0)

        remu t3,t1,t2
        sub t1,t1,t3
        add t1,t1,t2

        sb t1,char_display_state_cursor__x(a0)

        li a1,0x0
        li a2,0x0
        call char_display_move_cursor
.endm

.macro char_display_push_parameter_to_csi_stack context
        ld t1,_csi_arg(\context)
        lhu t2,_csi_stack_top(\context)
        addi t3,t2,0x1
        sh t3,_csi_stack_top(\context)
        slli t2,t2,0x3
        addi t2,t2,_csi_stack
        add t2,t2,\context
        sd t1,(t2)
        lbu t1,_csi_arg_is_default(\context)
        beqz t1,.L_push_\@_end
        
        not t1,zero
        sd t1,(t2)
        
.L_push_\@_end:        
.endm

char_display_write:
#[ci [ char_display, *string, max_lenght ]
        save an=3,sn=3,dn=201,wn=1,hn=1,bn=4 # dn=1+CHAR_DISPLAY_MAX_CSI_PARAMS
_in_esc = _b0
_in_csi = _b1
_bytes_left = _b2
_multibyte = _w0
_csi_stack_top = _h0
_csi_stack = _d1
_csi_arg = _d0
_csi_arg_is_default = _b3

        sb zero,_b0(sp)
        sb zero,_b1(sp)
        sb zero,_b2(sp)
        sb zero,_b3(sp)
        sh zero,_h0(sp)
        sw zero,_w0(sp)
        sd zero,_d0(sp)

        mv s1,a1
        mv s3,a2
        li s2,0x0
        
1:      lbu t0,(s1)
        beqz t0,1f
        
        andi t1,t0,0x80
        bnez t1,2f

   # ascii

        lbu t1,_in_esc(sp)
        beqz t1,3f

        # in escape sequence
        lbu t1,_in_csi(sp)
        bnez t1,4f

            # not in control sequence

        li t1,'['
        bne t0,t1,5f

        li t0,0x1
        sb t0,_in_csi(sp)
        j 9f

5:      ebreak
        j 1f


4:          # in control sequence

        li t1,0x3F
        bgt t0,t1,5f

        li t1,';'
        bne t0,t1,7f

        char_display_push_parameter_to_csi_stack sp
        
        sd zero,_csi_arg(sp)
        li t1,0x1
        sb t1,_csi_arg_is_default(sp)
        j 9f



7:      ld t1,_csi_arg(sp)
        addi t0,t0,-0x30
        li t2,10
        mul t1,t1,t2
        add t1,t1,t0
        sd t1,_csi_arg(sp)
        sb zero,_csi_arg_is_default(sp)
        j 9f


5:      li t1,0x7E
        bgt t0,t1,5f

        li t1,'A'
        bne t0,t1,6f

        li a1,0x0
        ld t1,_csi_arg(sp)
        lbu t0,_csi_arg_is_default(sp)
        beqz t0,8f
        li t1,0x1
8:      sub a2,zero,t1
  
        call char_display_move_cursor
        j 7f

6:      li t1,'B'
        bne t0,t1,6f

        li a1,0x0
        ld a2,_csi_arg(sp)
        lbu t0,_csi_arg_is_default(sp)
        beqz t0,8f
        li a2,0x1
8:      call char_display_move_cursor
        j 7f


6:      li t1,'C'
        bne t0,t1,6f

        li a2,0x0
        ld a1,_csi_arg(sp)
        lbu t0,_csi_arg_is_default(sp)
        beqz t0,8f
        li a1,0x1
8:      call char_display_move_cursor
        j 7f

6:      li t1,'D'
        bne t0,t1,6f

        li a2,0x0
        ld t1,_csi_arg(sp)
        lbu t0,_csi_arg_is_default(sp)
        beqz t0,8f
        li t1,0x1
8:      sub a1,zero,t1
  
        call char_display_move_cursor
        j 7f

6:      li t1,'E'
        bne t0,t1,6f

        li a1,0x0
        ld a2,_csi_arg(sp)
        lbu t0,_csi_arg_is_default(sp)
        beqz t0,8f
        li a2,0x1
8:      call char_display_move_cursor
        sb zero,char_display_state_cursor__x(a0)
        j 7f

6:      li t1,'F'
        bne t0,t1,6f

        li a1,0x0
        ld t1,_csi_arg(sp)
        lbu t0,_csi_arg_is_default(sp)
        beqz t0,8f
        li t1,0x1
8:      sub a2,zero,t1
        call char_display_move_cursor
        sb zero,char_display_state_cursor__x(a0)
        j 7f


6:      li t1,'m'
        bne t0,t1,6f

        mv a1,sp
        call char_display_process_sgr

        j 7f


6:

  



7:      sh zero,_csi_stack_top(sp)
        sd zero,_csi_arg(sp)
        sb zero,_in_esc(sp)
        sb zero,_in_csi(sp)
        li t1,0x1
        sb t1,_csi_arg_is_default(sp)

5:      j 9f


3:      # not in escape sequence

        li t1,0x1F
        bgt t0,t1,3f

        li t1,0x8
        bne t0,t1,4f

        li a1,-1
        li a2,0x0
        call char_display_move_cursor
        j 9f

4:      li t1,0x9
        bne t0,t1,4f
        char_display_write_tab
        j 9f

4:      li t1,0xA
        bne t0,t1,4f

        li a1,0x0
        li a2,1
        call char_display_move_cursor
        j 9f

4:      li t1,0xD
        bne t0,t1,4f
        sb zero,char_display_state_cursor__x(a0)
        j 9f
        
4:      li t1,0x1B
        bne t0,t1,4f

        li t0,0x1
        sb t0,_in_esc(sp)
        j 9f

4:      j 9f
        
3:      mv a1,t0
        call char_display_write_char
        j 9f

2:  # Unicode

        xori t2,t0,0xFF
        clz t2,t2
        addi t2,t2,-56

        lbu t1,_bytes_left(sp)
        bnez t1,4f
                
        sb t2,_bytes_left(sp)
        mv t1,t2

        li t2,0x2
        bne t1,t2,5f
        li t1,0xe0
        andn t1,t0,t1
        sw t1,_multibyte(sp)
        j 3f

5:      li t2,0x3
        bne t1,t2,5f
        li t1,0xF0
        andn t1,t0,t1
        sw t1,_multibyte(sp)
        j 3f

5:      li t2,0x4
        bne t1,t2,5f
        li t1,0xF8
        andn t1,t0,t1
        sw t1,_multibyte(sp)
        j 3f

5:


4:      lwu t1,_multibyte(sp)
        slli t1,t1,0x6
        li t2,0xc0
        andn t2,t0,t2
        or t1,t1,t2
        sw t1,_multibyte(sp)
        j 3f


3:      lbu t0,_bytes_left(sp)
        addi t0,t0,-1
        sb t0,_bytes_left(sp)

        bnez t0,9f

        lwu a1,_multibyte(sp)
        mv a2,sp
        call char_display_process_multibyte
        j 9f


    # end   

9:      addi s1,s1,0x1
        addi s2,s2,0x1
        blt s2,s3,1b

1:      call char_display_flush

        restore
        ret

char_display_process_multibyte:
#[ci [ char_display, char, context ]
        save an=3
        
        li t0,0x9F
        bgt a1,t0,1f

        li t0,0x9B
        bne a1,t0,2f

        li t0,0x1
        sb t0,_in_csi(a2)
        j 9f

2:      
1:      call char_display_write_char

9:      restore
        ret

char_display_process_sgr:
#[ci [ char_display, context ]
        save an=2,sn=4

        char_display_push_parameter_to_csi_stack a1
  
        sd zero,_csi_arg(a1)
        li t1,0x1

        li s1,0x0
        lhu s2,_csi_stack_top(a1)

        addi s3,a1,_csi_stack

1:      ld t0,(s3)

        li t1,0x0
        bne t0,t1,2f

        li t0,CHAR_DISPLAY_DEFAULT_FG
        sw t0,char_display_state__fg(a0)
        li t0,CHAR_DISPLAY_DEFAULT_BG
        sw t0,char_display_state__bg(a0)

        sb zero,char_display_state_ansi__video(a0)
        
        j 3f

2:      li t1,0x7
        bne t0,t1,2f
        lbu t0,char_display_state_ansi__video(a0)
        ori t0,t0,ANSI_INVERT
        sb t0,char_display_state_ansi__video(a0)
        j 3f

2:      li t1,27
        bne t0,t1,2f
        lbu t0,char_display_state_ansi__video(a0)
        li t1,ANSI_INVERT
        andn t0,t0,t1
        sb t0,char_display_state_ansi__video(a0)
        j 3f

        
2:      li t1,37
        bgt t0,t1,2f
        li t1,30
        blt t0,t1,2f

        addi t0,t0,-30
        slli t0,t0,0x2
        la t1,CHAR_DISPLAY_DEFAULT_COLOR_PALETTE
        add t0,t0,t1
        lwu t0,(t0)
        sw t0,char_display_state__fg(a0)
        j 3f
        
2: 

3:      addi s3,s3,0x8
        addi s1,s1,0x1
        blt s1,s2,1b


        restore
        ret

char_display_write_char:
#[ci [ char_display, char ]
        save an=2,sn=3

        lbu s1,char_display_state_cursor__y(a0)
        lwu s2,char_display__w(a0)
        mul t0,s1,s2
        lbu s3,char_display_state_cursor__x(a0)
        add t0,t0,s3
        slli t0,t0,0x1

        ld t1,char_display__char_buffer(a0)
        add t1,t0,t1
        sh a1,(t1)
        
        slli t0,t0,0x1

        lbu t6,char_display_state_ansi__video(a0)
        andi t5,t6,ANSI_INVERT
        bnez t5,1f

        ld t3,char_display__fg_buffer(a0)
        ld t4,char_display__bg_buffer(a0)
        j 2f
        
1:      ld t4,char_display__fg_buffer(a0)
        ld t3,char_display__bg_buffer(a0)
        
2:      add t1,t0,t3
        lwu t2,char_display_state__fg(a0)
        sw t2,(t1)


        add t1,t0,t4
        lwu t2,char_display_state__bg(a0)
        sw t2,(t1)

        li a1,0x1
        li a2,0x0
        call char_display_move_cursor

        restore
        ret

char_display_move_cursor:
#[ci [ char_display, x,y ]
        save an=3

        lbu t0,char_display_state_cursor__x(a0)
        lbu t1,char_display_state_cursor__y(a0)
        lwu t2,char_display__w(a0)
        lwu t3,char_display__h(a0)

        add t0,t0,a1
        add t1,t1,a2

        blt t0,t2,1f

        li t0,0x0
        addi t1,t1,0x1
        
1:      blt t1,t3,1f

        addi t1,t3,-1

1:      sb t0,char_display_state_cursor__x(a0)
        sb t1,char_display_state_cursor__y(a0)

        restore
        ret

char_display_set_tab_size:
#[ci [ char_display, size ]
        sb a1,char_display_state__tab_size(a0)
        ret
