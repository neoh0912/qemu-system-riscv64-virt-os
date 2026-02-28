.global _start
_start:

    la sp, stack_pointer

    la t0,_bss_start
    la t1,_bss_end
    bge t0,t1,2f
1:  sw zero,(t0)
    addi t0,t0,0x4
    blt t0,t1,1b
2:

    
    call machine_init
    call kernel_heap_init
    call uart_init
    call pci_init
    call device_manager_init

    call virtio_pci_keyboard_init
    call vga_init

    la a0,pci_scan
    call device_manager_register_device_scanner

    call device_manager_scan

    li a0,0x0
    li a1,1280
    la a2,1080
    call display_set_resolution

    li a0,1280*1080*4
    call malloc
    mv s11,a0
    li a1,0xFF
    li a2,1280*1080*4
    call memset
    mv a1,s11
    li a0,0x0
    call display_write_buffer

loop:
    wfi
j loop

