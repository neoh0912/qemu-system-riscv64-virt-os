sizeof_RRIP_CACHE_HEAD = 0x8
sizeof_RRIP_CACHE_ELEMENT = 0x8*4

rrip_cache__size = 0x0
rrip_cache__cache = sizeof_RRIP_CACHE_HEAD

rrip_cache_e__tag = 0x0
rrip_cache_e__value = 0x8
rrip_cache_e__rrpv = 0x10



rrip_create:
#[ci [ size ]
        save an=1,dn=1

        li t0,sizeof_RRIP_CACHE_ELEMENT
        mul t0,t0,a0
        addi a0,t0,sizeof_RRIP_CACHE_HEAD
        sd a0,_d0(sp)
        call malloc
        bnez a0,1f
        ebreak
        
1:      ld a2,_d0(sp)
        li a1,0x0
        call memset

        ld t1,_a0(sp)
        sd t1,rrip_cache__size(a0)
        sd a0,_a0(sp)
        li t0,0
        li t2,0x3
        li t3,0x0
        addi t3,t3,-1
        
1:      sb t2,(rrip_cache__cache + rrip_cache_e__rrpv)(a0)
        sd t3,(rrip_cache__cache + rrip_cache_e__tag)(a0)

        addi t0,t0,0x1
        addi a0,a0,sizeof_RRIP_CACHE_ELEMENT
        blt t0,t1,1b

        ld a0,_a0(sp)

        restore
        ret

rrip_get:
#[ci [ cache, tag ] -> address, is_hit
        save an=2

        ld t1,rrip_cache__size(a0)
        li t0,0x0

1:      ld t2,(rrip_cache__cache + rrip_cache_e__tag)(a0)
        bne t2,a1,2f

        sb zero,(rrip_cache__cache + rrip_cache_e__rrpv)(a0)
        ld a0,(rrip_cache__cache + rrip_cache_e__value)(a0)
        li a1,0x1
        j 9f
        
2:      addi t0,t0,0x1
        addi a0,a0,sizeof_RRIP_CACHE_ELEMENT
        blt t0,t1,1b

3:      ld a0,_a0(sp)
        ld t1,rrip_cache__size(a0)
        li t2,0x3
        li t0,0x0
        
1:      lbu t3,(rrip_cache__cache + rrip_cache_e__rrpv)(a0)
        bne t3,t2,2f

        addi a0,a0,rrip_cache__cache
        li a1,0x0
        j 9f

2:      addi t0,t0,0x1
        addi a0,a0,sizeof_RRIP_CACHE_ELEMENT
        blt t0,t1,1b

        li t0,0x0
        ld a0,_a0(sp)
        
1:      lbu t2,(rrip_cache__cache + rrip_cache_e__rrpv)(a0)
        addi t2,t2,0x1
        sb t2,(rrip_cache__cache + rrip_cache_e__rrpv)(a0)

        addi t0,t0,0x1
        addi a0,a0,sizeof_RRIP_CACHE_ELEMENT
        blt t0,t1,1b
        
        j 3b

9:      restore
        ret

rrip_set:
#[ci [ address, tag, value ]
        save an=3

        sd a1,rrip_cache_e__tag(a0)
        sd a2,rrip_cache_e__value(a0)
        li t0,0x2
        sb t0,rrip_cache_e__rrpv(a0)

        restore
        ret

rrip_get_rrpv:
#[ci [ cache, tag ] -> rrpv, hit 
        save an=2

        ld t1,rrip_cache__size(a0)
        li t0,0x0

1:      ld t2,(rrip_cache__cache + rrip_cache_e__tag)(a0)
        bne t2,a1,2f

        lbu a0,(rrip_cache__cache + rrip_cache_e__rrpv)(a0)
        li a1,0x1
        j 9f
        
2:      addi t0,t0,0x1
        addi a0,a0,sizeof_RRIP_CACHE_ELEMENT
        blt t0,t1,1b

        li a1,0x0

9:      restore
        ret

