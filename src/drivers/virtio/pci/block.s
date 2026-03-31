.equ COMMON_CONFIG,0x0
.equ NOTIFICATION,0x8
.equ ISR_STATUS,0x10
.equ DEVICE_CONFIG,0x18
.equ NOTI_OFF_MULT,0x20
.equ VQUEUE,0x28
.equ DEVICE_INFO,0x30

sizeof_DEVICE_INFO = 0x10
BLOCK_SIZE = 0x0
BLOCK_COUNT = 0x8

.include "const/virtio/virt_queue.s"

VIRTIO_BLK_T_IN           = 0 
VIRTIO_BLK_T_OUT          = 1 
VIRTIO_BLK_T_FLUSH        = 4 
VIRTIO_BLK_T_GET_ID       = 8 
VIRTIO_BLK_T_GET_LIFETIME = 10 
VIRTIO_BLK_T_DISCARD      = 11 
VIRTIO_BLK_T_WRITE_ZEROES = 13 
VIRTIO_BLK_T_SECURE_ERASE   = 14

virtio_pci_blk_init:
VIO_PCI_blk_ID = 0x010010421af4
        save
        li a0,VIO_PCI_blk_ID
        la a1,virtio_pci_blk_init_device
        mv a2,zero
blkdrive = 0x65766972646B6C62
        li a3,blkdrive
        call pci_register_driver
        restore
        ret        

virtio_pci_blk_read:
        save

        li t0,0x0
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        call virtio_pci_blk_read_sector
        j 2f
1:        
2:
        restore
        ret
        
virtio_pci_blk_write:
        save

        li t0,0x0
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        call virtio_pci_blk_write_sector
        j 2f
1:        
2:
        restore
        ret
virtio_pci_blk_ioctl:
        save

        li t0,0x0
        bne a1,t0,1f
        call virtio_pci_blk_get_total_blocks
        j 2f
1:      li t0,0x1
        bne a1,t0,1f
        call virtio_pci_blk_get_block_size
        j 2f
1:        
2:
        restore
        ret

virtio_pci_blk_get_total_blocks:
        ld a0,DEVICE_INFO(a0)
        ld a0,BLOCK_COUNT(a0)
        ret

virtio_pci_blk_get_block_size:
        ld a0,DEVICE_INFO(a0)
        ld a0,BLOCK_SIZE(a0)
        ret
        
virtio_pci_blk_read_sector:
#[ci [ device, sector, buffer ]
sizeof_virtio_blk_req_header = 0x10
        save an=3,dn=9

        mv a3,a0
        li a0,VIRTIO_BLK_T_IN
        call virtio_blk_create_request
        sd a0,_d0(sp)
        sd a2,_d6(sp)
        sd a1,_d3(sp)

#[ci [ virt_queue, requests, num]
        ld a0,_a0(sp)
        ld a0,VQUEUE(a0)
        addi a1,sp,_d0
        li t0,sizeof_virtio_blk_req_header
        sd t0,_d1(sp)
        ld t0,_a0(sp)
        ld t0,DEVICE_INFO(t0)
        ld t0,BLOCK_SIZE(t0)
        sd t0,_d4(sp)
        li t0,0x1
        sd t0,_d7(sp)
        li t0,0x0
        sd t0,_d2(sp)
        li t0,0x2
        sd t0,_d5(sp)
        li t0,0x2
        sd t0,_d8(sp)
        li a2,3
        call virtio_supply_buffer_chain_to_virtqueue
        
        slli t0,a0,0x4
        ld a0,_a0(sp)
        ld t1,VQUEUE(a0)
        ld t1,VQ_DESCRIPTOR_TABLE(t1)
        add t0,t0,t1
        sd t0,_d0(sp)

        ld a0,_a0(sp)
        ld t1,NOTIFICATION(a0)
        sh zero,(t1)
        fence w,w

1:      wfi

        ld t0,_d0(sp)
        ld t1,(t0)

        beqz t1,1f
        li t2,0x1
        bne t1,t2,2f
        ebreak
2:      li t2,0x2
        beq t1,t2,2f        
        j 1b

2:      ebreak
        
1:      restore
        ret

virtio_pci_blk_write_sector:
#[ci [ device, sector, buffer ]
sizeof_virtio_blk_req_header = 0x10
        save an=3,dn=9
        
        mv a3,a0
        li a0,VIRTIO_BLK_T_OUT
        call virtio_blk_create_request
        sd a0,_d0(sp)
        sd a1,_d3(sp)
        sd a2,_d6(sp)
