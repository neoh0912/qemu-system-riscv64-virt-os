.include "const/vga/device_struct.s"
.include "const/vga/VBE.s"

VGA_IO_PORTS = 0x400 - 0x3c0
VGA_SEQ = 0x3C4
VGA_CRT = 0x3D4
VGA_GC = 0x3CE
VGA_AC = 0x3c0

VGA_TEXT_MODE_OFFSET = 0x18000

VGA_XRES = 720
VGA_YRES = 400
VGA_BPP = 0x20

vga_init:
        save
vga_id = 0x030011111234
        li a0,vga_id
        la a1,vga_init_device
        mv a2,zero
display = 0x0079616C70736964
        li a3,display
        call pci_register_driver
        restore
        ret



vga_init_device:
        save dn=1
    
        call vga_init_pci
        sd a0,_d0(sp)

        call vga_init_regs

        ld a0,_d0(sp)

        li t0,0x0F41
        ld t1,device__fb(a0)
        li t2,VGA_TEXT_MODE_OFFSET
        add t1,t1,t2
        sh t0,(t1)


        ld a0,_d0(sp)
        la a1,vga_read
        la a2,vga_write
        la a3,vga_ioctl
        restore
        ret

.macro vga_write_io port index value
        li t0,(((\value) << 8) + (\index))
        sh t0,(VGA_IO_PORTS + (\port))(s1)
.endm

vga_load_font:
#[ci [ device ]
        save an=0,sn=7

        ld s1,device__mmio(a0)

        vga_write_io VGA_SEQ,0x02,0x04
        vga_write_io VGA_SEQ,0x04,0x07

        vga_write_io VGA_GC,0x04,0x02
        vga_write_io VGA_GC,0x05,0x00
        vga_write_io VGA_GC,0x06,0x00

        li s2,0x0
        li s3,0x100

        ld s6,device__fb(a0)
        la s7,VGA_FONT_DATA

1:      li s4,0x0
        li s5,0x10

2:      lbu t0,(s7)
        sb t0,(s6)

        addi s4,s4,0x1
        addi s6,s6,0x1
        addi s7,s7,0x1
        blt s4,s5,2b

        addi s2,s2,0x1
        addi s6,s6,0x10
        blt s2,s3,1b

        vga_write_io VGA_SEQ,0x02,0x03
        vga_write_io VGA_SEQ,0x04,0x03

        vga_write_io VGA_GC,0x04,0x00
        vga_write_io VGA_GC,0x05,0x10
        vga_write_io VGA_GC,0x06,0x0E

        restore
        ret

vga_init_regs:
#[ci [ device ]
        save an=1,sn=1

        ld s1,device__mmio(a0)

        vga_write_io VGA_SEQ,0,1
        vga_write_io VGA_CRT,0x11,0x8E

        lbu t0,(VGA_IO_PORTS+0x3DA)(s1)

        li t0,0x0
        li t1,0xF
        la t2,VGA_PALETTE

1:      lbu t0,(VGA_IO_PORTS+0x3DA)(s1)
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        lbu t3,(t2)
        sb t3,(VGA_IO_PORTS+VGA_AC)(s1)

        addi t0,t0,0x1
        addi t2,t2,0x1
        blt t0,t1,1b

        li t0,0x10
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        li t0,0x0C
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)

        li t0,0x11
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        li t0,0x00
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)

        li t0,0x12
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        li t0,0x0F
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)

        li t0,0x13
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        li t0,0x08
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)

        li t0,0x14
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        li t0,0x00
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)
        


        li t0,(0x67)
        sb t0,(VGA_IO_PORTS+0x3C2)(s1)
        
        vga_write_io VGA_SEQ,0x1,0x0
        vga_write_io VGA_SEQ,0x2,0x3
        vga_write_io VGA_SEQ,0x3,0x0
        vga_write_io VGA_SEQ,0x4,0x7

        vga_write_io VGA_CRT,0x0,0x5F
        vga_write_io VGA_CRT,0x1,0x4F
        vga_write_io VGA_CRT,0x2,0x50
        vga_write_io VGA_CRT,0x3,0x82
        vga_write_io VGA_CRT,0x4,0x55
        vga_write_io VGA_CRT,0x5,0x81

        vga_write_io VGA_CRT,0x6,0xBF
        vga_write_io VGA_CRT,0x7,0x1F
        
        vga_write_io VGA_CRT,0x8,0x00
        vga_write_io VGA_CRT,0x9,0x4F

        vga_write_io VGA_CRT,0xA,0x0D
        vga_write_io VGA_CRT,0xB,0x0E

        vga_write_io VGA_CRT,0x10,0x9C
        vga_write_io VGA_CRT,0x12,0x8F
        vga_write_io VGA_CRT,0x13,0x28
        vga_write_io VGA_CRT,0x14,0x1F
        vga_write_io VGA_CRT,0x15,0x96
        vga_write_io VGA_CRT,0x16,0xB9
        vga_write_io VGA_CRT,0x17,0xA3


        vga_write_io VGA_GC,0x5,0x10
        vga_write_io VGA_GC,0x6,0x0E

        call vga_load_font

        li t0,0x20
        sb t0,(VGA_IO_PORTS+VGA_AC)(s1)

        vga_write_io VGA_SEQ,0x0,0x3
        
        restore
        ret

vga_read:
        ret
vga_write:
        ret
vga_ioctl:
        ret

vga_init_pci:
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
