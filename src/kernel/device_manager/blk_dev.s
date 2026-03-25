.include "const/device_manager/device_struct.s"

blk_dev_open: #[ci [ descriptor ]
#[ci [ id ]
blkdrive = 0x65766972646B6C62
        mv a1,a0
        li a0,blkdrive
        tail device_manager_open_device

blk_dev_close:
 #[ci [ descriptor ]
        tail device_manager_close_device


blk_dev_read:
#[ci [ device_descriptor, sector, buffer ]
        save an=3

        device_manager_get_device_of_dd
        bnez a0,1f
        li a0,-ENODEV
        j 9f

1:      ld t0,device__device_type(a0)
        li t1,blkdrive
        beq t0,t1,1f
        ebreak
        li a0,-ENOTTY
        j 9f

1:      ld t0,device__read(a0)
        ld a0,device__device(a0)
        ld a3,_a2(sp)
        ld a2,_a1(sp)
        li a1,0
       
        jalr ra,t0,0x0
        
9:      restore
        ret    

blk_dev_write:
#[ci [ device_descriptor, sector, buffer ]
        save an=3

        device_manager_get_device_of_dd
        bnez a0,1f
        li a0,-ENODEV
        j 9f

1:      ld t0,device__device_type(a0)
        li t1,blkdrive
        beq t0,t1,1f
        ebreak
        li a0,-ENOTTY
        j 9f

1:      ld t0,device__write(a0)
        ld a0,device__device(a0)
        ld a3,_a2(sp)
        ld a2,_a1(sp)
        li a1,0
       
        jalr ra,t0,0x0
        
9:      restore
        ret    
