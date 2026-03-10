#[ci    [DEFINES]
.equ    PCI_ECAM,    0x30000000
.equ    PCI_MMIO_32, 0x40000000
.equ    PCI_MMIO_64, 0x4000000000
.include "const/pci/driver.s"

#[c     [LOCALS]


#[mi    [CODE]

pci_set_interrupt_line:
#[ci [ a0 = address, a1 = line ]
        lwu t0,0x3c(a0)
        li t1,0xFF
        andn t0,t0,t1
        and t1,a1,t1
        or t0,t0,t1
        sw t0,0x3c(a0)
        ret

pci_get_plic_id:
#[ci [ a0 = address, a1 = device number ]
        lwu t0,0x3c(a0)
        srli t0,t0,0x8
        andi t0,t0,0xFF
        addi t0,t0,-1
        add t0,t0,a1
        li t1,0x4
        remu t0,t0,t1
        addi a0,t0,0x20
        ret

pci_allocate_bar_to_mmio_region:
#[ci [ a0 = address, a1 = bar ]
        save an=1

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

        ld t1,_a0(sp)
        addi t0,t1,0x4
        lwu t1,(t0)
        ori t1,t1,0x2
        sw t1,(t0)
        fence io,io
       
        restore
        ret

pci_init:
#[g -- allocate pci_handlers --
        save
        li a0,0x20
        call malloc
        la t0,pci_handlers
        sd a0,(t0)
        li a2,0x20
        mv a1,zero
        call memset

        la t0,pci_mmio_ptr
        li t1,PCI_MMIO_32
        sd t1,(t0)

        restore
        ret

pci_get_bar_address:
#[ci [ a0 = address, a1 = bar ]
        save
        addi t0,a0,0x10
        slli t1,a1,0x2
        add t0,t0,t1

        lwu a0,(t0)
        li t0,0xF
        andn a0,a0,t0

        restore
        ret

pci_register_driver:
#[ci [ a0 = id: device_id,  a1 = *driver: call , a2 = *free: call, a3 = device_type: v char[8]]
#[c  device_id = (CLASS_CODE)[40-47](SUB_CLASS)[32-39]
#[c               (DEVICE_ID)[16-31](VENDOR_ID)[0-15]

        save an=4,dn=1

#[g -- Allocate pci_driver structure --
        
        li a0,sizeof_driver
        call malloc
        li a2,0x20
        mv a1,zero
        call memset

        ld t0,_a1(sp)
        sd t0,driver__driver(a0)
        ld t0,_a2(sp)
        sd t0,driver__free(a0)
        ld t0,_a3(sp)
        sd t0,driver__device_id(a0)

#[g -- Seperate device_id into pci_id and class codes --

        li t0,0xFFFFFFFF
        ld t1,_a0(sp)
        and t0,t1,t0
        
        sw t0,driver__pci_id(a0)
        srli t0,t1,0x20
        sh t0,driver__class_code(a0)

#[g -- Add pci_driver to linked list --

        la t0,pci_drivers
        ld t1,(t0)
        sd t1,driver__next(a0)
        sd a0,(t0)

        restore
        ret

pci_scan:
        save sn=3

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

        ebreak
4:      lwu t2,driver__pci_id(s3)
        bne t2,t0,3f
        lwu t2,driver__class_code(s3)
        bne t2,t1,3f

        ld t2,driver__driver(s3)
        mv a1,s1
        mv a2,s2
        jalr ra,t2,0x0
        ld a4,driver__device_id(s3)
        call device_manager_register_device
        ebreak
        j 4f   

3:      ebreak
        ld s3,driver__next(s3)
#        ebreak
        bnez s3,4b
        

4:      addi s2,s2, 0x1
        li t0,32
        blt s2,t0,2b

        addi s1,s1, 0x1         #[gi[Branch if bus < 255]
        li t0,255
        blt s1,t0,1b
        
1:      restore
        ret

pci_register_callback:
#[ci [ a0 = *device: device_specific_struct, a1 = *callback: call, a2 = iqr ]
        save an=3
#[g -- allocate pci_handler --

device = 0x0
callback = 0x8
next = 0x10

        li a0,0x18
        call malloc
        li a2,0x18
        mv a1,zero
        call memset
        
        ld t0,_a0(sp)
        sd t0,device(a0)
        ld t0,_a1(sp)
        sd t0,callback(a0)
        ld t0,_a2(sp)
        addi t0,t0,-0x20
        slli t0,t0,0x3
        la t1,pci_handlers
        add t0,t0,t1
        ld t1,(t0)
        
#[g -- link handler --
                
        bnez t1,1f
        mv t1,a0
1:      sd t1,next(a0)
        sd a0,(t0)
        
        restore
        ret

pci_dispatch_interrupt:
#[ci [ a0 = IRQ ID ]
device = 0x0
callback = 0x8
next = 0x10
        save an=1,sn=1

        la t0,pci_handlers
        addi t1,a0,-0x20
        slli t1,t1,0x3

        add t0,t0,t1
        ld s1,(t0)

1:      ld t0,callback(s1)
        ld a1,_a0(sp)
        ld a0,device(s1)

        jalr ra,t0,0x0
        beqz a0,1f
        mv t0,s1
        ld s1,0x10(t0)
        bne s1,t0,1b

1:      restore
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
