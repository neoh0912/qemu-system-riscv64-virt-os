sizeof_sprite = 0x10

.macro  unrolled_cpy_sprite
_w = 0x20
res_x = 0x10
        ld t2,_w(sp)
        mv t1,t0
2:      ld t6,0x00(a1)
        sd t6,0x00(t1)
        ld t6,0x08(a1)
        sd t6,0x08(t1)
        ld t6,0x10(a1)
        sd t6,0x10(t1)
        ld t6,0x18(a1)
        sd t6,0x18(t1)
        ld t6,0x20(a1)
        sd t6,0x20(t1)
        ld t6,0x28(a1)
        sd t6,0x28(t1)
        ld t6,0x30(a1)
        sd t6,0x30(t1)
        ld t6,0x38(a1)
        sd t6,0x38(t1)

        addi a1,a1,0x40
        addi t1,t1,0x40
        addi t2,t2,-1
        bnez t2,2b
        add t0,t0,t4
.endm        


bochs_write_sprite:
#[ci [ device, surface: *void, x,y,w,h]
fb = 0x0
res_x = 0x10
res_y = 0x14
        save an=6
_device = _a0
_surface = _a1
_x = _a2
_y = _a3
_w = _a4
_h = _a5
        
        sd a0,_device(sp)
        sd a1,_surface(sp)
        sd a2,_x(sp)
        sd a3,_y(sp)
        sd a4,_w(sp)
        sd a5,_h(sp)

        ld t0,fb(a0)
        lwu t1,res_x(a0)
        mul t1,t1,a3
        add t1,t1,a2
        slli t1,t1,0x2
        add t0,t0,t1
        lwu t4,res_x(a0)
        slli t4,t4,0x2

        ld t5,_h(sp)

1:      unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite
        unrolled_cpy_sprite

        addi t5,t5,-1
        bnez t5,1b
        
        restore
        ret
