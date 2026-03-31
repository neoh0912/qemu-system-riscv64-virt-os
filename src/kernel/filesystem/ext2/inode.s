.include "const/fs/mount.s"
.include "const/ext2.s"
ext2_get_inode:
#[ci [ mount, index ]
        save an=2,sn=1

        ld t0,fs_mount__superblock_data(a0)
        lwu t1,s_inodes_per_group(t0)

        addi t2,a1,-0x1
        divu t1,t2,t1
        addi s1,t1,0x2

        
        
        

        restore
        ret
