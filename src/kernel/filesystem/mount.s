.include "const/fs/mount.s"
.include "const/fs/block_cache.s"

fs_mount_alloc:
        save

        la t0,fs_mounted_filesystems
        li t1,0x0
        li t2,16
        
1:      lwu t3,(t0)
        beqz t3,1f

        addi t1,t1,0x1
        addi t0,t0,sizeof_fs_mount
        blt t1,t2,1b

        ebreak
        
1:      mv a0,t0
        mv a1,t1
        restore
        ret

fs_alloc_block_cache:
#[ci [ mount ]
        save an=1,sn=3

        li a0,BLOCK_CACHE_SIZE
        call rrip_create

        restore
        ret
