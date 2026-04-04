.include "const/fs/mount.s"
.include "const/ext2.s"
.include "const/rrip.s"

ext2_mount:
#[ci [ device_id ]
        save an=1,dn=1,sn=5
out = _d0
        
        call fs_mount_alloc
        bnez a0, 1f
        ebreak
        
1:      mv s1,a0
        sd a1,out(sp)

        li t0,1
        sw t0,fs_mount__valid_flag(s1)

        li t0,FS_MOUNT_EXT2
        sw t0,fs_mount__fs_type(s1)

        ld t0,_a0(sp)
        sd t0, fs_mount__device_id(s1)
        
        mv a0,t0
        call blk_dev_open
        break_on_error

        sd a0,fs_mount__device_handle(s1)

        li a0,1024
        call malloc
        bnez a0,1f        
        ebreak
        
1:      
        sd a0, fs_mount__superblock_data(s1)

        mv a0,s1
        call ext2_read_superblock

        ld t1, fs_mount__superblock_data(s1)

        lwu t2,s_log_block_size(t1)
        li t3,0x400
        sll t2,t3,t2

        sd t2,fs_mount__block_size(s1)

        lwu t2,s_first_ino(t1)
        sd t2,fs_mount__root_inode(s1)

        call fs_alloc_block_cache
        bnez a0,1f
        ebreak
        
1:      sd a0,fs_mount__block_cache(s1)

        call rrip_get_size

        mv s3,a0
        ld s5,fs_mount__block_cache(s1)
        ld s4,fs_mount__block_size(s1)
        li s2,0

1:      mv a0,s4
        call malloc
        bnez a0,2f
        ebreak
        
2:      sd a0,(rrip_cache__cache + rrip_cache_e__value)(s5)

        addi s2,s2,0x1
        addi s5,s5,sizeof_RRIP_CACHE_ELEMENT
        blt s2,s3,1b

        mv a0,s1
        ld a1,out(sp)
        
        restore
        ret 

ext2_read_superblock:
#[ci [ mount ]
        save an=1

        mv t0,a0
        ld a0,fs_mount__device_handle(t0)
        li a1,0x1
        ld a2,fs_mount__superblock_data(t0)
        call blk_dev_read

        restore
        ret
