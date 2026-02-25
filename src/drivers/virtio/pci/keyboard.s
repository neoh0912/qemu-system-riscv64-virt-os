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
#[ci [ a0 = address of config space ]
        salloc 8

        call virtio_pci_transport_init_device
        sd a0,(sp)
        call virtio_input_handshake
        ld a0,(sp)
        call virtio_input_allocate_virtqueue
        ld a0,(sp)
        li a1,0x10
        ebreak
#        call virtio_input_allocate_events
        sfree 8
        ret
