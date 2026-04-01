.include "cosnt/fs/mount.s"
.include "const/fs/block_cache.s"
ext2_read:
#[ci [ mount, block ]
        save an=2,sn=3

        bnez a1,1f
        ld a0,fs_mount__superblock_data(a0)
        j 9f

1:      ld t0,fs_mount__block_cache(a0)
        li s1,0x0
        li s2,BLOCK_CACHE_SIZE
        
1:      ld t1,block_cache__tag(t0)

        bne t1,a1,2f

        ld a0,block_cache__buffer(t0)
        j 9f
        
2:      addi s1,s1,0x1
        addi t0,t0,sizeof_block_cache
        blt s1,s2,1b

        

9:      restore
        ret
