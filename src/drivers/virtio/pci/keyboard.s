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
.equ RING_BUFFER_SIZE,0x38

.equ VQ_DESCRIPTOR_TABLE,0x0
.equ VQ_AVAIL_RING,0x8
.equ VQ_USED_RING,0x10
.equ LAST_SEEN_USED,0x18
.equ VQ_SIZE,0x20

.equ KEY_RING_BUFFER_SIZE,0x100

virtio_pci_keyboard_init:
VIO_PCI_INPUT_ID = 0x090010521af4
        save
        li a0,VIO_PCI_INPUT_ID
        la a1,virtio_pci_keyboard_init_device
        mv a2,zero
keyboard = 0x6472616F6279656B        
        li a3,keyboard
        call pci_register_driver
        restore
        ret

virtio_pci_keyboard_init_device:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device #]
        save an=3,dn=2

PLIC_ID = _d0
DEVICE = _d1

        li a1,0x20
        call pci_set_interrupt_line
        ld a0,_a0(sp)
        ld a1,_a2(sp)
        call pci_get_plic_id
        sd a0,PLIC_ID(sp)
        ld a0,_a0(sp)
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

        li a0,KEY_RING_BUFFER_SIZE*8+0x8
        call malloc
        li a2,KEY_RING_BUFFER_SIZE*8+0x8
        mv a1,zero
        call memset
        ld t0,DEVICE(sp)
        sd a0,RING_BUFFER(t0)
        li t1,KEY_RING_BUFFER_SIZE
        sd t1,RING_BUFFER_SIZE(t0)

        ld t1,NOTIFICATION(t0)
        sh zero,(t1)
        fence w,w

        ld a0,DEVICE(sp)
        la a1,virtio_pci_keyboard_read
        la a2,virtio_pci_keyboard_write
        la a3,virtio_pci_keyboard_ioctl

        restore
        ret

virtio_pci_keyboard_callback:
#[ci [ a0 = *device, a1 = irq ]
        save an=2,sn=1
        mv s1,a0

        ld t0,ISR_STATUS(s1)
        lbu t1,(t0)
        beqz t1,9f

        mv a2,s1
        ld a0,VQUEUE(a2)
        la a1,virtio_pci_keyboard_append_ring

        call virtio_input_read_used_ring

        ld t1,NOTIFICATION(s1)
        sh zero,(t1)
        fence w,w
        
        li a0,0x0
        ld a1,_a1(sp)
        call plic_complete_interrupt
        li a0,0x0
        j 8f

9:      li a0,0x1
8:      
        restore
        ret

virtio_pci_keyboard_read:
#[ci [ device, op, ... ]
        save
        li t0,0x0
        bne a1,t0,1f
        call virtio_pci_keyboard_pull_event
        j 2f
1:      li t0,0x1
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        call virtio_pci_keyboard_pull_events
        j 2f
1:
2:        
        restore
        ret
virtio_pci_keyboard_write:
        ret
virtio_pci_keyboard_ioctl:
        ret

virtio_pci_keyboard_pull_event:
#[ci [ device ]
        tail virtio_pci_keyboard_pop_ring
        
virtio_pci_keyboard_pull_events:
#[ci [ device, buffer, n ]
        save an=1,sn=2
_device = _a0
        mv s1,a2
        mv s2,a1

1:      ld a0,_device(sp)
        call virtio_pci_keyboard_pop_ring
        li t0,-EAGAIN
        beq a0,t0,2f

        sd a0,(s2)
        
        addi s2,s2,0x8
        addi s1,s1,-1
        bgtz s1,1b

2:      restore
        ret

virtio_pci_keyboard_pop_ring:
#[ci [ a0 = *device ]
read = 0x0
write = 0x4
ring = 0x8
A0 = 0x0
        ld t0,RING_BUFFER_SIZE(a0)
        ld a0,RING_BUFFER(a0)
        lwu t1,read(a0)
        remu t1,t1,t0
        lwu t2,write(a0)
        remu t2,t2,t0
        beq t1,t2,1f

        slli t3,t1,0x3
        add t3,t3,a0
        ld a1,ring(t3)
        add t1,t1,0x1
        remu t1,t1,t0
        sw t1,read(a0)
        mv a0,a1
        ret

1:      li a0,-EAGAIN
        ret
        


virtio_pci_keyboard_append_ring:
#[ci [ a0 = *device, a1 = val]
read = 0x0
write = 0x4
ring = 0x8
A0 = 0x0
        ld t0,RING_BUFFER_SIZE(a0)
        ld a0,RING_BUFFER(a0)
        lwu t1,read(a0)
        remu t1,t1,t0
        lwu t2,write(a0)
        addi t3,t2,0x1
        remu t3,t3,t0
        beq t1,t3,1f

        remu t3,t2,t0
        slli t3,t3,0x3
        add t3,t3,a0
        ld t4,(a1)
        sd t4,ring(t3)
        addi t2,t2,0x1
        remu t2,t2,t0
        sw t2,write(a0)
        
1:      ret

