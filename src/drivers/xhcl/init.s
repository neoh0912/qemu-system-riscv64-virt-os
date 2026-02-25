.equ XHCL_PCI_ID,0x000d1b36
.equ XHCL_CR_SIZE,0x1000
.equ XHCL_EVENT_RING_SIZE,0x1000
.equ XHCL_ERST_SIZE,0x20
.equ XHCL_PLIC_ID,0x20
.equ XHCL_ENABLED_SLOTS,0x1

.local HCSPARAMS1
.equ HCSPARAMS1,0x4
.local CONFIG
.equ CONFIG,0x38
.local CAPLENGTH
.equ CAPLENGTH,0x0
.local USBSTS
.equ USBSTS,0x4
.local USBCMD
.equ USBCMD,0x0
.local DCBAAP
.equ DCBAAP,0x30
.local CRCR
.equ CRCR,0x18
.local RTSOFF
.equ RTSOFF,0x14
.local ERSTSZ
.equ ERSTSZ,0x8
.local ERDP
.equ ERDP,0x18
.local ERSTBA
.equ ERSTBA,0x10
.local IMAN
.local IMOD
.equ IMAN,0x0
.equ IMOD,0x4


xhcl_init:
        salloc 0

        call xhcl_init_plic

        call xhcl_init_pci
        call xhcl_init_regs

        call xhcl_setup
        call xhcl_init_event_ring

        call xhcl_init_interrupts

        ld t0,xhcl_opr_regs
        add t0,t0,t1

        lwu t1,USBCMD(t0)
        ori t1,t1,0x1
        sw t1,USBCMD(t0)

        lwu t1,USBSTS(t0)
        andi t1,t1,0x1

        sfree 0
        ret

xhcl_init_interrupts:
        ret

xhcl_init_plic:
        salloc 0

        li a0,XHCL_PLIC_ID
        call plic_enable
        li a1,0x1
        call plic_set_prio

        sfree 0
        ret

xhcl_init_event_ring:
        salloc 8
        sd s1,(sp)

        ld s1,xhcl_regs

        lwu t1,RTSOFF(s1)
        li t2,0x1F
        andn t1,t1,t2
        add s1,s1,t1

        la t1,xhcl_run_regs
        sd s1,(t1)

        li a0,XHCL_EVENT_RING_SIZE
        addi a0,a0,0x7F
        call malloc
        la t0,xhcl_event_ring_malloc_address
        sd a0,(t0)
        li t0,0x7F
        andn a0,a0,t0
        la t0,xhcl_event_ring
        sd a0,(t0)

        li a0,XHCL_ERST_SIZE
        addi a0,a0,0x7F
        call malloc
        la t0,xhcl_erst_malloc_address
        sd a0,(t0)
        li t0,0x7F
        andn a0,a0,t0
        la t0,xhcl_erst
        sd a0,(t0)
        ld t0,xhcl_event_ring
        
        sd t0,0x0(a0)
        li t0,0x1000/0x1
        sw t0,0x8(a0)
        sw zero,0x12(a0)
        
        addi s1,s1,0x20

        li t0,0x1
        sw t0,ERSTSZ(s1)
        ld t0,xhcl_event_ring
        ori t0,t0,0x8
        sd t0,ERDP(s1)
        sd a0,ERSTBA(s1)

        ld s1,(sp)
        sfree 8
        ret

xhcl_setup:
        salloc 8
        sd s1,(sp)

        ld s1,xhcl_regs

        lwu t1,HCSPARAMS1(s1)
        andi t1,t1,0xFF
        la t2,xhcl_max_slots
        sb t1,(t2)
        
        ld s1,xhcl_opr_regs
        add s1,s1,t2
        li t1,XHCL_ENABLED_SLOTS
        lwu t1,CONFIG(s1)
        li t3,0xFF
        andn t2,t2,t3
        or t2,t2,t1
        
        addi t1,t1,0x1
        slli a0,t1,0x3
        call malloc
        la t0,xhcl_dcbaa
        sd a0,(t0)

        sd a0,DCBAAP(s1)

        li a0,XHCL_CR_SIZE
        addi a0,a0,0x7F
        call malloc
        la t0,xhcl_crcr_malloc_address
        sd a0,(t0)
        li t0,0x7F
        andn a0,a0,t0
        la t0,xhcl_crcr
        sd a0,(t0)

        ori a0,a0,0x1

        sd a0,CRCR(s1)

        ld s1,(sp)
        sfree 8
        ret




xhcl_init_regs:
        salloc 0

        ld t0,xhcl_regs

        lbu t1,CAPLENGTH(t0)
        add t0,t0,t1
        la t1,xhcl_opr_regs
        sd t0,(t1)

1:      lwu t1,USBSTS(t0)
        li t2,(1<<11)
        and t1,t1,t2
        bnez t1,1b

        lwu t1,USBCMD(t0)
        li t2,0x1
        andn t1,t1,t2
        sw t1,USBCMD(t0)

        fence io,io

1:      lwu t1,USBSTS(t0)
        andi t1,t1,1
        beqz t1,1b

        lwu t1,USBCMD(t0)
        li t2,0x2
        andn t1,t1,t2
        sw t1,USBCMD(t0)

1:      lwu t1,USBCMD(t0)
        andi t1,t1,0x2
        bnez t1,1b

        sfree 0
        ret

xhcl_init_pci:
        salloc 8

        li a0,XHCL_PCI_ID
        call pci_scan
        sd a0,(sp)

        li a1,0x0
        call pci_allocate_bar_to_mmio_region
        la t0,xhcl_regs
        sd a0,(t0)

        ld a0,(sp)
        lwu t0,0x4(a0)
        ori t0,t0,0x7
        sw t0,0x4(a0)

        sfree 8
        ret
