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

display_get_frame_buffer:
 #[ci [ descriptor ]
        save
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
        li a1,0x2
        jalr ra,t0,0x0
        
9:      restore
        ret    

display_set_resolution:
#[ci [ device_descriptor, res_x, res_y ]
        save an=3
_res_x = _a1
_res_y = _a2
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
        
9:      restore
        ret    

display_get_resolution:
#[ci [ device_descriptor ]
        save
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
        
9:      restore
        ret    


display_write_frame_buffer:
#[ci [ device_descriptor, buffer: *void ]
        save an=2
_buffer = _a1

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
        
9:      restore
        ret    

display_write_buffer:
#[ci [ device_descriptor, buffer, x,y,n ]
        save an=5
_buffer = _a1

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
        li a1,0x1
        ld a2,_buffer(sp)
        ld a3,_a2(sp)
        ld a4,_a3(sp)
        ld a5,_a4(sp)
        jalr ra,t0,0x0
        
9:      restore
        ret

display_write_sprite:
#[ci [ device_descriptor, surface: *void, x,y,w,h]
        save an=6
_surface = _a1
_x = _a2
_y = _a3
_w = _a4
_h = _a5

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
        
9:      restore
        ret    

