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
    call display_open
    break_on_error
    mv s5,a0
    
    call display_get_resolution
    break_on_error
    mul a0,a0,a1
    slli a0,a0,0x2
    mv s10,a0
    call malloc
    mv s11,a0
    li a1,0xFF
    mv a2,s10
    call memset
    mv a1,s11
    mv a0,s5
    call display_write_buffer
    break_on_error

    mv a0,s11
    call free

    li s1,0x0
    li s2,0x0

#loop:
    j bounce
#j loop

