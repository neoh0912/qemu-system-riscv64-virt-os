.include "const/vga/device_struct.s"
.include "const/vga/VBE.s"

bochs_init:
    save
bochs_id = 0x038011111234
    li a0,bochs_id
    la a1,bochs_init_device
    mv a2,zero
display = 0x0079616C70736964
    li a3,display
    call pci_register_driver
    restore
    ret

bochs_init_device:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device # ]
        save dn=1
        call bochs_init_pci
        sd a0,(sp)    
        call vga_boch_init
        ld a0,(sp)
        la a1,bochs_read
        la a2,bochs_write
        la a3,bochs_ioctl
        restore
        ret

bochs_read:
        ret
bochs_write:
#[ci [ device, op, ... ]
        save
        li t0,0x0
        bne a1,t0,1f
        mv a1,a2
        call bochs_write_buffer
        j 9f
1:      li t0,'s'
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        mv a3,a4
        mv a4,a5
        mv a5,a6
        call bochs_write_sprite
        j 9f
1:        
9:      restore
        ret

bochs_ioctl:
#[ci [ device, op, ... ]
        save
        li t0,0x0
        bne a1,t0,1f
        call bochs_get_resolution
        j 9f
1:      li t0,0x1
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        call bochs_set_resolution
        j 9f
1:        
9:      restore
        ret

bochs_set_resolution:
#[ci [ device, x, y ]

        sw a1,device__res_x(a0)
        sw a2,device__res_y(a0)
        ld t0,device__mmio(a0)
        
        addi t1,t0,0x500 # bochs dispi interface registers

        lhu t2,(VBE_DISPI_INDEX_ID << 1)(t1)
        li t3,0xB0C5
        beq t2,t3,1f
        #[ci [ Disable VBE Extentions ]
1:      sh zero,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        fence w,w

        #[ci [ Set resolution ]
        sh a1,(VBE_DISPI_INDEX_XRES << 1)(t1)
        sh a2,(VBE_DISPI_INDEX_YRES << 1)(t1)

        fence w,w
        
        #[ci [ Enable VBE Extentions ]
        li t0,0xc1
        sh t0,(VBE_DISPI_INDEX_ENABLE << 1)(t1)
  
        ret

bochs_get_resolution:
#[ci [ device ]
        lwu a1,device__res_y(a0)
        lwu a0,device__res_x(a0)
        ret


        
bochs_init_pci:
#[ci [ a0 = address of config space ]
        save an=1,dn=1

        li a0,sizeof_device
        call malloc
        sd a0,_d0(sp)

        ld a0,_a0(sp)
        li a1,0x0
        call pci_allocate_bar_to_mmio_region
        ld t0,_d0(sp)
        sd a0,device__fb(t0)
        
        ld a0,_a0(sp)
        li a1,0x2
        call pci_allocate_bar_to_mmio_region
        ld t0,_d0(sp)
        sd a0,device__mmio(t0)
        mv a0,t0
        restore
        ret

bochs_write_buffer:
#[ci [ device, buffer: *void ]
        ld t0,device__fb(a0)
        lwu t1,device__res_x(a0)
        lwu t2,device__res_y(a0)
        mul t1,t1,t2
        li t3,0x20
        remu t2,t1,t3
        divu t1,t1,t3

1:      ld t3,0x00(a1)
        sd t3,0x00(t0)
        ld t3,0x08(a1)
        sd t3,0x08(t0)
        ld t3,0x10(a1)
        sd t3,0x10(t0)
        ld t3,0x18(a1)
        sd t3,0x18(t0)
        ld t3,0x20(a1)
        sd t3,0x20(t0)
        ld t3,0x28(a1)
        sd t3,0x28(t0)
        ld t3,0x30(a1)
        sd t3,0x30(t0)
        ld t3,0x38(a1)
        sd t3,0x38(t0)
        ld t3,0x40(a1)
        sd t3,0x40(t0)
        ld t3,0x48(a1)
        sd t3,0x48(t0)
        ld t3,0x50(a1)
        sd t3,0x50(t0)
        ld t3,0x58(a1)
        sd t3,0x58(t0)
        ld t3,0x60(a1)
        sd t3,0x60(t0)
        ld t3,0x68(a1)
        sd t3,0x68(t0)
        ld t3,0x70(a1)
        sd t3,0x70(t0)
        ld t3,0x78(a1)
        sd t3,0x78(t0)
        addi a1,a1,0x80
        addi t0,t0,0x80
        addi t1,t1,-1
        bgtz t1,1b

1:      beqz t2,1f
        lwu t3,0x00(a1)
        sw t3,0x00(t0)
        addi a1,a1,0x4
        addi t0,t0,0x4
        addi t2,t2,-1
        j 1b
        
1:      ret
