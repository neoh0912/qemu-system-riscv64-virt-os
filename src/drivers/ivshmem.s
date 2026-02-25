#[ci    [DEFINES]

#ivshmem_init:
#        salloc 16
#
#                                    #[gi[ Prep for pci_scan call ]
#        li a0,0x11101AF4
#        call pci_scan
#        sd a0,(sp)
#        sd a1,8(sp)
#        li t1,0x1AF4
#        xor t0,a0,t1
#        bnez t0,1f
#        li a0,E_ERROR
#        la a1,ivshmem_device_not_found_error_Message
#        ecall
#        
#1:      li a2,0x0
#        li a3,0x18
#        call pci_config
#        li t0,0xFFFFFFFF
#        sw t0,(a0)
#        fence rw,rw
#        lwu t0,(a0)
#        srli t0,t0,4
#        slli t0,t0,4
#        ctz t0,t0
#        li t5,0x1
#        sll a0,t5,t0                   #[gi[ calculate size ]
#        la t0,ivshmem_size
#        sd a0,(t0)
#
#        la t0,ivshmem_ptr
#        la t1,pci_mmio_ptr
#        ld t2,(t1)
#        sd t2,(t0)
#        mv a4,t2
#        add t2,t2,a0
#        sd t2,(t1)
#        ld a0,(sp)
#        ld a1,8(sp)
#        li a2,0x0
#        li a3,0x18
#        call pci_write_config
#        li a4,0x0
#        li a3,0x1c
#        call pci_write_config
#        fence i,o
#        
#        li a3,0x04
#        call pci_read_config
#        ori a4,a0,0x2
#        ld a0,(sp)
#        call pci_write_config
#
#        sfree 16
#        ret

ivshmem_address_out_of_bounds_error:
        salloc 16
        la t0,ivshmem_size
        ld t0,(t0)
        addi t0,t0,-0x1
        sd t0,(sp)
        sd t2,8(sp)

        li a0,E_ERROR
        la a1,ivshmem_address_out_of_bounds_error_Message
        mv a2,sp
        ecall

        sfree 16
        ret


#[ri    [   8B   ]
ivshmem_sd:
#[ci [a0 = local address, a1 = source, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t4,t0
        add t0,t0,a0
        addi t1,a1,0x0
        slli t2,a2,0x3
        add t2,t0,t2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        blt t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      ld t4,(t1)
        sd t4,(t0)
        addi t1,t1,0x8
        addi t0,t0,0x8
2:      blt t0,t2,1b
        ret

ivshmem_ld:
#[ci [a0 = local address, a1 = dest, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        slli t2,a2,0x3
        add t2,t0,t2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        blt t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      ld t4,(t0)
        sd t4,(t1)
        addi t1,t1,0x8
        addi t0,t0,0x8
2:      blt t0,t2,1b
        ret

#[ri    [   4B   ]
ivshmem_sw:
#[ci [a0 = local address, a1 = source, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        slli t2,a2,0x2
        add t2,t0,t2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        blt t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      lwu t4,(t1)
        sw t4,(t0)
        addi t1,t1,0x4
        addi t0,t0,0x4
2:      blt t0,t2,1b
        ret
ivshmem_lwu:
#[ci [a0 = local address, a1 = dest, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        slli t2,a2,0x2
        add t2,t0,t2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        blt t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      lwu t4,(t0)
        sw t4,(t1)
        addi t1,t1,0x4
        addi t0,t0,0x4
2:      blt t0,t2,1b
        ret

#[ri    [   2B   ]
ivshmem_sh:
#[ci [a0 = local address, a1 = source, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        slli t2,a2,0x1
        add t2,t0,t2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        blt t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      lhu t4,(t1)
        sh t4,(t0)
        addi t1,t1,0x2
        addi t0,t0,0x2
2:      blt t0,t2,1b
        ret
ivshmem_lhu:
#[ci [a0 = local address, a1 = dest, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        slli t2,a2,0x1
        add t2,t0,t2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        blt t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      lhu t4,(t0)
        sh t4,(t1)
        addi t1,t1,0x2
        addi t0,t0,0x2
2:      blt t0,t2,1b
        ret

#[ri    [   1B   ]
ivshmem_sb:
#[ci [a0 = local address, a1 = source, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        add t2,t0,a2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        ble t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      lbu t4,(t1)
        sb t4,(t0)
        addi t1,t1,0x1
        addi t0,t0,0x1
2:      blt t0,t2,1b
        ret
ivshmem_lbu:
#[ci [a0 = local address, a1 = dest, a2, len]
        la t0,ivshmem_ptr
        ld t0,(t0)
        mv t3,t0
        add t0,t0,a0
        addi t1,a1,0x0
        add t2,t0,a2
        la t4,ivshmem_size
        ld t4,(t4)
        add t3,t3,t4
        ble t2,t3,1f
        call ivshmem_address_out_of_bounds_error
        j 2f
1:      lbu t4,(t0)
        sb t4,(t1)
        addi t1,t1,0x1
        addi t0,t0,0x1
2:      blt t0,t2,1b
        ret

