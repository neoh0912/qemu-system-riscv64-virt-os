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
        call virtio_input_handshake
        ld a0,DEVICE(sp)
        call virtio_input_allocate_virtqueue
        ld a0,DEVICE(sp)
        
        ld t0,DEVICE(sp)
        ld a0,VQ_DESCRIPTOR_TABLE(t0)
        ld a1,VQ_AVAIL_RING(t0)
        ld a2,VQ_SIZE(t0)
        mv a3,a2
        call virtio_input_allocate_input_structs

        ebreak
        
        sfree 40
        ret

virtio_pci_keyboard_callback:
        ret
