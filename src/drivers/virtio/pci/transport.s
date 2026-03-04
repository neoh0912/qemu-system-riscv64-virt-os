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
.equ RING_BUFFER,0x30

.equ VQ_DESCRIPTOR_TABLE,0x0
.equ VQ_AVAIL_RING,0x8
.equ VQ_USED_RING,0x10
.equ LAST_SEEN_USED,0x18
.equ VQ_SIZE,0x20

virtio_pci_transport_init_device:
#[ci [ a0 = address off config ]
        save an=1,dn=1

        li a0,0x40
        call malloc
        sd a0,_d0(sp)

        li a0,0x22
        call malloc
        li a2,0x22
        mv a1,zero
        call memset
        ld t0,_d0(sp)
        sd a0,VQUEUE(t0)

        
        ld a0,_a0(sp)
        call virtio_pci_transport_get_regs
        
        ld t0,_d0(sp)
        sd a0, COMMON_CONFIG(t0)
        sd a1,  NOTIFICATION(t0)
        sd a2,    ISR_STATUS(t0)
        sd a3, DEVICE_CONFIG(t0)
        sd a4, NOTI_OFF_MULT(t0)

        ld a0,_d0(sp)

        restore
        ret

virtio_pci_transport_get_regs:
#[ci [ a0 = address off config ]
        save sn=2,dn=6

        li s1,0x0

        lwu t0,0x34(a0)
        add s2,a0,t0
2:      lbu t0,(s2)
        li t1,0x9
        bne t0,t1,1f

        lbu t0,0x3(s2)
        li t1,0x5
        bge t0,t1,1f

#[ri [ allocate bar ]

        li t1,0x2
        bne t0,t1,3f
        lwu t1,0x10(s2)
        sd t1,_d5(sp)
3:
        lbu a1,0x4(s2)
        
        li t0,0x1
        sll t0,t0,a1
        and t1,s1,t0
        bnez t1,3f

        or s1,s1,t0
        
        sd a0,_d0(sp)
        call pci_allocate_bar_to_mmio_region
        mv t0,a0
        ld a0,_d0(sp)
        j 4f
        
3:      sd a0,_d0(sp)
        call pci_get_bar_address
        mv t0,a0
        ld a0,_d0(sp)

4:      lwu t1,0x8(s2)
        add t0,t0,t1
        lbu t1,0x3(s2)
        slli t1,t1,0x3
        add t1,t1,sp
        sd t0,(t1)
        
1:      lbu t0,0x1(s2)

        beqz t0,1f  
        add s2,a0,t0
        j 2b

        
1:      ld a0,0x8(sp)
        ld a1,0x10(sp)
        ld a2,0x18(sp)
        ld a3,0x20(sp)
        ld a4,_d5(sp)
        restore
        ret
