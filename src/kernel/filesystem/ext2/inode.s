.include "const/fs/mount.s"
.include "const/ext2.s"
ext2_get_inode:
#[ci [ mount, index ]
        save an=2,sn=3,dn=1
buf = _d0

        ld a0,fs_mount__block_size(a0)
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,buf(sp)

        ld a0,_a0(sp)
        ld a1,_a1(sp)

        ld t0,fs_mount__superblock_data(a0)
        lwu t1,s_inodes_per_group(t0)

        addi t2,a1,-0x1
        divu s1,t2,t1
        remu s2,t2,t1
        addi s1,s1,0x2
        lhu t1,s_inode_size(t0)
        mul s2,s2,t1
        ld t1,fs_mount__block_size(a0)
        divu s3,s2,t1
        remu s2,s2,t1

        ld a0,_a0(sp)
        mv a1,s1
        ld a2,buf(sp)
        call ext2_read_block
        ld a2,buf(sp)
        lwu a1,bg_inode_table(a2)
        add a1,a1,s3
        ld a0,_a0(sp)
        call ext2_read_block

        ld a0,_a0(sp)
        lwu s1,fs_mount__superblock_data(a0)
        lhu a0,s_inode_size(s1)
        mv s3,a0
        call malloc
        bnez a0,1f
        ebreak

1:      ld a1,buf(sp)
        add a1,a1,s2
        mv a2,s3
        mv s2,a0
        mv s1,a1
        call memcpy
        mv a0,s1
        call free
        mv a0,s2

        restore
        ret
