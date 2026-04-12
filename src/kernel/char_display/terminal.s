char_display_write:
#[ci [ char_display, string, max_length ]
        save an=3,sn=7

        call char_display_remove_cursor

        li s1,0x0
        mv s2,a2
        mv s3,a1

1:      bge s1,s2,1f

        lbu t0,(s3)
        beqz t0,1f
        addi s3,s3,0x1

        mv s4,t0
        mv s5,t0

        li t0,0x7F
        ble s4,t0,2f

        li t0,0xF0
        blt s4,t0,3f

        andn s5,s5,t0
        li t1,0x3
        j 4f

3:      li t0,0xE0
        blt s4,t0,3f

        andn s5,s5,t0
        li t1,0x2
        j 4f

3:      li t0,0xC0
        andn s5,s5,t0
        li t1,0x1

4:      lbu t0,(s3)
        addi s3,s3,0x1
        slli s4,s4,0x8
        or s4,s4,t0
        slli s5,s5,0x6
        and t0,t0,0x80-1
        or s5,s5,t0
        addi t1,t1,-1
        bgtz t1,4b

        li t0,0x9F
        ble s5,t0,2f

        mv a1,s4
        call char_display_write_utf8
        j 1b

2:      addi a0,a0,CHAR_DISPLAY__parser
        mv a1,s5
        call char_display_parser_next

        mv s6,a1
        mv a1,a0
        ld a0,_a0(sp)
        mv a2,s5
        mv a3,s4
        call char_display_handle_action
        ld a0,_a0(sp)
        mv a1,s6
        mv a2,s5
        mv a3,s4
        call char_display_handle_action
        j 1b
        
1:      call char_display_add_cursor

        ld a0,_a0(sp)
        call char_display_flush

9:      restore
        ret

char_display_remove_cursor:
#[ci [ self ]
        save

        lwu t0,CHAR_DISPLAY__state__cursor__y(a0)
        lwu t1,CHAR_DISPLAY__w(a0)
        mul t0,t0,t1
        lwu t1,CHAR_DISPLAY__state__cursor__x(a0)
        add t0,t0,t1

        ld t1,CHAR_DISPLAY__attribute_buffer(a0)
        add t0,t0,t1

        lbu t1,(t0)

        li t2,CURSOR_FLAG
        andn t1,t1,t2
        sb t1,(t0)
        
        restore
        ret

char_display_add_cursor:
#[ci [ self ]
        save

        lwu t0,CHAR_DISPLAY__state__cursor__y(a0)
        lwu t1,CHAR_DISPLAY__w(a0)
        mul t0,t0,t1
        lwu t1,CHAR_DISPLAY__state__cursor__x(a0)
        add t0,t0,t1

        ld t1,CHAR_DISPLAY__attribute_buffer(a0)
        add t0,t0,t1

        lbu t1,(t0)
        ori t1,t1,CURSOR_FLAG
        sb t1,(t0)
        
        restore
        ret


char_display_write_utf8:
#[ci [ self, utf8 ]
        save an=2,sn=3

        lwu t0,CHAR_DISPLAY__state__cursor__y(a0)
        lwu t1,CHAR_DISPLAY__w(a0)
        mul t0,t0,t1
        lwu t1,CHAR_DISPLAY__state__cursor__x(a0)
        add s1,t0,t1

        lwu s2,CHAR_DISPLAY__state__fg(a0)
        lwu s3,CHAR_DISPLAY__state__bg(a0)

        slli t0,s1,0x2
        ld t1,CHAR_DISPLAY__fg_buffer(a0)
        add t1,t1,t0
        
        ld t2,CHAR_DISPLAY__bg_buffer(a0)
        add t2,t2,t0


        ld t0,CHAR_DISPLAY__state__cursor__style(a0)
        bexti t3,t0,STYLE_invisible
        beqz t3,1f

        mv s2,s3
1:        
        bexti t3,t0,STYLE_inverse

        beqz t3,1f

        sw s3,(t1)
        sw s2,(t2)
        j 2f
1:
        sw s2,(t1)
        sw s3,(t2)
