display_set_resolution:
#[ci [ id, res_x, res_y ]
display = 0x0079616C70736964
_id = 0x0
_res_x = 0x8
_res_y = 0x10
ioctl = 0x28
device = 0x8
        salloc 0
        sald 3
        sd a0,_id(sp)
        sd a1,_res_x(sp)
        sd a2,_res_y(sp)

        li a0,display
        ld a1,_id(sp)
        call device_manager_get_device
        beqz a0,9f

        ld t0,ioctl(a0)
        ld a0,device(a0)
        li a1,0x1
        ld a2,_res_x(sp)
        ld a3,_res_y(sp)
        jalr ra,t0,0x0
        
9:      sfree
        ret    

display_write_buffer:
#[ci [ id, buffer: *void ]
_id = 0x0
_buffer = 0x8
write = 0x20
device = 0x8
        salloc 0
        sald 2
        sd a0,_id(sp)
        sd a1,_buffer(sp)

        li a0,display
        ld a1,_id(sp)
        call device_manager_get_device
        beqz a0,9f

        ld t0,write(a0)
        ld a0,device(a0)
        li a1,0x0
        ld a2,_buffer(sp)
        jalr ra,t0,0x0
        
9:      sfree
        ret    

