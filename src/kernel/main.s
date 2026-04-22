kernel_start:
    save

    call device_manager_scan

    



    call bounce

    restore
    ret