2:        
        slli s1,s1,0x1
        ld t1,CHAR_DISPLAY__glyph_buffer(a0)
        add s1,s1,t1

        ld a0,CHAR_DISPLAY__font(a0)
        call font_get_glyph
        sh a0,(s1)

        ld a0,_a0(sp)
        li a1,0x1
        call char_display_move_cursor_right

        restore
        ret

char_display_move_cursor_right:
#[ci [ self, x ]
        lwu t0,CHAR_DISPLAY__state__cursor__x(a0)
        add t0,t0,a1
        max t0,t0,zero
        lwu t1,CHAR_DISPLAY__w(a0)
        addi t1,t1,-1
        min t0,t0,t1
        sw t0,CHAR_DISPLAY__state__cursor__x(a0)
        ret

char_display_move_cursor_left:
#[ci [ self, x ]
        lwu t0,CHAR_DISPLAY__state__cursor__x(a0)
        sub t0,t0,a1
        max t0,t0,zero
        lwu t1,CHAR_DISPLAY__w(a0)
        addi t1,t1,-1
        min t0,t0,t1
        sw t0,CHAR_DISPLAY__state__cursor__x(a0)
        ret


char_display_move_cursor_down:
#[ci [ self, y ]
        lwu t0,CHAR_DISPLAY__state__cursor__y(a0)
        add t0,t0,a1
        max t0,t0,zero
        lwu t1,CHAR_DISPLAY__h(a0)
        addi t1,t1,-1
        min t0,t0,t1
        sw t0,CHAR_DISPLAY__state__cursor__y(a0)
        ret


char_display_move_cursor_up:
#[ci [ self, y ]
        lwu t0,CHAR_DISPLAY__state__cursor__y(a0)
        sub t0,t0,a1
        max t0,t0,zero
        lwu t1,CHAR_DISPLAY__h(a0)
        addi t1,t1,-1
        min t0,t0,t1
        sw t0,CHAR_DISPLAY__state__cursor__y(a0)
        ret


char_display_handle_action:
#[ci [ self, action, utf8, ch ]
        save

        li t0,ACTION__none
        beq a1,t0,2f

        li t0,ACTION__print
        bne a1,t0,1f

        mv a1,a2
        call char_display_write_utf8
        j 2f

1:      li t0,ACTION__execute
        bne a1,t0,1f

        mv a1,a3
        call char_display_execute
        j 2f

1:      li t0,ACTION__csi_dispatch
        bne a1,t0,1f

        mv a1,a3
        addi a2,a0,(CHAR_DISPLAY__parser + PARSER__intermediates)
        addi a3,a0,(CHAR_DISPLAY__parser + PARSER__params)
        addi a4,a0,(CHAR_DISPLAY__parser+PARSER__params_sep)
        call char_display_csi_dispatch
        j 2f

1:      li t0,ACTION__esc_dispatch
        bne a1,t0,1f

        mv a1,a3
        addi a2,a0,(CHAR_DISPLAY__parser + PARSER__intermediates)
        call char_display_esc_dispatch
        j 2f

1:      

2:      restore
        ret

char_display_execute:
#[ci [ self, ch ]
        save

        li t0,'\b'
        bne a1,t0,1f

        li a1,1
        call char_display_move_cursor_left
        j 9f

1:      li t0,'\n'
        bne a1,t0,1f

        call char_display_handle_newline
        j 9f

1:      li t0,'\r'
        bne a1,t0,1f
        call char_display_handle_carriage_return
        j 9f

1:      li t0,'\t'
        bne a1,t0,1f
        call char_display_handle_tab
        j 9f

1:      li t0,0x7F
        ble a1,t0,1f

        li a2,0x0
        addi a1,a1,-0x40
        call char_display_esc_dispatch
        j 9f

1:      ebreak

9:      restore
        ret

char_display_handle_newline:
#[ci [ self ]
        li a1,1
        tail char_display_move_cursor_down

char_display_handle_carriage_return:
#[ci [ self ]
        sw zero,CHAR_DISPLAY__state__cursor__x(a0)
        ret

char_display_handle_tab:
#[ci [ self ]
        ret

