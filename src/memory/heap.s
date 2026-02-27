heap_init:
#[ci [ a0 = start, a1 = size ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        salloc 0

        sw a1,size(a0)
        sw zero,alloc(a0)
        sd a0,next(a0)
        sd a0,prev(a0)

        sfree
        ret

heap_alloc:
#[ci [ a0 = heap, a1 = size, a2 = alloc ]
A0 = 0x0
A1 = 0x8
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        salloc 0
        sald 2
        sd a0,A0(sp)
        sd a1,A1(sp)
#        ebreak
        call heap_find_free
        mv t0,a0
        bnez t0,1f
        ebreak
        
1:      ld a1,A1(sp)
        add t1,t0,a1
        lwu t2,size(t0)
        sub t2,t2,a1
        ld t3,next(t0)
        
        sw a2,alloc(t0)
        sw a1,size(t0)
        sd t1,next(t0)

        sw t2,size(t1)
        sw zero,alloc(t1)
        sd t3,next(t1)
        sd t0,prev(t1)

        mv a0,t0
        
        sfree
        ret

heap_find_free:
#[ci [ a0 = heap, a1 = size ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        salloc 0
        
        mv t0,a0
1:      lwu t1,alloc(t0)
        bnez t1,2f
        lwu t1,size(t0)
        blt t1,a1,2f
        mv a0,t0
        j 3f

2:      mv t1,t0
        ld t0,next(t1)
        bne t0,t1,1b
        li a0,0x0
        

3:      sfree
        ret

heap_dealloc:
#[ci [ a0 = heap, a1 = ptr ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        salloc 0

        ld t0,prev(a1)
        lwu t1,alloc(t0)
        bnez t1,1f
        ld t1,next(a1)
        sd t1,next(t0)
        sd t0,prev(t1)

        lwu t1,size(a1)
        lwu t2,size(t0)
        add t1,t1,t2
        sw t1,size(t0)
        mv a1,t0
        j 2f
        
1:      sw zero,alloc(a1)
2:      ld t0,next(a1)
        lwu t1,alloc(t0)
        bnez t1,1f
        mv a1,t0
        ld t0,prev(a1)
        ld t1,next(a1)
        sd t1,next(t0)
        sd t0,prev(t1)

        lwu t1,size(a1)
        lwu t2,size(t0)
        add t1,t1,t2
        sw t1,size(t0)

1:      sfree
        ret
