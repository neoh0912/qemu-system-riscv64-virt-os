machine_decode_instruction:
#[ci [ instruction ]
        save an=1

        li t0,0x7c
        and t0,a0,t0
        srli t0,t0,1
        

        auipc t1,1f
        add t0,t0,t1
        j t1

1:      j machine_decode_load
        j machine_decode_load_fp
        j machine_decode_end
        j machine_decode_misc_mem
        j machine_decode_op_imm
        j machine_decode_auipc
        j machine_decode_op_imm_32
        j machine_decode_end
        j machine_decode_store
        j machine_decode_store_fp
        j machine_decode_end
        j machine_decode_amo
        j machine_decode_op
        j machine_decode_lui
        j machine_decode_op_32
        j machine_decode_end
        j machine_decode_madd
        j machine_decode_msub
        j machine_decode_nmsub
        j machine_decode_nmadd
        j machine_decode_op_fp
        j machine_decode_op_v
        j machine_decode_end
        j machine_decode_end
        j machine_decode_branch
        j machine_decode_jalr
        j machine_decode_end
        j machine_decode_jal
        j machine_decode_system
        j machine_decode_end
        j machine_decode_end



machine_decode_load:
        srli t0,a0,12
        andi t0,t0,0x7
        slli t0,t0,3

        auipc t1,1f
        add t0,t0,t1
        j t1

1:      la t0,machine_decode__lb
        j 1f
        la t0,machine_decode__lh
        j 1f
        la t0,machine_decode__lw
        j 1f
        la t0,machine_decode__
        j 1f
        la t0,machine_decode__lbu
        j 1f
        la t0,machine_decode__lhu
        j 1f


1:      mv a1,t0
        call machine_decode_i_type
        j machine_decode_end
        
machine_decode_load_fp:
        j machine_decode_end
machine_decode_misc_mem:
        j machine_decode_end
machine_decode_op_imm:
        j machine_decode_end
machine_decode_auipc:
        j machine_decode_end
machine_decode_op_imm_32:
        j machine_decode_end
machine_decode_store:
        srli t0,a0,12
        andi t0,t0,0x7
        slli t0,t0,3

        auipc t1,1f
        add t0,t0,t1
        j t1

1:      la t0,machine_decode__sb
        j 1f
        la t0,machine_decode__sh
        j 1f
        la t0,machine_decode__sw
        j 1f

1:      mv a1,t0
        call machine_decode_s_type
        j machine_decode_end
        
machine_decode_store_fp:
        j machine_decode_end
machine_decode_amo:
        j machine_decode_end
machine_decode_op:
        j machine_decode_end
machine_decode_lui:
        j machine_decode_end
machine_decode_op_32:
        j machine_decode_end
machine_decode_madd:
        j machine_decode_end
machine_decode_msub:
        j machine_decode_end
machine_decode_nmsub:
        j machine_decode_end
machine_decode_nmadd:
        j machine_decode_end
machine_decode_op_fp:
        j machine_decode_end
machine_decode_op_v:
        j machine_decode_end
machine_decode_branch:
        j machine_decode_end
machine_decode_jalr:
        j machine_decode_end
machine_decode_end:
        j machine_decode_end
machine_decode_jal:
        j machine_decode_end
machine_decode_system:
        j machine_decode_end



machine_decode_end:

        restore
        ret

