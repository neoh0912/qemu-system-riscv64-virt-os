#[ci    [DEFINES]
.equ    PCI_ECAM,    0x30000000
.equ    PCI_MMIO_32, 0x40000000
.equ    PCI_MMIO_64, 0x4000000000

#[c     [LOCALS]


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
        la t2, pci_mmio_ptr
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

pci_register_driver:
#[ci [ a0 = id: device_id,  a1 = *driver: call , a2 = *free: call]
#[c  device_id = (CLASS_CODE)[40-47](SUB_CLASS)[32-39]
#[c               (DEVICE_ID)[16-31](VENDOR_ID)[0-15]

pci_id = 0x0
class_code = 0x4
driver = 0x08
next = 0x10
free = 0x18
 
        salloc 16
        sd a0,(sp)

#[g -- Allocate pci_driver structure --
        
        li a0,0x20
        call zalloc
        sd a0,0x8(sp)
        
        sd a1,driver(a0)
        sd a2,  free(a0)

#[g -- Seperate device_id into pci_id and class codes --

        li t0,0xFFFFFFFF
        ld t1,(sp)
        and t0,t1,t0
        
        sw t0,pci_id(a0)
        srli t0,t1,0x20
        sh t0,class_code(a0)

#[g -- Add pci_driver to linked list --

        ld t0,pci_drivers
        beqz t0,1f
        sd a0,next(a0)
        j 2f
1:      sd t0,next(a0)
2:      la t0,pci_drivers
        sd a0,(t0)

        sfree 16
        ret

pci_scan:

pci_id = 0x0
class_code = 0x4
driver = 0x08
next = 0x10
free = 0x18

        salloc 32
        sd s1,0x0(sp)
        sd s2,0x8(sp)
        sd s3,0x10(sp)

        li s1,0x0
1:      li s2,0x0

#[g -- Get pci_id, class codes from corresponding address --
2:      mv a0,s1  
        mv a1,s2
        li a2,0x0
        li a3,0x0
        call pci_config
        lwu t0,(a0)
#[g -- Loop through drivers --
        lwu t1,0x8(a0)
        srli t1,t1,0x10
        ld s3,pci_drivers
        
4:      lwu t2,pci_id(s3)
        bne t2,t0,3f
        lwu t2,class_code(s3)
        bne t2,t1,3f

        ld t2,driver(s3)
        mv a1,s1
        mv a2,s2
        jalr ra,t2,0x0
        j 4f   

3:      mv t2,s3
        ld s3,next(t2)
        bne s3,t2,4b
        

4:      addi s2,s2, 0x1
        li t0,32
        blt s2,t0,2b

        addi s1,s1, 0x1         #[gi[Branch if bus < 255]
        li t0,255
        blt s1,t0,1b
        
1:      ld s1, 0x0(sp)
        ld s2, 0x8(sp)
        ld s3, 0x10(sp)
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
