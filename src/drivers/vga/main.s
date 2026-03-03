sizeof_device = 0x18
.equ VBE_DISPI_INDEX_ID, 0
.equ VBE_DISPI_INDEX_XRES, 1
.equ VBE_DISPI_INDEX_YRES, 2
.equ VBE_DISPI_INDEX_BPP, 3
.equ VBE_DISPI_INDEX_ENABLE, 4
.equ VBE_DISPI_INDEX_BANK, 5
.equ VBE_DISPI_INDEX_VIRT_WIDTH, 6
.equ VBE_DISPI_INDEX_VIRT_HEIGHT, 7
.equ VBE_DISPI_INDEX_X_OFFSET, 8
.equ VBE_DISPI_INDEX_Y_OFFSET, 9

.equ VGA_XRES,640
.equ VGA_YRES,480
.equ VGA_BPP,32

vga_init:
    save
vga_id = 0x038011111234
    li a0,vga_id
    la a1,vga_init_device
    mv a2,zero
display = 0x0079616C70736964
    li a3,display
    call pci_register_driver
    restore
    ret

vga_init_device:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device # ]
        save dn=1
        call vga_init_pci
        sd a0,(sp)    
        call vga_boch_init
        ld a0,(sp)
        la a1,vga_read
        la a2,vga_write
        la a3,vga_ioctl
        restore
        ret

vga_read:
        ret
vga_write:
#[ci [ device, op, ... ]
        save
        li t0,0x0
        bne a1,t0,1f
        mv a1,a2
        call vga_write_buffer
        j 9f
1:      li t0,'s'
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        mv a3,a4
        mv a4,a5
        mv a5,a6
        call vga_write_sprite
        j 9f
1:        
9:      restore
        ret

vga_ioctl:
#[ci [ device, op, ... ]
        save
        li t0,0x0
        bne a1,t0,1f
        call vga_get_resolution
        j 9f
1:      li t0,0x1
        bne a1,t0,1f
        mv a1,a2
        mv a2,a3
        call vga_set_resolution
        j 9f
1:        
9:      restore
        ret

vga_boch_init:
#[ci [ device ]
fb = 0x0
mmio = 0x8
res_x = 0x10
res_y = 0x14
        save
        
        ld t0,mmio(a0)
        
        addi t1,t0,0x500 # bochs dispi interface registers

        lhu t2,(VBE_DISPI_INDEX_ID << 1)(t1)
        li t3,0xB0C5
        beq t2,t3,1f
        #[ci [ Disable VBE Extentions ]
1:      sh zero,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        fence w,w

        #[ci [ Set resolution and bit depth]
        li t0,VGA_XRES
        sw t0,res_x(a0)
        sh t0,(VBE_DISPI_INDEX_XRES << 1)(t1)
        li t0,VGA_YRES
        sw t0,res_y(a0)
        sh t0,(VBE_DISPI_INDEX_YRES << 1)(t1)
        li t0,VGA_BPP
        sh t0,(VBE_DISPI_INDEX_BPP << 1)(t1)

        fence w,w
        
        #[ci [ Enable VBE Extentions ]
        li t0,0xc1
        sh t0,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        restore
        ret

vga_set_resolution:
#[ci [ device, x, y ]
mmio = 0x8
res_x = 0x10
res_y = 0x14
        sw a1,res_x(a0)
        sw a2,res_y(a0)
        ld t0,mmio(a0)
        
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

vga_get_resolution:
#[ci [ device ]
res_x = 0x10
res_y = 0x14
        lwu a1,res_y(a0)
        lwu a0,res_x(a0)
        ret


        
vga_init_pci:
#[ci [ a0 = address of config space ]
fb = 0x0
mmio = 0x8
res_x = 0x10
res_y = 0x14
        save an=1,dn=1

        li a0,sizeof_device
        call malloc
        sd a0,_d0(sp)

        ld a0,_a0(sp)
        li a1,0x0
        call pci_allocate_bar_to_mmio_region
        ld t0,_d0(sp)
        sd a0,fb(t0)
        
        ld a0,_a0(sp)
        li a1,0x2
        call pci_allocate_bar_to_mmio_region
        ld t0,_d0(sp)
        sd a0,mmio(t0)
        mv a0,t0
        restore
        ret

vga_write_buffer:
#[ci [ device, buffer: *void ]
fb = 0x0
res_x = 0x10
res_y = 0x14
        ld t0,fb(a0)
        lwu t1,res_x(a0)
        lwu t2,res_y(a0)
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
