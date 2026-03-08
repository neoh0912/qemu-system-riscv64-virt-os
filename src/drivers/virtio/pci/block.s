virtio_pci_block_device_init:
VIO_PCI_BLOCK_DEVICE_ID = 0x01801042f4
        save
        li a0,VIO_PCI_BLOCK_DEVICE_ID
        la a1,virtio_pci_block_device_init_device
        mv a2,zero
blkdrive = 0x65766972646B6C62
        li a3,blkdrive
        call pci_register_driver
        restore
        ret        
        
virtio_pci_block_device_init_device:
        
