sizeof_header = 0x18

heap_init:
#[ci [ a0 = start, a1 = size ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        sw a1,size(a0)
        sw zero,alloc(a0)
        sd zero,next(a0)
        sd a0,prev(a0)
        ret

heap_find_next_free:
#[ci [ current: *header, size: int ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        mv t0,a0

1:      lwu t1,alloc(t0)
        bnez t1,2f
        lwu t1,size(t0)
        blt t1,a1,2f
        mv a0,t0
        j 3f
        
2:      mv t1,t0
        ld t0,next(t1)
        bnez t0,1b
        li a0,0x0
        
3:      ret

heap_split_header:
#[ci [ header: *header, size: int ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        mv t0,a0
        add t1,t0,a1
        ld t2,next(t0)
        lwu t3,size(t0)
        sub t3,t3,a1
        sw a1,size(t0)
        sw t3,size(t1)
        sd t1,next(t0)
        sd t2,next(t1)
        sd t0,prev(t1)
        beqz t2,1f
        
        sd t1,prev(t2)
        
1:      mv a0,t0
        mv a1,t1
        ret

heap_merge_headers:
#[ci [ a,b ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        lwu t0,size(a0)
        lwu t1,size(a1)
        add t0,t0,t1
        sw t0,size(a0)

        ld t0,next(a1)
        sd t0,next(a0)
        beqz t0,1f
        sd a0,prev(t0)
1:      ret
        



heap_alloc:
#[ci [ heap: *header, size: int ]
alloc = 0x4
        save an=2
_heap = _a0
_size = _a1
        addi a1,a1,sizeof_header
        sd a1,_size(sp)

        call heap_find_next_free
        beqz a0,1f
        ld a1,_size(sp)
        call heap_split_header
        sw zero,alloc(a1)
        li t0,0x1
        sw t0,alloc(a0)
        addi a0,a0,sizeof_header
1:      restore
        ret

heap_alloc_aligned:
#[ci [ heap: *header, size: int, align: int ]

size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        save an=3,sn=3,bn=1
_heap = _a0
_size = _a1
_align = _a2
        addi a1,a1,sizeof_header
        sd a1,_size(sp)

        sb zero,_b0(sp)

        add s1,a1,a2
        addi s1,s1,-1
        mv s2,a0

1:      mv a0,s2
        mv a1,s1
        call heap_find_next_free
        beqz a0,9f
        
        mv s2,a0
        
        addi a0,a0,sizeof_header
        ld a1,_align(sp)
        call align
        addi a0,a0,-sizeof_header
        sub s3,a0,s2

        bnez s3,2f

        mv a0,s2
        ld a1,_size(sp)
        call heap_split_header
        sw zero,alloc(a1)
        li t0,0x1
        sw t0,alloc(a0)
        addi a0,a0,sizeof_header
        j 1f
        
2:      li t0,sizeof_header
        blt s3,t0,3f

        mv a0,s2
        mv a1,s3
        call heap_split_header
        sw zero,alloc(a0)
        li t0,0x1
        sw t0,alloc(a1)
        mv a0,a1
        ld a1,_size(sp)
        call heap_split_header
        sw zero,alloc(a1)
        addi a0,a0,sizeof_header
        j 1f
        
3:      ld s2,next(s2)
        li t0,0x1
        sb t0,_b0(sp)
        bnez s2,1b
        j 8f
        
9:      lbu t0,_b0(sp)
        beqz t0,1f
        
8:      ld a0,_heap(sp)
        ld a1,_size(sp)
        addi a1,a1,-sizeof_header
        ld a2,_align(sp)
        slli a2,a2,0x1
        call heap_alloc_aligned
        
1:      restore
        ret

free:
#[ci [ a0 = ptr ]
size = 0x0
alloc = 0x4
next = 0x8
prev = 0x10
        save
        addi a0,a0,-sizeof_header

        sw zero,(a0)
        ld t0,prev(a0)
        beqz t0,1f
        lwu t1,alloc(t0)
        bnez t1,1f
        mv a1,a0
        mv a0,t0
        call heap_merge_headers
1:      ld t0,next(a0)
        beqz t0,1f
        lwu t1,alloc(t0)
        bnez t1,1f
        mv a1,t0
        call heap_merge_headers

1:      restore
        ret
