.include "const/fs/file_handle.s"
.include "const/fs/operations.s"
fs_create_file_handle:
#[ci [ fs_id, ino, file_size, flags, operations ]
        save an=5

        li a0,sizeof_FILE_HANDLE
        call malloc
        bnez a0,1f
        ebreak

1:      ld t0,_a0(sp)
        sd t0,FILE_HANDLE__fs_id(a0)
        ld t0,_a1(sp)
        sd t0,FILE_HANDLE__ino(a0)
        ld t0,_a2(sp)
        sd t0,FILE_HANDLE__file_size(a0)
        ld t0,_a3(sp)
        sd t0,FILE_HANDLE__flags(a0)
        ld t0,_a4(sp)
        sd t0,FILE_HANDLE__operations(a0)


        sd zero,FILE_HANDLE__offset(a0)


9:      restore
        ret
