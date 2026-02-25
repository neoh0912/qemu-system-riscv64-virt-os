.local HCSPARAMS1
.equ HCSPARAMS1,0x4

xhcl_discover_device:
        salloc 8
        sd s1,(sp)

        ld s1,xhcl_regs
        lwu t0,HCSPARAMS1(s1)
        srli t0,t0,24
        li t1,0x0

        ld t2,xhcl_opr_regs
        addi t2,t2,0x400

1:      

        addi t2,t2,0x10
        addi t1,t1,0x1
        blt t1,t0,1b

2:      ld s1,(sp)
        sfree 8
        ret
