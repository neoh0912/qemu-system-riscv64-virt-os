.include "const/fs/mount.s"
.include "const/ext2.s"
ext2_get_inode:
#[ci [ mount, index ]
        save an=2,sn=2

        ld t0,fs_mount__superblock_data(a0)
        lwu t1,s_inodes_per_group(t0)

        addi t2,a1,-0x1
        divu s1,t2,t1
        remu s2,t2,t1
        addi s1,s1,0x2
        li t0,128
        mul s2,s2,t0

        ld a0,_a0(sp)
        mv a1,s1
        ebreak
        call ext2_read

        lwu a1,bg_inode_table(a0)
        ld a0,_a0(sp)
        ebreak
        call ext2_read
        add a0,a0,s2
        call print_int_hex

        restore
        ret