char_display_parser_next:
#[ci [ self, ch ]
        save an=2,sn=4

        la t0,CHAR_DISPLAY_PARSER_STATE_TABLE
        li t1,sizeof_PARSER_STATE
        mul t1,a1,t1
        lbu s4,PARSER__state(a0)
        add t1,t1,s4
        slli t1,t1,0x1
        add t0,t0,t1

        mv a2,a1
        
        lbu s1,0x0(t0)
        lbu a1,0x1(t0)

        call char_display_parser_do_action
        mv s2,a0

        li s3,0x0

        ld a0,_a0(sp)
        mv t0,s4
        mv s4,a0

        beq t0,s1,1f

        li t0,PARSER_STATE__escape
        beq s1,t0,2f
        li t0,PARSER_STATE__csi_entry
        bne s1,t0,1f

2:      call char_display_parser_clear
        
1:      sb s1,PARSER__state(s4)
        mv a0,s2
        mv a1,s3

        restore
        ret

char_display_parser_do_action:
#[ci [ self, action, ch ]
        save

        li t0,TRANSITION_ACTION__print
        bne a1,t0,1f

        li a0,ACTION__print
        j 9f
        
1:      li t0,TRANSITION_ACTION__execute
        bne a1,t0,1f

        li a0,ACTION__execute
        j 9f

1:      li t0,TRANSITION_ACTION__collect
        bne a1,t0,1f

        mv a1,a2
        call char_display_parser_collect
        j char_display_parser_do_action__none

1:      li t0,TRANSITION_ACTION__param
        bne a1,t0,1f

        li t0,';'
        beq a2,t0,2f
        li t0,':'
        bne a2,t0,3f

2:      lbu t0,PARSER__params_idx(a0)
        li t1,MAX_PARAMS
        bge t0,t1,char_display_parser_do_action__none

        slli t1,t0,0x1
        add t1,a0,t1
        lhu t2,PARSER__param_acc(a0)
        sh zero,PARSER__param_acc(a0)
        sb zero,PARSER__param_acc_idx(a0)
        sh t2,PARSER__params(t1)

        li t1,':'
        bne a2,t1,4f

        srli t1,t0,0x3
        add t1,a0,t1
        lbu t2,PARSER__params_sep(t1)
        li t3,0x4
        remu t3,t0,t3

        bset t2,t2,t3
        sb t2,PARSER__params_sep(t1)

4:      addi t0,t0,0x1
        j char_display_parser_do_action__none

3:      lhu t0,PARSER__param_acc(a0)
        li t1,10
        mul t0,t0,t1

        addi t1,a2,-'0'
        or t0,t0,t1

        sh t0,PARSER__param_acc(a0)

        lbu t0,PARSER__param_acc_idx(a0)
        addi t0,t0,0x1
        sb t0,PARSER__param_acc_idx(a0)
        j char_display_parser_do_action__none
        
1:      li t0,TRANSITION_ACTION__csi_dispatch
        bne a1,t0,1f

        lbu t0,PARSER__params_idx(a0)
        li t1,MAX_PARAMS
        
        bge t0,t1,char_display_parser_do_action__none

        lbu t1,PARSER__param_acc_idx(a0)
        beqz t1,2f

        slli t1,t0,0x1
        addi t0,t0,0x1
        sb t0,PARSER__params_idx(a0)
        
        add t0,a0,t1
        lhu t1,PARSER__param_acc(a0)
        sh t1,PARSER__params(t0)

2:      li t1,'m'
        beq a2,t1,2f

        li t2,0x0
        li t3,sizeof_PARAM_SEP

        mv t0,a0        

4:      lbu t4,PARSER__params_sep(t0)
        bnez t4,3f

        addi t0,t0,0x1
        addi t2,t2,0x1
        blt t2,t3,4b
        j 2f

3:      j char_display_parser_do_action__none

2:      li a0,ACTION__csi_dispatch
        j 9f



1:      li t0,TRANSITION_ACTION__esc_dispatch
        bne a1,t0,1f  

        li a0,ACTION__esc_dispatch
        j 9f

1:      li t0,TRANSITION_ACTION__none
        beq a1,t0,char_display_parser_do_action__none
        li t0,TRANSITION_ACTION__ignore
        beq a1,t0,char_display_parser_do_action__none


char_display_parser_do_action__none:
        li a0,ACTION__none
        j 9f

9:      restore
        ret

