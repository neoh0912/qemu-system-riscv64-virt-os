heap_init:

    la t0,heap_list
    li t1,HEAP_LIST_SIZE
    slli t1,t1,0x2
    addi t1,t1,0x2
    sw t1,(t0)
    ret

malloc:
#[ci [ a0 = size in bytes ]
    salloc 8
    sd s1,(sp)

    li t0,HEAP_BLOCK_SIZE
    divu t1,a0,t0
    remu t2,a0,t0
    beqz t2,1f
    addi t1,t1,0x1
1:  mv a0,t1

    #[ci [ Look for free block in heap list ]
    la s1,heap_list
    li t1,0
    li t2,HEAP_LIST_SIZE
1:  lwu t0,(s1)
    andi t3,t0,0x1 #[g is free
    bnez t3,2f
    srli t0,t0,1
    andi t3,t0,0x1 #[g is start
    beqz t3,2f

    srli t0,t0,1   #[g is large enough
    blt t0,a0,2f

    mv a1,s1
    mv a2,t0
    call heap_alloc
    j 9f

2:  addi s1,s1,0x4
    addi t1,t1,0x1
    blt t1,t2,1b    

9:  ld s1,(sp)
    sfree 8

    ret

zalloc:
#[ci [ a0 = size in bytes ]
        salloc 8
        
        sd a0,(sp)
        call malloc
        ld t1,(sp)
        mv t3,a0
        li t0,0x0

1:      sb zero,(t3)
        addi t3,t3,0x1
        addi t0,t0,0x1
        blt t0,t1,1b

        sfree 8
        ret

heap_alloc:
#[ci [ a0 = size in blk, a1 = heap_list index, a2 = free size ]
    #[ri [1]
    sub t0,a2,a0
    #[ri [2]
    slli t1,a0,0x2
    add t1,a1,t1
    slli t2,t0,0x2
    ori t3,t2,0x2
    sw t3,(t1)
    #[ri [3]
    addi t0,t0,-1
    slli t0,t0,0x2
    add t1,t1,t0
    sw t2,(t1)
1:
    
                    #[ri [4]
    slli t0,a0,0x2  #[ci [ size,1,1 ]
    addi t0,t0,0x3
    sw t0,(a1)
    addi t1,a0,-1
    beqz t1,1f
    slli t1,t1,0x2
    add t1,t1,a1
    xori t0,t0,0x2
    sw t0,(t1)
1:                  #[ri [5]
    la t0,heap_list
    sub t0,a1,t0
    srli t0,t0,0x2
    li t1,HEAP_BLOCK_SIZE
    mul t0,t0,t1
    la t1,heap
    add a0,t0,t1
    ret

free:
#[ci [ a0 = pointer to heap ]
    salloc 16
    sd s1,8(sp)
#[ri [1]
    la t0,heap
    sub t0,a0,t0
    li t1,HEAP_BLOCK_SIZE
    divu t0,t0,t1
    slli t0,t0,0x2
    la t1,heap_list
    add s1,t0,t1
#[ri [1.5]
    lwu t0,(s1)
    andi t1,t0,0x3
    bnez t1,1f
    ecall
1:
#[ri [2]
    li t1,0x1
    andn t1,t0,t1
    sw t1,(s1)

    li t1,0x3
    andn t0,t0,t1
    add t1,s1,t0
    addi t2,t1,-4
    sw t0,(t2)
#[ri [3]
    lwu t1,(t1)
    andi t2,t1,0x1
    bnez t2,1f
#[r 3.1
    mv a0,s1
    call heap_merge_free
#[ri [4]
1:  
    la t0,heap_list
    ble s1,t0,1f
    addi t0,s1,-4
    lwu t0,(t0)
    andi t1,t0,0x1
    bnez t1,1f
#[r 4.1
    srli t0,t0,0x2
    slli t0,t0,0x2
    sub a0,s1,t0
    call heap_merge_free
1:
    ld s1,8(sp)
    sfree 16
    ret

heap_merge_free:
#[ci [ a0 = Heap_list pointer ]
    lwu t0,(a0)
    li t1,0x3
    andn t0,t0,t1
    add t1,a0,t0
    lwu t2,(t1)
    
    sw zero,(t1)
    sw zero,-4(t1)
    
    srli t2,t2,0x2
    slli t2,t2,0x2
    
    lwu t0,(a0)
    add t0,t0,t2
    sw t0,(a0)
#[ri [ 2.1 ]
    li t1,0x3
    andn t0,t0,t1
    add t2,a0,t0
    addi t2,t2,-4
    li t1,0x2
    andn t1,t0,t1
    sw t1,(t2)
    ret


