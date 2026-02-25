.equ PLIC_BASE,      0x0c000000

plic_enable:
#[ci [ a0 = id ]
        salloc 0

        li t0, PLIC_BASE

        li t1, 0x2000
        add t1,t1,t0
        srli t2,a0,0x5
        slli t2,t2,0x2
        add t1,t1,t2
        lw t2,(t1)
        li t6,0x20
        remu t0,a0,t6
        li t3, 1
        sll t3,t3,t0
        or t2,t2,t3
        sw t2,(t1)

        sfree 0
        ret

plic_set_prio:
#[ci [ a0 = id, a1 = prio ]
        salloc 0

        li t0, PLIC_BASE
        slli t1,a0,0x2
        add t0,t0,t1
        sw a1, (t0)

        sfree 0
        ret

plic_set_prio_thres:
#[ci [ a0 = context, a1 = val ]
        salloc 0

        li t0, PLIC_BASE
        li t1, 0x200000
        add t1, t1, t0
        li t0,4096
        mul t0,t0,a0
        add t1,t1,t0
        sw a1, 0(t1)

        sfree 0
        ret

plic_get_ipb:
        salloc 0

        li t0,PLIC_BASE
        li t1,0x1000
        add t0,t0,t1
        lwu a0,(t0)

        sfree 0
        ret

plic_claim_interrupt:
#[ci [ a0 = context ]
        salloc 0

        li t0,PLIC_BASE
        li t1,0x200004
        add t0,t0,t1
        li t1,0x1000
        mul t1,t1,a0
        add t0,t0,t1
        lwu a0,(t0)
        
        sfree 0
        ret

plic_complete_interrupt:
#[ci [ a0 = context , a1 = id]
        salloc 0

        li t0,PLIC_BASE
        li t1,0x200004
        add t0,t0,t1
        li t1,0x1000
        mul t1,t1,a0
        add t0,t0,t1
        sw a1,(t0)
        
        sfree 0
        ret

