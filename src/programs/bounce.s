bounce:
    save dn=0xb
_w=_d0
_a=_d1
_s=_d2
_d=_d3

_x=_d4
_y=_d5

_keyboard=_d6
_display=_d7

_res_x=_d8
_res_y=_d9

_time = _d10

    li a0,0x0
    call display_open
    sd a0,_display(sp)
    li a0,0x0
    call keyboard_open
    sd a0,_keyboard(sp)

    ld a0,_display(sp)
    call display_get_resolution
    sd a0,_res_x(sp)
    sd a1,_res_y(sp)

    mul a0,a0,a1
    slli a0,a0,0x2
    mv s11,a0
    call malloc
    li a1,0xFF
    mv a2,s11
    call memset
    mv s11,a0
    mv a1,a0
    ld a0,_display(sp)
    call display_write_buffer
    mv a0,s11
    call free

    sd zero,_w(sp)
    sd zero,_a(sp)
    sd zero,_s(sp)
    sd zero,_d(sp)

    sd zero,_x(sp)
    sd zero,_y(sp)

    li t0,mtime
    ld t0,(t0)
    li t1,mtime_64hz
    add t0,t0,t1
    sd t0,_time(sp)


    j bounce_loop


.macro bounce_process_events
    
    ld a0,_keyboard(sp)
    call keyboard_pull_event
    li t0,-EAGAIN
    beq a0,t0,9f
    break_on_error
    j 4f

1:  ld a0,_keyboard(sp)
    call keyboard_pull_event
    li t0,-EAGAIN
    beq a0,t0,8f
    break_on_error
    
4:  li t1,0xFFFF
    and t0,a0,t1

    beqz t0,1b

    li t1,0x1
    bne t0,t1,2f

    srli t0,a0,0x10
    li t1,0xFFFF
    and t0,t0,t1

    srli t1,a0,0x20
    li t2,0xFFFFFFFF
    and t3,t1,t2
    li t1,0x2
    beq t3,t1,1b

    li t1,32
    bne t0,t1,3f
    sd t3,_d(sp)
    j 1b
3:  li t1,30
    bne t0,t1,3f
    sd t3,_a(sp)
    j 1b
3:  li t1,17
    bne t0,t1,3f
    sd t3,_w(sp)
    j 1b  
3:  li t1,31
    bne t0,t1,3f
    sd t3,_s(sp)
    j 1b
3:  j 1b

2:  ebreak    

8:  li a0,0x0
    j 8f
9:  li a0,0x1
8:

.endm


bounce_loop:

    bounce_process_events
    
1:  

    ld t0,_time(sp)
    li t1,mtime
    ld t1,(t1)
    bgt t0,t1,bounce_loop
    li t2,mtime_64hz
    add t0,t0,t2
    sd t0,_time(sp)
    
    
    
#    ebreak
    ld t0,_x(sp)
    ld t1,_d(sp)
    ld t2,_res_x(sp)
    bge t1,t2,1f
    add t0,t0,t1
1:  ld t1,_a(sp)
    beqz t0,1f
    sub t0,t0,t1
1:  sd t0,_x(sp)

    ld t0,_y(sp)
    ld t1,_s(sp)
    ld t2,_res_y(sp)
    bge t1,t2,1f    
    add t0,t0,t1
1:  ld t1,_w(sp)
    beqz t0,1f
    sub t0,t0,t1
1:  sd t0,_y(sp)

    ld a0,_display(sp)
    la a1,image
    ld a2,_x(sp)
    ld a3,_y(sp)
    lbu a4,image_w
    lbu a5,image_h
    call display_write_sprite
    break_on_error
    j bounce_loop

    restore
