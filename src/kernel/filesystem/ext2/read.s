.include "const/fs/mount.s"
.include "const/fs/block_cache.s"
ext2_read:
#[ci [ mount, block ]
        save an=2,sn=3
        bnez a1,1f
        
        ld a0,fs_mount__superblock_data(a0)
        j 9f

1:      ld a0,fs_mount__block_cache(a0)
        call rrip_get
        bnez a1,9f

        mv s1,a0
        call rrip_invisable_get
        bnez a0,1f

        ld a0,_a0(sp)
        ld a0,fs_mount__block_size(a0)
        call malloc
        bnez a0,2f
        ebreak
        
2:      mv a2,a0
        mv a0,s1
        ld a1,_a1(sp)
        call rrip_set
        mv s2,a2
        j 3f
        
1:      mv s2,a0
3:      mv a2,s2
        ld a0,_a0(sp)
        ld a0,fs_mount__device_handle(a0)
        ld a1,_a1(sp)
        call blk_dev_read
        mv a0,s2
        j 9f

9:      restore
        ret
