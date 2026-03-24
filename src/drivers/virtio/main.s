.include "const/virtio/virt_queue.s"
virtio_supply_buffer_to_queue:
#[ci [ virt_queue, buffer, len, flag, next]
        save
addr = 0x0
len = 0x8
flags = 0xc
next = 0xe
        ld t0,VQ_DESCRIPTOR_TABLE(a0)
        ld t1,VQ_AVAIL_RING(a0)
        ld t3,VQ_SIZE(a0)
        lhu t2,0x2(t1)
        remu t2,t2,t3
        
        slli t3,t2,0x1
        addi t3,t3,0x4
        add t3,t3,t1
        slli t4,t2,0x4
        add t4,t4,t0
        ld t5,addr(t4)
        bnez t5,1f
        sd a1,addr(t4)
        sd a2,len(t4)
        sd a3,flags(t4)
        sd a4,next(t4)
        sh t2,(t3)
        fence rw,rw
        addi t2,t2,0x1
        sh t2,0x2(t1)
        fence rw,rw
        li a0,0x0
        j 2f
1:      li a0,-EAGAIN
2:
        restore
        ret
virtio_supply_buffer_chain_to_virtqueue:
#[ci [ virt_queue, requests, num]
        save an=3,sn=1

        li s1,0x0
1:      slli t0,s1,3
        li t1,0x3
        mul t0,t0,t1
        ld a1,_a1(sp)
        add a1,a1,t0
        ld a3,0x10(a1)
        ld a2,0x8(a1)
        ld a1,(a1)
        addi s1,s1,0x1
        li a4,0x0
        bne s1,a4,2f
        ori a3,a3,0x1
        li a4,0x1
2:      blt s1,a4,1b

        restore
        ret