char_display_parser_collect:
#[ci [ self,ch ]

        lbu t0,PARSER__intermediates_idx(a0)
        li t1,MAX_INTERMEDIATE
        bge t0,t1,9f

        add t1,a0,t0
        sb a1,PARSER__intermediates(t1)

9:      ret

char_display_parser_clear:
#[ci [ self ]
        save
        
        sb zero,PARSER__intermediates_idx(a0)
        sb zero,PARSER__params_idx(a0)
        sh zero,PARSER__param_acc(a0)
        sb zero,PARSER__param_acc_idx(a0)

        addi a0,a0,PARSER__params_sep
        li a1,0x0
        li a2,sizeof_PARAM_SEP
        call memset

        restore
        ret

char_display_esc_dispatch:
        
        ret
        
char_display_csi_dispatch:
#[ci [ self, ch, intermediates, params, params_sep ]
        save an=5,sn=3

        li t0,'m'
        bne a1,t0,1f

#[ri _                                                               

        lbu s2,(CHAR_DISPLAY__parser+PARSER__params_idx)(a0)
        li s1,0x0
        addi s3,a0,(CHAR_DISPLAY__parser+PARSER__params)

2:      bge s1,s2,2f

        lhu a1,(s3)
        addi s3,s3,0x2

        call char_display_set_attribute

        addi s1,s1,0x1
        j 2b

2:      j 9f

1:      li t0,'H'
        bne a1,t0,1f

1:      li t0,'K'
        bne a1,t0,1f

1:      li t0,'A'
        bne a1,t0,1f

        lbu t0,(CHAR_DISPLAY__parser+PARSER__params_idx)(a0)
        li t1,0x0
        bne t0,t1,2f

        li a1,1
        j 3f
        
2:      li t1,0x1
        bne t0,t1,2f

        lhu a1,(CHAR_DISPLAY__parser+PARSER__params)(a0)
        j 3f

2:      ebreak
        j 9f

3:      call char_display_move_cursor_up
        j 9f

1:      li t0,'C'
        bne a1,t0,1f

        lbu t0,(CHAR_DISPLAY__parser+PARSER__params_idx)(a0)
        li t1,0x0
        bne t0,t1,2f

        li a1,1
        j 3f
        
2:      li t1,0x1
        bne t0,t1,2f

        lhu a1,(CHAR_DISPLAY__parser+PARSER__params)(a0)
        j 3f

2:      ebreak
        j 9f

3:      call char_display_move_cursor_right
        j 9f


1:      li t0,'X'
        bne a1,t0,1f

1:      li t0,'l'
        bne a1,t0,1f

1:      li t0,'h'
        bne a1,t0,1f

1:      li t0,'r'
        bne a1,t0,1f

1:      

9:      restore
        ret

#[ri [############################]
#[ri [#  TODO: MAKE VECTOR JUMP  #]
#[ri [############################]

char_display_set_attribute:
#[ci [ self, attribute ]
        save

        li t0,7
        bne a1,t0,1f

        ld t0,CHAR_DISPLAY__state__cursor__style(a0)
        bseti t0,t0,STYLE_inverse
        sd t0,CHAR_DISPLAY__state__cursor__style(a0)
        j 9f


1:      li t0,8
        bne a1,t0,1f

        ld t0,CHAR_DISPLAY__state__cursor__style(a0)
        bseti t0,t0,STYLE_invisible
        sd t0,CHAR_DISPLAY__state__cursor__style(a0)
        j 9f


1:      li t0,27
        bne a1,t0,1f

        ld t0,CHAR_DISPLAY__state__cursor__style(a0)
        bclri t0,t0,STYLE_inverse
        sd t0,CHAR_DISPLAY__state__cursor__style(a0)
        j 9f


1:      li t0,28
        bne a1,t0,1f

        ld t0,CHAR_DISPLAY__state__cursor__style(a0)
        bclri t0,t0,STYLE_invisible
        sd t0,CHAR_DISPLAY__state__cursor__style(a0)
        j 9f


1:      li t0,30
        blt a1,t0,1f
        li t0,37
        bgt a1,t0,1f

        

        

1:      li t0,0x7
        bne a1,t0,1f

1:      li t0,0x7
        bne a1,t0,1f

1:      li t0,0x7
        bne a1,t0,1f

1:      


9:      restore
        ret

