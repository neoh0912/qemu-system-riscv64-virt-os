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

        ld a0,_a0(sp)
        mv a1,s1
        call ext2_read
        call print_int_hex
        
        

        restore
        ret
