.local VQ_SIZE
.local VQ_DESCRIPTOR_TABLE
.local VQ_AVAIL_RING
.local VQ_USED_RING

.equ VQ_DESCRIPTOR_TABLE,0x0
.equ VQ_AVAIL_RING,0x8
.equ VQ_USED_RING,0x10
.equ LAST_SEEN_USED,0x18
.equ VQ_SIZE,0x20

.equ VIO_PCI_IN_VQUEUE_SIZE,0x40

virtio_input_handshake:
#[ci [ a0 = *regs ]

DEVICE_STATUS = 0x14
DEVICE_FEATURE_SELECT = 0x0
DEVICE_FEATURE = 0x4
DRIVER_FEATURE_SELECT = 0x8
DRIVER_FEATURE = 0xc

        save

        sb zero,DEVICE_STATUS(a0)
        fence io,io
        li t1,0x1
        sb t1,DEVICE_STATUS(a0)
        fence io,io
        li t1,0x3
        sb t1,DEVICE_STATUS(a0)
        fence io,io
        li t1,0x1
        sw t1,DEVICE_FEATURE_SELECT(a0)
        sw t1,DRIVER_FEATURE_SELECT(a0)
        lwu t1,DEVICE_FEATURE(a0)
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

virtio_input_allocate_virtqueue:
#[ci [ a0 = *VQUEUE, a1 = *VREGS ]
        save an=2,sn=2

        sh zero,0x16(a1)
        lhu t1,0x18(a1)
        li t2,0x40
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

virtio_input_allocate_input_structs:
#[ci [ a0 = *VQUEUE ]

addr = 0x0
len = 0x8
flags = 0xc
next = 0xe

        save an=1,sn=1,dn=1
BUFFER = _d0

        lhu a0,VQ_SIZE(a0)
        slli a0,a0,0x3
        mv s1,a0
        call malloc
        mv a2,s1
        mv a1,zero
        call memset
        sd a0,BUFFER(sp)
        ld a0,_a0(sp)
        lhu a2,VQ_SIZE(a0)

        li t0,0x0
        ld t1,BUFFER(sp)
        ld t2,VQ_DESCRIPTOR_TABLE(a0)
        ld t3,VQ_AVAIL_RING(a0)
        lhu t4,0x2(t3)
        slli t4,t4,0x1
        addi t4,t4,0x4
        add t4,t4,t3
1:      sd t1,addr(t2)
        li t5,0x8
        sw t5,len(t2)
        li t5,0x2
        sh t5,flags(t2)
        sh zero,next(t2)
        
        addi t2,t2,0x10
        
        sh t0,(t4)

        add t4,t4,0x2
        add t1,t1,0x8
        addi t0,t0,0x1
        blt t0,a2,1b

        lhu t4,0x2(t3)
        add t4,t4,a2
        sh t4,0x2(t3)

        fence w,w

        restore
        ret

virtio_input_read_used_ring:
#[ci [ a0 = *VQUEUE, a1 = *handler , a2 = *device ]
idx = 0x2
ring = 0x4
        save an=3,sn=6

#[g -- Read Used_ring->idx --

        ld s1,VQ_USED_RING(a0)
        ld s2,LAST_SEEN_USED(a0)
        lhu s3,VQ_SIZE(a0)
        ld s4,VQ_AVAIL_RING(a0)

        mv s5,a0        
1:      lhu t0,idx(s1)
#        ebreak
        beq t0,s2,1f

        remu t0,s2,s3
#        ebreak
        slli t0,t0,0x3
        add t0,t0,s1

        lwu s6,ring(t0)
#        ebreak
        ld t0,VQ_DESCRIPTOR_TABLE(s5)
        slli t1,s6,0x4
        add t0,t0,t1

        ld a1,(t0)
        ld a0,_a2(sp)
        ld t0,_a1(sp)
        jalr ra,t0,0x0

        lhu t0,idx(s4)
        remu t1,t0,s3
        slli t1,t1,0x1
        add t1,t1,s4

        sh s6,ring(t1)
        addi t0,t0,0x1
        sh t0,idx(s4)

        addi s2,s2,0x1
        j 1b

1:      sd s2,LAST_SEEN_USED(s5)

        restore 
        ret
