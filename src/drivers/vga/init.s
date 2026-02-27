.equ VGA_ID,0x11111234

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

        call vga_init_pci

        call vga_boch_init

        li a0,4*1280*1080
        call malloc

        la t0,vga_buffer
        sd a0,(t0)

        sfree
        ret

vga_boch_init:
        salloc 0
        la t0,vga_mmio_ptr
        ld t0,(t0)
        
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
        salloc 16

        li a0,VGA_ID
        call pci_scan
        sd a0,(sp)

        li a1,0x0
        call pci_allocate_bar_to_mmio_region
        la t0,vga_frame_buffer_ptr
        sd a0,(t0)
        
        ld a0,(sp)

        li a1,0x2
        call pci_allocate_bar_to_mmio_region
        la t0,vga_mmio_ptr
        sd a0,(t0)
        
        sfree
        ret
