.global _start
_start:
    la sp, stack_pointer

    la t0,_bss_start
    la t1,_bss_end
    bge t0,t1,2f
1:  sd zero,(t0)
    addi t0,t0,0x8
    blt t0,t1,1b
2:

    call machine_init
    call kernel_heap_init
    call uart_init
    call pci_init
    call device_manager_init

    call virtio_pci_keyboard_init
    call virtio_pci_blk_init
    call bochs_init    

    la a0,pci_scan
    call device_manager_register_device_scanner

    call device_manager_scan

    call device_manager_print_devices

    call test_ext2

1:
    wfi
j 1b
