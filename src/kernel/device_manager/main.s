sizeof_device_scanner = 0x10
sizeof_device_tree = 0x20
sizeof_device = 0x38+1

create_device_tree:
#[ci [ device_type]
device_type = 0x0
start = 0x8
avail_id = 0x10
next = 0x18
        salloc 0
        sald 1
        sd a0,(sp)
        li a0,sizeof_device_tree
        call malloc
        ld t0,(sp)
        sd t0,device_type(a0)
        sd zero,start(a0)
        la t0,device_manager_device_tree_root
        ld t1,(t0)
        sd t1,next(a0)
        sd zero,avail_id(a0)
        sd a0,(t0)
        sfree
        ret

device_manager_init:
        salloc 0
keyboard = 0x6472616F6279656B
        li a0,keyboard
        call create_device_tree
display = 0x0079616C70736964
        li a0,display
        call create_device_tree

        sfree
        ret

device_manager_register_device_scanner:
#[ci [ scanner: *device_scanner ]
scanner = 0x0
next = 0x8
        salloc 8
        sd a0,(sp)
        li a0,sizeof_device_scanner
        call malloc
        la t0,device_manager_device_scanners
        ld t1,(t0)
        sd t1,next(a0)
        sd a0,(t0)
        ld t0,(sp)
        sd t0,scanner(a0)
        sfree
        ret

device_manager_scan:
_s1 = 0x0
scanner = 0x0
next = 0x8
        salloc 0
        sald 1
        sd s1,_s1(sp)

        ld s1,device_manager_device_scanners
1:      ld t0,scanner(s1)
        jalr ra,t0,0x0
        mv t0,s1
        ld s1,next(t0)
        bnez s1,1b

        ld s1,_s1(sp)
        sfree
        ret

device_manager_get_device_tree:
#[ci [ device_type ]
device_type = 0x0
start = 0x8
avail_id = 0x10
next = 0x18
        ld t0,device_manager_device_tree_root
1:      ld t1,device_type(t0)
        beq t1,a0,1f
        mv t1,t0
        ld t0,next(t1)
        bnez t0,1b
1:      mv a0,t0
        ret        

device_manager_get_device:
#[ci [ device_type, id ]
device_type = 0x0
start = 0x8
next = 0x18
id = 0x0
        ld t0,device_manager_device_tree_root
1:      ld t1,device_type(t0)
        beq t1,a0,1f
        mv t1,t0
        ld t0,next(t1)
        bnez t0,1b
9:      li a0,0x0
        j 9f
        
1:      ld t0,start(t0)

1:      beqz t0,9b
        
        ld t1,id(t0)
        bne t1,a1,2f

        mv a0,t0
        j 9f

2:      mv t1,t0
next = 0x30
        ld t0,next(t1)
        j 1b

9:      ret

device_manager_register_device:
#[ci [ device: *void, read, write, ioctl: *function, device_type: char[8] ]
_id = 0x0
_device = 0x8
_read = 0x10
_write = 0x18
_ioctl = 0x20
_ptr = 0x28
id = 0x0
device = 0x8
parent = 0x10
read = 0x18
write = 0x20
ioctl = 0x28
next = 0x30
parent_set = 0x38
start = 0x8
avail_id = 0x10
        salloc 0
        sald 6
        sd a0,_device(sp)
        sd a1,_read(sp)
        sd a2,_write(sp)
        sd a3,_ioctl(sp)
        mv a0,a4
        
        call device_manager_get_device_tree
        ld t0,0x10(a0)
        sd t0,_id(sp)
        sd a0,_ptr(sp)

        li a0,sizeof_device
        call malloc
        ld t0,_device(sp)
        sd t0,device(a0)
        ld t0,_read(sp)
        sd t0,read(a0)
        ld t0,_write(sp)
        sd t0,write(a0)
        ld t0,_ioctl(sp)
        sd t0,ioctl(a0)
        sd zero,parent(a0)
        sb zero,parent_set(a0)
        ld t0,_ptr(sp)
        ld t1,start(t0)
        sd t1,next(a0)
        sd a0,start(t0)
        ld t1,_id(sp)
        sd t1,id(a0)
        addi t1,t1,0x1
        sd t1,avail_id(t0)

        sfree
        ret
