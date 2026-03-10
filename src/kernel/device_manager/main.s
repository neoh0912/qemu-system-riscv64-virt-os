.include "const/device_manager/device_struct.s"
.include "const/device_manager/device_tree_struct.s"
.include "const/device_manager/device_scanner_struct.s"

sizeof_device_descriptor_table = 0x10

create_device_tree:
#[ci [ device_type]
        save an=1
        li a0,sizeof_device_tree
        call malloc
        ld t0,_a0(sp)
        sd t0,device_tree__device_type(a0)
        sd zero,device_tree__start(a0)
        la t0,device_manager_device_tree_root
        ld t1,(t0)
        sd t1,device_tree__next(a0)
        sd zero,device_tree__avail_id(a0)
        sd a0,(t0)
        restore
        ret

device_manager_init:
        save
keyboard = 0x6472616F6279656B
        li a0,keyboard
        call create_device_tree
display = 0x0079616C70736964
        li a0,display
        call create_device_tree
blkdrive = 0x65766972646B6C62
        li a0,blkdrive
        call create_device_tree

        li a0,0x8*sizeof_device_descriptor_table
        call malloc
        li a1,0x0
        li a2,0x8*sizeof_device_descriptor_table
        call memset

        la t0,device_manager_device_descriptors
        sd a0,(t0)

        restore
        ret

device_manager_register_device_scanner:
#[ci [ scanner: *device_scanner ]
        save an=1
        li a0,sizeof_device_scanner
        call malloc
        la t0,device_manager_device_scanners
        ld t1,(t0)
        sd t1,device_scanner__next(a0)
        sd a0,(t0)
        ld t0,_a0(sp)
        sd t0,device_scanner__scanner(a0)
        restore
        ret

device_manager_scan:
        save sn=1

        ld s1,device_manager_device_scanners
1:      ld t0,device_scanner__scanner(s1)
        jalr ra,t0,0x0
        mv t0,s1
        ld s1,device_scanner__next(t0)
        bnez s1,1b

        restore
        ret

device_manager_get_device_tree:
#[ci [ device_type ]
        ld t0,device_manager_device_tree_root
1:      ld t1,device_tree__device_type(t0)
        beq t1,a0,1f
        mv t1,t0
        ld t0,device_tree__next(t1)
        bnez t0,1b
1:      mv a0,t0
        ret        

device_manager_get_device:
#[ci [ device_type, id ]
        ld t0,device_manager_device_tree_root
1:      ld t1,device_tree__device_type(t0)
        beq t1,a0,1f
        mv t1,t0
        ld t0,device_tree__next(t1)
        bnez t0,1b
9:      li a0,0x0
        j 9f
        
1:      ld t0,device_tree__start(t0)

1:      beqz t0,9b
        
        ld t1,device__id(t0)
        bne t1,a1,2f

        mv a0,t0
        j 9f

2:      mv t1,t0
next = 0x30
        ld t0,device__next(t1)
        j 1b

9:      ret

device_manager_register_device:
#[ci [ device: *void, read, write, ioctl: *function, device_type: char[8] ]

        save an=5,dn=2
_device = _a0
_read = _a1
_write = _a2
_ioctl = _a3
_device_type = _a4
_id = _d0
_ptr = _d1
        mv a0,a4

        call device_manager_get_device_tree
        ld t0,device_tree__avail_id(a0)
        sd t0,_id(sp)
        addi t0,t0,0x1
        sd t0,device_tree__avail_id(a0)
        sd a0,_ptr(sp)

        li a0,sizeof_device
        call malloc

        ld t0,_device_type(sp)
        sd t0,device__device_type(a0)
        
        ld t0,_device(sp)
        sd t0,device__device(a0)
        
        ld t0,_read(sp)
        sd t0,device__read(a0)
        
        ld t0,_write(sp)
        sd t0,device__write(a0)
        
        ld t0,_ioctl(sp)
        sd t0,device__ioctl(a0)
        
        sd zero,device__parent(a0)
        sb zero,device__parent_set(a0)
        
        ld t0,_ptr(sp)
        
        ld t1,device_tree__start(t0)
        sd t1,device__next(a0)
        sd a0,device_tree__start(t0)
        
        ld t1,_id(sp)
        sd t1,device__id(a0)

        restore
        ret