#[ci [ virt_queue, requests, num]
        ld a0,_a0(sp)
        ld a0,VQUEUE(a0)
        addi a1,sp,_d0
        li t0,sizeof_virtio_blk_req_header
        sd t0,_d1(sp)
        ld t0,_a0(sp)
        ld t0,DEVICE_INFO(t0)
        ld t0,BLOCK_SIZE(t0)
        sd t0,_d4(sp)
        li t0,0x1
        sd t0,_d7(sp)
        li t0,0x0
        sd t0,_d2(sp)
        li t0,0x0
        sd t0,_d5(sp)
        li t0,0x2
        sd t0,_d8(sp)
        li a2,3
        call virtio_supply_buffer_chain_to_virtqueue
        
        slli t0,a0,0x4
        ld a0,_a0(sp)
        ld t1,VQUEUE(a0)
        ld t1,VQ_DESCRIPTOR_TABLE(t1)
        add t0,t0,t1
        sd t0,_d0(sp)

        ld a0,_a0(sp)
        ld t1,NOTIFICATION(a0)
        sh zero,(t1)
        fence w,w

1:      wfi

        ld t0,_d0(sp)
        ld t1,(t0)

        beqz t1,1f
        li t2,0x1
        bne t1,t2,2f
        ebreak
2:      li t2,0x2
        beq t1,t2,2f        
        j 1b

2:      ebreak
        
1:      restore
        ret



virtio_blk_create_request:
#[ci [ type, sector, data, device ]
sizeof_virtio_blk_req_header = 0x10
type = 0x0
sector = 0x8
data = 0x10
        save an=4
        li a0,sizeof_virtio_blk_req_header
        call malloc
        li a2,sizeof_virtio_blk_req_header
        li a1,0x0
        call memset
        ld t0,_a0(sp)
        sw t0,type(a0)
        
        ld t0,_a1(sp)
        
        ld t1,_a3(sp)
        ld t1,DEVICE_INFO(t1)
        ld t1,BLOCK_SIZE(t1)
        li t2,0x200
        divu t1,t1,t2
        mul t0,t0,t1

        sd t0,sector(a0)
        sd a0,_a0(sp)
        li a0,1
        call malloc
        sb zero,(a0)
        mv a2,a0
        ld a0,_a0(sp)
        ld a1,_a2(sp)

        restore
        ret
        
virtio_pci_blk_init_device:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device #]
        save an=3,dn=2
DEVICE = _d0
PLIC_ID = _d1

        li a1,0x20
        call pci_set_interrupt_line
        ld a0,_a0(sp)
        ld a1,_a2(sp)
        call pci_get_plic_id
        sd a0,PLIC_ID(sp)
        ld a0,_a0(sp)
        call virtio_pci_transport_init_device
        sd a0,DEVICE(sp)

        la a1,virtio_pci_blk_callback
        ld a2,PLIC_ID(sp)
        call pci_register_callback

        ld a0,PLIC_ID(sp)
        li a1,0x1
        call plic_set_prio
        li a0,0x0
        li a1,0x0
        call plic_set_prio_thres
        ld a0,PLIC_ID(sp)
        call plic_enable        
    
        ld a0,DEVICE(sp)
        ld a0,COMMON_CONFIG(a0)
        call virtio_pci_blk_handshake
        ld t0,DEVICE(sp)
        ld a0,VQUEUE(t0)
        ld a1,COMMON_CONFIG(t0)
        call virtio_pci_blk_allocate_virtqueue
        ld t0,DEVICE(sp)

        ld t1,NOTIFICATION(t0)
        sh zero,(t1)
        fence w,w

        li a0,sizeof_DEVICE_INFO
        call malloc
        ld t0,DEVICE(sp)
        sd a0,DEVICE_INFO(t0)

        ld t1,DEVICE_CONFIG(t0)
        lwu t2,20(t1)
        sd t2,BLOCK_SIZE(a0)
        ld t2,0(t1)
        sd t2,BLOCK_COUNT(a0)

        ld a0,DEVICE(sp)
        la a1,virtio_pci_blk_read
        la a2,virtio_pci_blk_write
        la a3,virtio_pci_blk_ioctl

        restore
        ret

