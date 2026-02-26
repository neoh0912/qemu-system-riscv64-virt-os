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
.equ VQ_SIZE,0x18

.equ RING_BUFFER_SIZE,0x100

virtio_pci_keyboard_init:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device #]
        salloc 40

A0 = 0x0
A1 = 0x8
A2 = 0x10
PLIC_ID = 0x18
DEVICE = 0x20

        sd a0,A0(sp)
        sd a1,A1(sp)
        sd a2,A2(sp)

        li a1,0x20
        call pci_set_interrupt_line
        ld a0,A0(sp)
        ld a1,A2(sp)
        call pci_get_plic_id
        sd a0,PLIC_ID(sp)
        ld a0,A0(sp)
        call virtio_pci_transport_init_device
        sd a0,DEVICE(sp)

        la a1,virtio_pci_keyboard_callback
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
        call virtio_input_handshake
        ld t0,DEVICE(sp)
        ld a0,VQUEUE(t0)
        ld a1,COMMON_CONFIG(t0)
        call virtio_input_allocate_virtqueue
        ld a0,DEVICE(sp)
        
        ld t0,DEVICE(sp)
        ld a0,VQUEUE(t0)
        call virtio_input_allocate_input_structs

        li a0,RING_BUFFER_SIZE+0x2
        call zalloc
        ld t0,DEVICE(sp)
        sd a0,RING_BUFFER(t0)

        ld t1,NOTIFICATION(t0)
        sh zero,(t1)
        fence w,w

        sfree 40
        ret

virtio_pci_keyboard_callback:
#[ci [ a0 = *device, a1 = irq ]
        A0 = 0x0
        A1 = 0x8

        salloc 16

        sd a0,A0(sp)
        sd a1,A1(sp)
        
        ld t0,ISR_STATUS(a0)
        lbu t1,(t0)
        beqz t1,9f
 
        db 'i'       
#        call virtio_input_read_used_ring
        
        li a0,0x0
        call plic_complete_interrupt
        li a0,0x0
        j 8f

9:      li a0,0x1
8:      sfree 16
        ret
