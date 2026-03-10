.equ COMMON_CONFIG,0x0
.equ NOTIFICATION,0x8
.equ ISR_STATUS,0x10
.equ DEVICE_CONFIG,0x18
.equ NOTI_OFF_MULT,0x20
.equ VQUEUE,0x28

.equ VQ_DESCRIPTOR_TABLE,0x0
.equ VQ_AVAIL_RING,0x8
.equ VQ_USED_RING,0x10
.equ LAST_SEEN_USED,0x18
.equ VQ_SIZE,0x20

virtio_pci_block_device_init:
VIO_PCI_BLOCK_DEVICE_ID = 0x010010011af4
        save
        li a0,VIO_PCI_BLOCK_DEVICE_ID
        la a1,virtio_pci_block_device_init_device
        mv a2,zero
blkdrive = 0x65766972646B6C62
        li a3,blkdrive
        call pci_register_driver
        restore
        ret        

virtio_pci_block_device_read:
        ret
virtio_pci_block_device_write:
        ret
virtio_pci_block_device_ioctl:
        ret
        
virtio_pci_block_device_init_device:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device #]
        save an=3,dn=1
DEVICE = _d0
        call virtio_pci_transport_init_device
        sd a0,DEVICE(sp)

        call virtio_pci_block_device_handshake
        ld t0,DEVICE(sp)
        ld a0,VQUEUE(t0)
        ld a1,COMMON_CONFIG(t0)
        call virtio_pci_block_device_allocate_virtqueue
        ld t0,DEVICE(sp)

        ld t1,NOTIFICATION(t0)
        sh zero,(t1)
        fence w,w

        ld a0,DEVICE(sp)
        la a1,virtio_pci_block_device_read
        la a2,virtio_pci_block_device_write
        la a3,virtio_pci_block_device_ioctl

        restore
        ret

virtio_pci_block_device_allocate_virtqueue:
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

virtio_pci_block_device_handshake:
        save
DEVICE_STATUS = 0x14
DEVICE_FEATURE_SELECT = 0x0
DEVICE_FEATURE = 0x4
DRIVER_FEATURE_SELECT = 0x8
DRIVER_FEATURE = 0xc

        ld a0,COMMON_CONFIG(a0)
        sb zero,DEVICE_STATUS(a0)
        fence rw,rw
        li t1,0x1
        sb t1,DEVICE_STATUS(a0)
        fence rw,rw
        li t1,0x3
        sb t1,DEVICE_STATUS(a0)
        fence rw,rw
        
        li t1,(1 << 9) | (1 << 6)
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
