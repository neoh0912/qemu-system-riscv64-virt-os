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

        li a0,(BLOCK_CACHE_SIZE * sizeof_block_cache)
        call malloc
        bnez a0,1f
        ebreak
        
1:      li a2,(BLOCK_CACHE_SIZE * sizeof_block_cache)
        li a1,0x0
        call memset
        mv s1,a0

        li s2,0x0
        li s3,BLOCK_CACHE_SIZE

1:      ld a0,_a0(sp)
        ld a0,fs_mount__block_size(a0)
        call malloc
        bnez a0,2f
        ebreak

2:      li t0,sizeof_block_cache
        mul t0,s2,t0
        add t0,t0,s1
#        sd a0,block_cache__(t0)

        addi s2,s2,0x1
        blt s2,s3,1b        

        restore
        ret
