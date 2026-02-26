.local COMMON_CONFIG
.local NOTIFICATION
.local ISR_STATUS
.local DEVICE_CONFIG
.local NOTI_OFF_MULT
.local VQ_SIZE
.local VQ_DESCRIPTOR_TABLE
.local VQ_AVAIL_RING
.local VQ_USED_RING
.equ COMMON_CONFIG,0x0
.equ NOTIFICATION,0x8
.equ ISR_STATUS,0x10
.equ DEVICE_CONFIG,0x18
.equ NOTI_OFF_MULT,0x20
.equ VQUEUE,0x28

.equ VQ_DESCRIPTOR_TABLE,0x0
.equ VQ_AVAIL_RING,0x8
.equ VQ_USED_RING,0x10
.equ VQ_SIZE,0x18

.equ VIO_PCI_IN_VQUEUE_SIZE,0x40

virtio_input_handshake:
#[ci [ a0 = *regs ]

DEVICE_STATUS = 0x14
DEVICE_FEATURE_SELECT = 0x0
DEVICE_FEATURE = 0x4
DRIVER_FEATURE_SELECT = 0x8
DRIVER_FEATURE = 0xc

        salloc 0

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

        sfree 0
        ret

virtio_input_allocate_virtqueue:
#[ci [ a0 = *VQUEUE, a1 = *VREGS ]
        salloc 40
        sd s1,(sp)
        sd a0,0x8(sp)
        sd a1,0x10(sp)

        sh zero,0x16(a1)
        lhu t1,0x18(a1)
        li t2,0x40
        minu s1,t1,t2
        sh s1,VQ_SIZE(a0)
        slli a0,s1,0x4
        call zalloc
        mv t0,a0
        ld a0,0x8(sp)
        sd t0,VQ_DESCRIPTOR_TABLE(a0)

        slli a0,s1,0x1
        addi a0,a0,6
        call zalloc
        mv t0,a0
        ld a0,0x8(sp)
        sd t0,VQ_AVAIL_RING(a0)

        slli a0,s1,0x3
        addi a0,a0,6
        call zalloc
        mv t0,a0
        ld a0,0x8(sp)
        sd t0,VQ_USED_RING(a0)

        ld a1,0x10(sp)

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

        ld s1,(sp)
        sfree 40
        ret

virtio_input_allocate_input_structs:
#[ci [ a0 = *VQUEUE ]
A0 = 0x0
BUFFER = 0x8

addr = 0x0
len = 0x8
flags = 0xc
next = 0xe

        salloc 40
        sd a0,(sp)

        ld a0,VQ_SIZE(a0)
        slli a0,a0,0x3
        call zalloc
        sd a0,BUFFER(sp)
        ld a0,A0(sp)
        ld a2,VQ_SIZE(a0)


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
        addi t0,t0,0x1
        blt t0,a2,1b

        lhu t4,0x2(t3)
        add t4,t4,a2
        sh t4,0x2(t3)

        fence w,w

        sfree 40
        ret

virtio_input_read_used_ring:
#[ci [ a0 = *used_ring, a1 = *avail_ring,    ]
#[ci [ a2 = *last_seen_used, a3 = queue_size ]
#[ci [ a4 = *handler                         ]
        salloc 0

        

        sfree 0
        ret
