#[ci    [DEFINES]
.equ    PCI_ECAM,    0x30000000
.equ    PCI_MMIO_32, 0x40000000
.equ    PCI_MMIO_64, 0x4000000000

#[mi    [CODE]

pci_allocate_bar_to_mmio_region:
#[ci [ a0 = address, a1 = bar ]
        salloc 16
        sd a0,(sp)
        sd a1,0x8(sp)

        addi t0,a0,0x10
        slli t1,a1,0x2
        add t0,t0,t1

        lwu t1,(t0)
        andi t2,t1,0x6

        beqz t2,1f

        addi t1,t0,0x4
        sw zero,(t1)

1:      li t1,0xFFFFFFFF
        sw t1,(t0)
        fence io,io
        fence rw,rw
        lwu t1,(t0)
        li t2,0xF
        andn t1,t1,t2
        ctz t1,t1
        li t2,0x1
        sll t1,t2,t1
        la t2,pci_mmio_ptr
        ld t3,(t2)

        addi t4,t1,-1
        add t3,t3,t4
        andn t3,t3,t4

        mv a0,t3

        sd t3,(t0)
        add t3,t3,t1
        sd t3,(t2)
        fence io,io

        ld t1,(sp)
        addi t0,t1,0x4
        lwu t1,(t0)
        ori t1,t1,0x2
        sw t1,(t0)
        fence io,io
       
        sfree 16
        ret

pci_init:
        la t0,pci_mmio_ptr
        li t1,PCI_MMIO_32
        sd t1,(t0)
        ret

pci_get_bar_address:
#[ci [ a0 = address, a1 = bar ]
        salloc 0

        addi t0,a0,0x10
        slli t1,a1,0x2
        add t0,t0,t1

        lwu a0,(t0)
        li t0,0xF
        andn a0,a0,t0

        sfree 0
        ret

pci_scan:
#[ci    [ a0 = packed ids ]
        salloc 32
        sd s1, 0(sp)
        sd s2, 8(sp)
        sd s3,16(sp)

        mv s3,a0

        li s1,0x0
1:      li s2,0x0

2:      mv a0,s1                #[gi[Prep function arguments for read config]
        mv a1,s2
        li a2,0x0
        li a3,0x0
        call pci_config
        lwu t0,(a0)
        beq t0,s3,1f

        addi s2,s2, 0x1
        li t0,32
        blt s2,t0,2b

        addi s1,s1, 0x1         #[gi[Branch if bus < 255]
        li t0,255
        blt s1,t0,1b
        
1:      ld s3,24(sp)
        ld s1, 0(sp)
        ld s2, 8(sp)
        sfree 32
        ret

pci_config:
#[ci    [ a0 = bus, a1 = slot, a2 = func, a3 = offset ]
        li t2,0xFFC
        li t0, PCI_ECAM
        slli t1,a0,20
        or t0,t0,t1
        slli t1,a1,15
        or t0,t0,t1
        slli t1,a2,12
        or t0,t0,t1
        and t1,a3,t2
        or a0,t0,t1 
        ret