virtio_pci_blk_callback:
addr = 0x0
len = 0x8
flags = 0xc
next = 0xe
        save an=2,sn=7
        mv s1,a0

        ld t0,ISR_STATUS(s1)
        lbu t1,(t0)
        beqz t1,9f

        ld t0,VQUEUE(s1)
        ld s2,LAST_SEEN_USED(t0)
        ld s3,VQ_USED_RING(t0)
        lhu s3,0x2(t2)
        lhu s4,VQ_SIZE(t0)
        ld s5,VQ_DESCRIPTOR_TABLE(t0)
        
        
1:      remu s6,s2,s4
        slli s6,s6,0x4
        add s6,s6,s5
        mv s7,s6

        ld a0,addr(s6)
        call free
        sd zero,addr(s6)

        lhu t0,next(s6)
        remu s6,t0,s4
        slli s6,s6,0x4
        add s6,s6,s5

        sd zero,addr(s6)

        lhu t0,next(s6)
        remu s6,t0,s4
        slli s6,s6,0x4
        add s6,s6,s5

        ld a0,addr(s6)
        lbu t0,(a0)
        beqz t0,2f

        sd t0,addr(s7)
        
2:      call free
        sd zero,addr(s6)

        addi s2,s2,0x1
        blt s2,s3,1b
        
        ld t0,VQUEUE(s1)
        sh s2,LAST_SEEN_USED(t0)

        li a0,0x0
        ld a1,_a1(sp)
        call plic_complete_interrupt
        li a0,0x0
        j 8f

9:      li a0,0x1
8:
        restore
        ret

virtio_pci_blk_allocate_virtqueue:
        save an=2,sn=2

        sh zero,0x16(a1)
        lhu t1,0x18(a1)
        li t2,0x40000
        minu s1,t1,t2
        sh s1,VQ_SIZE(a0)
        slli a0,s1,0x4
        mv s2,a0
        li a1,0x1000
        call malloc_aligned
        mv a2,s2
        mv a1,zero
        call memset
        mv t0,a0
        ld a0,_a0(sp)
        sd t0,VQ_DESCRIPTOR_TABLE(a0)

        slli a0,s1,0x1
        addi a0,a0,6
        mv s2,a0
        li a1,0x1000
        call malloc_aligned
        mv a2,s2
        mv a1,zero
        call memset
        mv t0,a0
        ld a0,_a0(sp)
        sd t0,VQ_AVAIL_RING(a0)

        slli a0,s1,0x3
        addi a0,a0,6
        mv s2,a0
        li a1,0x1000
        call malloc_aligned

        mv a2,s2
        mv a1,zero
        call memset
        mv t0,a0
        ld a0,_a0(sp)
        sd t0,VQ_USED_RING(a0)

        ld a1,_a1(sp)

        ld t0,VQ_DESCRIPTOR_TABLE(a0)
        li t1,0xFFFFFFFF
        and t1,t0,t1
        sw t1,0x20(a1)
        srli t1,t0,0x20
        sw t1,0x24(a1)

        ld t0,VQ_AVAIL_RING(a0)
        li t1,0xFFFFFFFF
        and t1,t0,t1
        sw t1,0x28(a1)
        srli t1,t0,0x20
        sw t1,0x2C(a1)

        ld t0,VQ_USED_RING(a0)
        li t1,0xFFFFFFFF
        and t1,t0,t1
        sw t1,0x30(a1)
        srli t1,t0,0x20
        sw t1,0x34(a1)

        li t1,0x1
        sh t1,0x1c(a1)

        restore
        ret

virtio_pci_blk_handshake:
        save
DEVICE_STATUS = 0x14
DEVICE_FEATURE_SELECT = 0x0
DEVICE_FEATURE = 0x4
DRIVER_FEATURE_SELECT = 0x8
DRIVER_FEATURE = 0xc

        sb zero,DEVICE_STATUS(a0)
        fence rw,rw
        li t1,0x1
        sb t1,DEVICE_STATUS(a0)
        fence rw,rw
        li t1,0x3
        sb t1,DEVICE_STATUS(a0)
        fence rw,rw
        
        li t1,(0 << 9) | (1 << 6)
        sw t1,DRIVER_FEATURE(a0)

        li t1,0x1
        sw t1,DRIVER_FEATURE_SELECT(a0)
        sw t1,DRIVER_FEATURE(a0)
        fence io,io
        li t1,0xB
        sb t1,DEVICE_STATUS(a0)
        fence io,io
        lbu t2,DEVICE_STATUS(a0)
        beq t1,t2,1f
        ecall
1:      li t1,0xF
        sb t1,DEVICE_STATUS(a0)

        restore
        ret
