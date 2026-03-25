sizeof_device_descriptor_table = 0x10

device_manager_open_device: #[ci [ device_descriptor ]
#[ci [ device_type, id ]
        save
        call device_manager_get_device
        bnez a0,1f

        li a0,-ENODEV
        j 9f
        
1:      ld t0,device_manager_device_descriptors
        li t2,( sizeof_device_descriptor_table * 0x8 )
        add t2,t2,t0
        mv t4,t0

1:      ld t1,(t0)
        bnez t1,2f

        sd a0,(t0)
        sub t0,t0,t4
        srli a0,t0,0x3
        j 9f

2:      addi t0,t0,0x8
        blt t0,t2,1b
        li a0,-EMFILE

9:      restore
        ret

device_manager_close_device:
#[ci [ device_descriptor ]
        save
        li t0,sizeof_device_descriptor_table
        blt a0,t0,1f
        li a0,-ERANGE
        j 9f
        
1:      slli t0,a0,0x3
        ld t1,device_manager_device_descriptors
        add t0,t0,t1

        ld t1,(t0)
        bnez t1,1f
        li a0,-EBADF
        j 9f
        
1:      sd zero,(t0)
        mv a0,zero

9:      restore
        ret

.global device_manager_get_device_of_dd
.macro device_manager_get_device_of_dd
        addi sp,sp,-8
        sd s1,(sp)
        slli a0,a0,0x3
        ld s1,device_manager_device_descriptors
        add a0,a0,s1
        ld a0,(a0)
        ld s1,(sp)
        addi sp,sp,8
.endm
