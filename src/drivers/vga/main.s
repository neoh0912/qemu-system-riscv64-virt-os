.include "const/vga/device_struct.s"
.include "const/vga/VBE.s"

VGA_XRES = 640
VGA_YRES = 480
VGA_BPP = 0x20

#vga_init:
#        save
#vga_id = 0x030011111234
#        li a0,vga_id
#        la a1,vga_init_device
#        mv a2,zero
#display = 0x0079616C70736964
#        li a3,display
#        call pci_register_driver
#        restore
#        ret
#
#vga_init_device:
#        save dn=1
#    
#        call vga_init_pci
#        sd a0,_d0(sp)
#
#        ld a0,_d0(sp)
#        la a1,vga_read
#        la a2,vga_write
#        la a3,vga_ioctl
#        restore
#        ret
#
#vga_init_pci:
#        save an=1,dn=1
#    
#        li a0,sizeof_device
#        call malloc
#        sd a0,_d0(sp)
#
#        ld a0,_a0(sp)
#        li a1,0x0
#        call pci_allocate_bar_to_mmio_region
#        ld t0,_d0(sp)
#        sd a0,device__fb(t0)
#
#        ld a0,_a0(sp)
#        li a1,0x2
#        call pci_allocate_bar_to_mmio_region
#        ld t0,_d0(sp)
#        sd a0,device__mmio(t0)
#        mv a0,t0
#
#        restore
#        ret
#
vga_boch_init:
#[ci [ device ]
        save
        
        ld t0,device__mmio(a0)
        
        addi t1,t0,0x500 # bochs dispi interface registers

        lhu t2,(VBE_DISPI_INDEX_ID << 1)(t1)
        li t3,0xB0C5
        beq t2,t3,1f
        #[ci [ Disable VBE Extentions ]
1:      sh zero,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        fence w,w

        #[ci [ Set resolution and bit depth]
        li t0,VGA_XRES
        sw t0,device__res_x(a0)
        sh t0,(VBE_DISPI_INDEX_XRES << 1)(t1)
        li t0,VGA_YRES
        sw t0,device__res_y(a0)
        sh t0,(VBE_DISPI_INDEX_YRES << 1)(t1)
        li t0,VGA_BPP
        sh t0,(VBE_DISPI_INDEX_BPP << 1)(t1)

        fence w,w
        
        #[ci [ Enable VBE Extentions ]
        li t0,0xc1
        sh t0,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        restore
        ret
