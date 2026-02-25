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

.equ VQ_DESCRIPTOR_TABLE,0x28
.equ VQ_AVAIL_RING,0x30
.equ VQ_USED_RING,0x38

.equ VQ_SIZE,0x40

.equ VIO_PCI_IN_VQUEUE_SIZE,0x40

.local DEVICE_STATUS
.equ DEVICE_STATUS,0x14
.local DEVICE_FEATURE
.equ DEVICE_FEATURE,0x4
.local DRIVER_FEATURE
.equ DRIVER_FEATURE,0xc

virtio_input_handshake:
#[ci [ a0 = *Capabilities ]
        salloc 0

        ld t0,COMMON_CONFIG(a0)
        sb zero,DEVICE_STATUS(t0)
        fence io,io
        li t1,0x1
        sb t1,DEVICE_STATUS(t0)
        fence io,io
        li t1,0x3
        sb t1,DEVICE_STATUS(t0)
        fence io,io
        lwu t1,DEVICE_FEATURE(t0)
        li t2,0x30000000
        and t1,t1,t2
        sw t1,DRIVER_FEATURE(t0)
        fence io,io
        li t1,0xB
        sb t1,DEVICE_STATUS(t0)
        fence io,io
        lbu t2,DEVICE_STATUS(t0)
        beq t1,t2,1f
        ecall
1:      li t1,0xF
        sb t1,DEVICE_STATUS(t0)

        sfree 0
        ret

virtio_input_allocate_virtqueue:
#[ci [ a0 = *Capabilities ]
        salloc 40
        sd s1,(sp)

        ld t0,COMMON_CONFIG(a0)

        sh zero,0x16(t0)
        lhu t1,0x18(t0)
        li t2,0x40
        minu t1,t1,t2
        sh t1,VQ_SIZE(a0)
        mv s1,t1

        sd a0,0x8(sp)

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

        ld s1,COMMON_CONFIG(a0)

        ld t0,VQ_DESCRIPTOR_TABLE(a0)
        li t1,0xFFFFFFFF
        and t1,t0,t1
        sw t1,0x20(s1)
        srli t1,t0,0x20
        sw t1,0x24(s1)

        ld t0,VQ_AVAIL_RING(a0)
        li t1,0xFFFFFFFF
        and t1,t0,t1
        sw t1,0x28(s1)
        srli t1,t0,0x20
        sw t1,0x2C(s1)

        ld t0,VQ_USED_RING(a0)
        li t1,0xFFFFFFFF
        and t1,t0,t1
        sw t1,0x30(s1)
        srli t1,t0,0x20
        sw t1,0x34(s1)

        ld t0,COMMON_CONFIG(a0)
        li t1,0x1
        sh t1,0x1c(t0)

        ld s1,(sp)
        sfree 40
        ret
