.include "const/device_manager/device_struct.s"

keyboard_open: #[ci [ descriptor ]
#[ci [ id ]
keyboard = 0x6472616F6279656B
        mv a1,a0
        li a0,keyboard
        tail device_manager_open_device

keyboard_close:
 #[ci [ descriptor ]
        tail device_manager_close_device


keyboard_pull_event:
#[ci [ device_descriptor ]
        save

        device_manager_get_device_of_dd
        bnez a0,1f
        li a0,-ENODEV
        j 9f
        
1:      ld t0,device__device_type(a0)
        li t1,keyboard
        beq t0,t1,1f
        ebreak
        li a0,-ENOTTY
        j 9f

1:      ld t0,device__read(a0)
        ld a0,device__device(a0)
        li a1,0
        jalr ra,t0,0x0
        
9:      restore
        ret    
