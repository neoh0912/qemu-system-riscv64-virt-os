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

.equ VGA_XRES,1280
.equ VGA_YRES,1080
.equ VGA_BPP,32

vga_init:
    salloc 0
vga_id = 0x038011111234
    li a0,vga_id
    la a1,vga_init_device
    mv a2,zero
display = 0x0079616C70736964
    li a3,display
    call pci_register_driver
    sfree
    ret

vga_init_device:
#[ci [ a0 = address of config space , a1 = bus #, a2 = device # ]
        salloc 0
        sald 1
        call vga_init_pci
        sd a0,(sp)    
        call vga_boch_init
        ld a0,(sp)
        la a1,vga_read
        la a2,vga_write
        la a3,vga_ioctl

        sfree
        ret

vga_read:
        ret
vga_write:
        ret
vga_ioctl:
        ret

vga_boch_init:
#[ci [ device ]
fb = 0x0
mmio = 0x8
        salloc 0

        ld t0,mmio(a0)
        
        addi t1,t0,0x500 # bochs dispi interface registers

        lhu t2,(VBE_DISPI_INDEX_ID << 1)(t1)
        li t3,0xB0C5
        beq t2,t3,1f
        #[ci [ Disable VBE Extentions ]
1:      sh zero,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        fence rw,rw
        fence io,io

        #[ci [ Set resolution and bit depth]
        li t0,VGA_XRES
        sh t0,(VBE_DISPI_INDEX_XRES << 1)(t1)
        li t0,VGA_YRES
        sh t0,(VBE_DISPI_INDEX_YRES << 1)(t1)
        li t0,VGA_BPP
        sh t0,(VBE_DISPI_INDEX_BPP << 1)(t1)

        fence rw,rw
        fence io,io
        
        #[ci [ Enable VBE Extentions ]
        li t0,0xc1
        sh t0,(VBE_DISPI_INDEX_ENABLE << 1)(t1)

        

        sfree
        ret

vga_init_pci:
#[ci [ a0 = address of config space ]
fb = 0x0
mmio = 0x8
        salloc 16
        sd a0,(sp)

        li a0,0x10
        call malloc
        sd a0,0x8(sp)

        ld a0,(sp)
        li a1,0x0
        call pci_allocate_bar_to_mmio_region
        ld t0,0x8(sp)
        sd a0,fb(t0)
        
        ld a0,(sp)
        li a1,0x2
        call pci_allocate_bar_to_mmio_region
        ld t0,0x8(sp)
        sd a0,mmio(t0)
        mv a0,t0
        sfree
        ret
