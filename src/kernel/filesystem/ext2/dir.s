ext2_find_entry:
#[ci [ mount, inode, name ]
        save an=3,sn=4

        ld a0,fs_mount__block_size(a0)
        call malloc
        bnez a0,1f
        ebreak

1:      mv s1,a0

        ld a0,_a0(sp)
        ld a1,_a1(sp)
        mv a2,s1
#        call ext2_init_directory_iterator

        mv s2,a0

1:      mv a0,s2
#        call ext2_directory_iterator_next
        mv s3,a0

        beqz s3,ext2_find_error

        ld a0,_a2(sp)
#        call strcmp

        beqz a0,1b
        mv a0,s3
        j 9f


ext2_find_error:
        li a0,-ENOENT
        j 9f

9:      mv a0,s2
#        call ext2_destroy_directory_iterator
        mv a0,s1
        call free
        restore
        ret

