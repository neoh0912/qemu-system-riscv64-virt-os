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
#    call ivshmem_init
#    call vga_init
#    call xhcl_init

    .equ VIO_PCI_INPUT_ID, 0x090010521af4
    li a0,VIO_PCI_INPUT_ID
    la a1,virtio_pci_keyboard_init
    call pci_register_driver
    call pci_scan    

loop:
    wfi
j loop

