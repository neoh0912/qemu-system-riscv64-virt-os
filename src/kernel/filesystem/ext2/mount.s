.include "const/fs/mount.s"
.include "const/ext2.s"

ext2_mount:
#[ci [ device_id ]
        save an=1,dn=2
fs_mount = _d0
out = _d1
        
        call fs_mount_alloc
        bnez a0, 1f
        ebreak
        
1:      sd a0,fs_mount(sp)
        sd a1,out(sp)

        li t0,1
        sw t0,fs_mount__valid_flag(a0)

        li t0,0x2
        sd t0,fs_mount__root_inode(a0)

        li t0,FS_MOUNT_EXT2
        sw t0,fs_mount__fs_type(a0)

        ld t0,_a0(sp)
        sd t0, fs_mount__device_id(a0)
        mv a0,t0
        call blk_dev_open
        break_on_error

        ld t0,fs_mount(sp)
        sd a0,fs_mount__device_handle(t0)

        li a0,1024
        call malloc
        bnez a0,1f        
        ebreak
        
1:      
        ld t0,fs_mount(sp)
        sd a0, fs_mount__superblock_data(t0)

        mv a0,t0
        call ext2_read_superblock

        ld t0,fs_mount(sp)
        ld t1, fs_mount__superblock_data(t0)

        lwu t2,s_log_block_size(t1)
        li t3,0x400
        sll t2,t3,t2

        sd t2,fs_mount__block_size(t0)

        call fs_alloc_block_cache
        bnez a0,1f
        ebreak
        
1:      ld t0,fs_mount(sp)
        sd a0,fs_mount__block_cache(t0)

#        call fs_alloc_inode_cache
#        bnez a0,1f
#        ebreak
#        
#1:      ld t0,fs_mount(sp)
#        sd a0,fs_mount__inode_cache(t0)


        ld a0,fs_mount(sp)
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
