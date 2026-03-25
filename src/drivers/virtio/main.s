.include "const/virtio/virt_queue.s"
virtio_supply_buffer_to_queue:
#[ci [ virt_queue, buffer, len, flag, next]
        save
addr = 0x0
len = 0x8
flags = 0xc
next = 0xe
        ld t0,VQ_DESCRIPTOR_TABLE(a0)
        ld t1,VQ_SIZE(a0)
        li t3,0
1:      ld t2,addr(t0)
        beqz t2,1f
        addi t0,t0,16
        addi t3,t3,1
        blt t3,t1,1b
        li a0,-EAGAIN
        j 2f
        
1:      sd a1,addr(t0)
        sd a2,len(t0)
        sd a3,flags(t0)
        
        sd zero,next(t0)
        li a0,0x0
        mv a1,t3
        addi a2,t0,next
2:      restore
        ret
        
virtio_supply_buffer_chain_to_virtqueue:
#[ci [ virt_queue, requests, num]
        save an=3,sn=3

        li s1,0x0
        li s2,0xFFFFFFFF
1:      slli t0,s1,3
        li t1,3
        mul t0,t0,t1
        ld a1,_a1(sp)
        add a1,a1,t0
        ld a3,0x10(a1)
        ld a2,0x8(a1)
        ld a1,(a1)
        addi s1,s1,0x1
        ld t0,_a2(sp)
        ld a0,_a0(sp)
        beq s1,t0,2f
        ori a3,a3,0x1
2:      call virtio_supply_buffer_to_queue
        break_on_error
        li t0,0xFFFFFFFF
        bne s2,t0,3f
        mv s2,a1
        j 4f
3:      sh a1,(s3)

4:      mv s3,a2
        ld t0,_a2(sp)
        blt s1,t0,1b

        ld a0,_a0(sp)

        ld t0,VQ_AVAIL_RING(a0)
        lhu t1,0x2(t0)
        slli t2,t2,0x1
        addi t2,t2,0x4
        add t2,t2,t0
        sh s2,(t2)
        addi t1,t1,0x1
        sh t1,0x2(t0)

        mv a0,s2

        restore
        ret
