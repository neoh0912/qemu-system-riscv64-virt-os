kernel_heap_init:
        la a0,heap_start
        li a1,HEAP_SIZE
        tail heap_init

malloc:
#[ci [ a0 = size ]
        mv a1,a0
        la a0,heap_start
        tail heap_alloc

malloc_aligned:
#[ci [ a0 = size, a1 = alignment ]
        mv a2,a1
        mv a1,a0
        la a0,heap_start
        tail heap_alloc_aligned
