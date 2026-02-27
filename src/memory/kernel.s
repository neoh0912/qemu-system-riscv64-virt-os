kernel_heap_init:
        salloc 0

        la a0,heap_start
        li a1,HEAP_SIZE
        call heap_init

        sfree
        ret

malloc:
#[ci [ a0 = size ]
        salloc 0

        addi a1,a0,0x18
        la a0,heap_start
        li a2,0x1
        call heap_alloc
        addi a0,a0,0x18
        sfree
        ret

malloc_aligned:
#[ci [ a0 = size, a1 = alignment ]
        salloc 8
        sd a1,0x0(sp)
        add a0,a0,a1
        addi a1,a0,0x18+0x8-1
        la a0,heap_start
        li a2,0x2
        call heap_alloc
        ld a1,0x0(sp)
        addi a0,a0,0x20
        remu t0,a0,a1
        sub t1,a0,t0
        beq t1,a0,1f
        add t1,t1,a1
1:      sd t1,-0x8(a0)
        mv a0,t1
        sfree
        ret

free_aligned:
#[ci [ a0 = *ptr ]
addr = 0x20
alloc = 0x4
next = 0x8
        salloc 8

        la t0,heap_start

1:      lwu t1,alloc(t0)
        li t2,0x2
        bne t1,t2,2f
        ld t1,addr(t0)
        bne t1,a0,2f
        mv a1,t0
        la a0,heap_start
        call heap_dealloc
        
        j 3f

2:      mv t1,t0
        ld t0,next(t1)
        bne t0,t1,1b
        
3:      sfree
        ret

free:
#[ci [ a0 = *ptr ]
        salloc 0

        addi a1,a0,-0x18
        la a0,heap_start
        call heap_dealloc

        sfree
        ret
