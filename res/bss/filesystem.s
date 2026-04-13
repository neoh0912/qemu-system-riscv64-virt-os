.include "const/fs/mount.s"
fs_mounted_filesystems: .space (MAX_MOUNTED_FS * sizeof_fs_mount)
