.include "const/ext2.s"
ext2_sb_get_inode_size:
#[ci [ sb ]
        lhu a0,s_inode_size(a0)
        ret
