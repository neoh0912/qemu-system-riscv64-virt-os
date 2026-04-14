.include "const/fs/mount.s"
.include "const/ext2.s"
ext2_read_inode:
#[ci [ mount, ino, buffer ]
        save an=3,sn=3,dn=1
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

        ld a0,_a2(sp)
        ld a1,buf(sp)
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

ext2_is_inode_directory:
#[ci [ inode ]
        lhu t0,i_mode(a0)
        li t1,0xF000
        and t0,t0,t1
        li t1,0x4000
        bne t0,t1,1f
        li a0,0x1
        ret
1:
        li a0,0x0
        ret

ext2_get_size_of_inode:
#[ci [ inode ]
        lwu a0,i_size(a0)
        ret
