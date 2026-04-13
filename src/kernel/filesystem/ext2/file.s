.include "const/fs/mount.s"
ext2_open:
#[ci [ fs, path, flags ]
        save an=3,sn=6

        bltz a0,ext2_open_invalid_fs
        li t0,MAX_MOUNTED_FS
        bge a0,t0,ext2_open_invalid_fs

        call fs_get_mount
        mv s1,a0

        call fs_mount_is_valid
        beqz a0,ext2_open_invalid_fs

        beqz a1,ext2_open_invalid_path

        mv a0,s1
        ld a0,fs_mount__superblock_data(a0)
        call ext2_sb_get_inode_size

        call malloc
        bnez a0,1f
        ebreak

1:      mv s2,a0
        li a0,0x200
        call malloc
        bnez a0,1f
        ebreak

1:      mv s3,a0

        ld a1,_a1(sp)
        lbu t0,0x0(a1)
        li t1,'/'
        beq t0,t1,ext2_open_absolute_path
        li a0,-ENOENT
        j 9f

ext2_open_absolute_path:

        mv a0,s1
        call fs_mount_get_root_inode
        addi a1,a1,0x1
        mv s5,a0
        ld s6,_a1(sp)
        j ext2_open_walk

ext2_open_walk:

        mv a0,s6
        mv a1,s3
        call fs_path_next
        mv s6,a0

        lbu t0,(s3)
        beqz t0,ext2_open_done

        mv a1,s5
        mv a0,s1
        mv a2,s2
        call ext2_read_inode

        mv a0,s2
        call ext2_is_inode_directory
        beqz a0,ext2_open_not_a_directory

        mv a0,s1
        mv a1,s2
        mv a2,s3
        call ext2_find_entry
        bltz a0,ext2_open_no_entry

        mv s5,a0

        ebreak

        j ext2_open_walk

ext2_open_done:

        j 9f


ext2_open_no_entry:
        li a0,-ENOENT
        j 9f
        
ext2_open_not_a_directory:
        li a0,-3
        j 9f

ext2_open_invalid_fs: 
        li a0,-1
        j 9f

ext2_open_invalid_path:
        li a0,-2
        j 9f

9:      beqz s2,1f
        mv a0,s2
        call free
        
1:      beqz s6,1f
        mv a0,s6
        call free
              
1:      restore
        ret
