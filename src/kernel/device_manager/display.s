.include "const/device_manager/device_struct.s"

display_open: #[ci [ descriptor ]
#[ci [ id ]
display = 0x0079616C70736964
        mv a1,a0
        li a0,display
        tail device_manager_open_device

display_close:
 #[ci [ descriptor ]
        tail device_manager_close_device

display_set_resolution:
#[ci [ device_descriptor, res_x, res_y ]
_id = 0x0
_res_x = 0x8
_res_y = 0x10
        salloc 0
        sald 3
        sd a0,_id(sp)
        sd a1,_res_x(sp)
        sd a2,_res_y(sp)

        device_manager_get_device_of_dd

        bnez a0,1f
        li a0,-ENODEV
        j 9f

        
1:      ld t0,device__device_type(a0)
        li t1,display
        beq t0,t1,1f
        li a0,-ENOTTY
        j 9f

        
1:      ld t0,device__ioctl(a0)
        ld a0,device__device(a0)
        li a1,0x1
        ld a2,_res_x(sp)
        ld a3,_res_y(sp)
        jalr ra,t0,0x0
        
9:      sfree
        ret    

display_get_resolution:
#[ci [ device_descriptor ]
_id = 0x0
        salloc 0
        sald 3
        sd a0,_id(sp)

        device_manager_get_device_of_dd

        bnez a0,1f
        li a0,-ENODEV
        j 9f

        
1:      ld t0,device__device_type(a0)
        li t1,display
        beq t0,t1,1f
        li a0,-ENOTTY
        j 9f

        
1:      ld t0,device__ioctl(a0)
        ld a0,device__device(a0)
        li a1,0x0
        jalr ra,t0,0x0
        
9:      sfree
        ret    


display_write_buffer:
#[ci [ device_descriptor, buffer: *void ]
_id = 0x0
_buffer = 0x8
        salloc 0
        sald 2
        sd a0,_id(sp)
        sd a1,_buffer(sp)

        device_manager_get_device_of_dd
        bnez a0,1f
        li a0,-ENODEV
        j 9f
        
1:      ld t0,device__device_type(a0)
        li t1,display
        beq t0,t1,1f
        li a0,-ENOTTY
        j 9f

1:      ld t0,device__write(a0)
        ld a0,device__device(a0)
        li a1,0x0
        ld a2,_buffer(sp)
        jalr ra,t0,0x0
        
9:      sfree
        ret    

display_write_sprite:
#[ci [ device_descriptor, surface: *void, x,y,w,h]
_id = 0x0
_surface = 0x8
_x = 0x10
_y = 0x18
_w = 0x20
_h = 0x28
        salloc 0
        sald 8
        sd a0,_id(sp)
        sd a1,_surface(sp)
        sd a2,_x(sp)
        sd a3,_y(sp)
        sd a4,_w(sp)
        sd a5,_h(sp)

        device_manager_get_device_of_dd
        bnez a0,1f
        li a0,-ENODEV
        j 9f
        
1:      ld t0,device__device_type(a0)
        li t1,display
        beq t0,t1,1f
        li a0,-ENOTTY
        j 9f

1:      ld t0,device__write(a0)
        ld a0,device__device(a0)
        li a1,'s'
        ld a2,_surface(sp)
        ld a3,_x(sp)
        ld a4,_y(sp)
        ld a5,_w(sp)
        ld a6,_h(sp)
        jalr ra,t0,0x0
        
9:      sfree
        ret    

