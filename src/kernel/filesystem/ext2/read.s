.include "const/fs/mount.s"
.include "const/fs/block_cache.s"
ext2_read_block:
#[ci [ mount, block , buffer]
        save an=3,sn=3
        bnez a1,1f
        
        ld a0,fs_mount__superblock_data(a0)
        j 9f

1:      ld a0,fs_mount__block_cache(a0)
        call rrip_get
        bnez a1,9f

        mv s1,a0
        call rrip_invisable_get
        
        mv a2,a0
        mv a0,s1
        ld a1,_a1(sp)
        call rrip_set
        mv s2,a2
        ld a0,_a0(sp)
        ld a0,fs_mount__device_handle(a0)
        call blk_dev_read

        
        mv a1,s2
        ld a0,_a2(sp)
        
        ld t0,_a0(sp)
        ld t0,fs_mount__block_size(t0)
        srli t1,t0,0x3
        li t0,0x0

1:      ld t2,(a1)
        sd t2,(a0)

        addi a1,a1,0x8
        addi a0,a0,0x8

        addi t0,t0,0x1
        blt t0,t1,1b

        restore
        ret
